import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/chat/community_chats_widget.dart';
import 'package:acumen/widgets/chat/new_chat_dialog_widget.dart';
import 'package:acumen/widgets/chat/new_community_dialog_widget.dart';
import 'package:acumen/features/resources/widgets/resources_tab_widget.dart';
import 'package:acumen/widgets/chat/solo_chats_widget.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/features/chat/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';


class ChatsScreen extends StatefulWidget {
  final int initialTabIndex;
  final UserModel? selectedMentor;

  const ChatsScreen({
    super.key,
    this.initialTabIndex = 0,
    this.selectedMentor,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _tabs = ['Solo', 'Community', 'Resources'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // If a mentor is selected, create a chat with them
    if (widget.selectedMentor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createChatWithMentor(widget.selectedMentor!);
      });
    }

    // Fetch available communities for joining
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatController>(context, listen: false).fetchAvailableCommunities();
    });
  }

  Future<void> _createChatWithMentor(UserModel mentor) async {
    try {
      final chatController = Provider.of<ChatController>(context, listen: false);
      final conversation = await chatController.createConversation(
        participantId: mentor.id,
        participantName: mentor.name,
        participantImageUrl: mentor.photoUrl,
      );
    
      if (!mounted) return;
      
      // Navigate to the chat detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            conversationId: conversation.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final chatController = Provider.of<ChatController>(context, listen: false);
    
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
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
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
                  const SoloChatsWidget(),
                  const CommunityChatsWidget(),
                  const ResourcesTabWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: (_tabController.index == 0) ? FloatingActionButton(
        onPressed: () => NewChatDialogWidget.show(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.chat, color: Colors.white),
      ) : (_tabController.index == 1 && chatController.canCreateCommunities(context)) ? FloatingActionButton(
        onPressed: () => NewCommunityDialogWidget.show(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.group_add, color: Colors.white),
      ) : null,
    );
  }
} 
