import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/coach_chat/chat_coach_list_item.dart';
import 'package:SmartQuitIoT/views/screens/coach_chat/chat_recent_item.dart';
import '../coach_chat/coach_chat_screen.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> coaches = [
    {
      'name': 'Coach Michael',
      'specialty': 'Quit Smoking Specialist',
      'avatar':
      'https://images.unsplash.com/photo-1598994291074-0c334b2f7d4b?auto=format&fit=crop&q=80&w=1000'
    },
    {
      'name': 'Coach Sarah',
      'specialty': 'Health Coach',
      'avatar':
      'https://images.unsplash.com/photo-1556157382-97eda2d62296?auto=format&fit=crop&q=80&w=1000'
    },
  ];

  final List<Map<String, String>> recentChats = [
    {
      'name': 'Coach Michael',
      'message': 'How was your day quitting today?',
      'time': '14:30',
      'avatar':
      'https://images.unsplash.com/photo-1598994291074-0c334b2f7d4b?auto=format&fit=crop&q=80&w=1000'
    },
    {
      'name': 'Coach Sarah',
      'message': 'I’m proud of your progress!',
      'time': '13:00',
      'avatar':
      'https://images.unsplash.com/photo-1556157382-97eda2d62296?auto=format&fit=crop&q=80&w=1000'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToCoachChat(Map<String, String> coach) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoachChatScreen(coach: coach),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        title: const Text(
          'Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Coaches'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Coaches list
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coaches.length,
            itemBuilder: (context, index) {
              final coach = coaches[index];
              return GestureDetector(
                onTap: () => _navigateToCoachChat(coach),
                child: ChatCoachListItem(coach: coach, onTap: () {  },),
              );
            },
          ),
          // Tab 2: Recent messages
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recentChats.length,
            itemBuilder: (context, index) {
              final chat = recentChats[index];
              return ChatRecentItem(
                name: chat['name'] ?? '',
                lastMessage: chat['message'] ?? '',
                avatar: chat['avatar'] ?? '',
                time: chat['time'] ?? '',
              );
            },
          ),
        ],
      ),
    );
  }
}
