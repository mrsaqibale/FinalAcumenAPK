import 'package:acumen/features/events/models/event_model.dart';
import 'package:acumen/features/notification/controllers/notification_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class EventController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<EventModel> _events = [];
  List<EventModel> _activeEvents = [];
  List<EventModel> _pastEvents = [];
  bool _isLoading = false;
  Timer? _expirationCheckTimer;

  // Getters
  List<EventModel> get events => _events;
  List<EventModel> get activeEvents => _activeEvents;
  List<EventModel> get pastEvents => _pastEvents;
  bool get isLoading => _isLoading;

  EventController() {
    // Start the expiration check timer
    _startExpirationCheck();
  }

  @override
  void dispose() {
    _expirationCheckTimer?.cancel();
    super.dispose();
  }

  // Start a timer to check for expired events every hour
  void _startExpirationCheck() {
    // Check immediately once
    _checkForExpiredEvents();
    
    // Then set up a periodic check
    _expirationCheckTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkForExpiredEvents();
    });
  }

  // Check if any active events have expired
  void _checkForExpiredEvents() async {
    final now = DateTime.now();
    bool hasChanges = false;
    
    for (final event in _activeEvents) {
      if (event.endDate.isBefore(now)) {
        // This event has expired, mark it as inactive
        if (kDebugMode) {
          print('Event expired: ${event.title}');
        }
        
        await markEventAsInactive(event.id);
        hasChanges = true;
      }
    }
    
    // If any events were marked inactive, reload the events
    if (hasChanges) {
      await loadEvents();
    }
  }

  // Force check for expired events (can be called from outside)
  Future<void> checkForExpiredEvents(BuildContext context) async {
    final now = DateTime.now();
    bool hasChanges = false;
    
    for (final event in _activeEvents) {
      if (event.endDate.isBefore(now)) {
        // This event has expired, mark it as inactive
        if (kDebugMode) {
          print('Event expired: ${event.title}');
        }
        
        await markEventAsInactive(event.id);
        hasChanges = true;
      }
    }
    
    // If any events were marked inactive, reload the events
    if (hasChanges) {
      await loadEvents();
      
      // Sync with notification controller if available
      try {
        final notificationController = Provider.of<NotificationController>(context, listen: false);
        await notificationController.syncWithEvents(_activeEvents);
      } catch (e) {
        if (kDebugMode) {
          print('Could not sync with notification controller: $e');
        }
      }
    }
  }

  // Load all events
  Future<void> loadEvents() async {
    _setLoading(true);
    try {
      if (kDebugMode) {
        print('Loading events from Firestore...');
      }
      
      final snapshot = await _firestore.collection('events').orderBy('startDate', descending: true).get();
      
      if (kDebugMode) {
        print('Got ${snapshot.docs.length} events from Firestore');
      }
      
      _events = [];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          if (kDebugMode) {
            print('Processing event ${doc.id}: ${data['title']}');
          }
          
          final event = EventModel.fromMap(data, doc.id);
          _events.add(event);
        } catch (e) {
          if (kDebugMode) {
            print('Error processing event ${doc.id}: $e');
            print('Event data: ${doc.data()}');
          }
        }
      }
      
      _filterEvents();
      
      if (kDebugMode) {
        print('Successfully loaded ${_events.length} events');
        print('Active events: ${_activeEvents.length}');
        print('Past events: ${_pastEvents.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading events: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Filter events into active and past
  void _filterEvents() {
    final now = DateTime.now();
    
    _activeEvents = _events
        .where((event) => event.endDate.isAfter(now) && event.isActive)
        .toList();
    
    _pastEvents = _events
        .where((event) => event.endDate.isBefore(now) || !event.isActive)
        .toList();
    
    notifyListeners();
  }

  // Create a new event
  Future<bool> createEvent(EventModel event) async {
    _setLoading(true);
    try {
      // Convert DateTime fields to Timestamp before saving
      final eventMap = event.toMap();
      
      await _firestore.collection('events').add(eventMap);
      await loadEvents();
      // Check for expired events immediately after creating a new event
      _checkForExpiredEvents();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating event: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an event
  Future<bool> updateEvent(EventModel event) async {
    _setLoading(true);
    try {
      // Convert DateTime fields to Timestamp before saving
      final eventMap = event.toMap();
      
      await _firestore.collection('events').doc(event.id).update(eventMap);
      await loadEvents();
      // Check for expired events immediately after updating an event
      _checkForExpiredEvents();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating event: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete an event
  Future<bool> deleteEvent(String eventId) async {
    _setLoading(true);
    try {
      await _firestore.collection('events').doc(eventId).delete();
      await loadEvents();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting event: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark event as inactive
  Future<bool> markEventAsInactive(String eventId) async {
    _setLoading(true);
    try {
      await _firestore.collection('events').doc(eventId).update({
        'isActive': false
      });
      await loadEvents();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking event as inactive: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 