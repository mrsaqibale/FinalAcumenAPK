import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  final int initialTabIndex;

  const ChatsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _tabs = ['Solo', 'Community', 'Resources'];
  
  // Sample data for solo chats
  final List<Map<String, dynamic>> _soloChats = [
    {
      'name': 'Jacob Wilson',
      'message': 'How\'s it going',
      'time': '10:30',
      'hasAvatar': true,
      'gender': 'male',
    },
    {
      'name': 'Jenny',
      'message': 'Thanks for updating',
      'time': '10:30',
      'hasAvatar': true,
      'gender': 'female',
    },
    {
      'name': 'Albert',
      'message': 'How\'s it going',
      'time': '10:30',
      'hasAvatar': false,
      'gender': 'male',
    },
    {
      'name': 'Tiffni',
      'message': 'Thanks for updating',
      'time': '10:30',
      'hasAvatar': true,
      'gender': 'female',
    },
  ];
  
  // Sample data for community chats
  final List<Map<String, dynamic>> _communityChats = [
    {
      'name': 'Group 1',
      'message': 'How\'s it going',
      'time': '10:30',
      'hasAvatar': false,
    },
    {
      'name': 'Group 2',
      'message': 'Thanks for updating',
      'time': '10:30',
      'hasAvatar': false,
    },
    {
      'name': 'Group 3',
      'message': 'How\'s it going',
      'time': '10:30',
      'hasAvatar': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                  insets: EdgeInsets.symmetric(horizontal: 10.0),
                ),
                dividerHeight: 0,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withAlpha(179),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSoloChats(),
                  _buildCommunityChats(),
                  _buildResourcesTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoloChats() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: _soloChats.length,
      itemBuilder: (context, index) {
        final chat = _soloChats[index];
        return _buildChatCard(
          name: chat['name'],
          message: chat['message'],
          time: chat['time'],
          isGroup: false,
          hasAvatar: chat['hasAvatar'],
          gender: chat['gender'],
        );
      },
    );
  }

  Widget _buildCommunityChats() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: _communityChats.length,
      itemBuilder: (context, index) {
        final chat = _communityChats[index];
        return _buildChatCard(
          name: chat['name'],
          message: chat['message'],
          time: chat['time'],
          isGroup: true,
          hasAvatar: chat['hasAvatar'] ?? false,
          gender: null,
        );
      },
    );
  }

  Widget _buildResourcesTab() {
    // Placeholder for resources tab
    return const Center(
      child: Text(
        'Resources Coming Soon',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildChatCard({
    required String name,
    required String message,
    required String time,
    required bool isGroup,
    required bool hasAvatar,
    String? gender,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: _buildAvatar(hasAvatar, isGroup, gender, name),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                name: name,
                isGroup: isGroup,
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAvatar(bool hasAvatar, bool isGroup, String? gender, String name) {
    if (isGroup) {
      return CircleAvatar(
        backgroundColor: Colors.grey[400],
        radius: 24,
        child: const Icon(
          Icons.group,
          color: Colors.white,
          size: 30,
        ),
      );
    } else if (hasAvatar) {
      return CircleAvatar(
        backgroundColor: Colors.black,
        radius: 24,
        child: gender == 'female' 
          ? const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 30,
            )
          : ClipOval(
              child: Image.asset(
                'assets/images/profile-img.png',
                fit: BoxFit.cover,
              ),
            ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.grey[400],
        radius: 24,
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }
  }
} 
