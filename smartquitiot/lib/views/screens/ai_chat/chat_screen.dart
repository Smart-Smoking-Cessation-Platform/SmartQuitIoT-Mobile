import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/widgets/chat/chat_coach_list_item.dart';
import 'package:SmartQuitIoT/views/widgets/lists/chat_recent_item.dart';
import 'package:SmartQuitIoT/views/widgets/chat/chat_message_bubble.dart';
import 'package:SmartQuitIoT/views/widgets/ai/ai_chat_message_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Message Box',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Chat'),
            Tab(text: 'Message'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildChatTab(), _buildMessageTab()],
      ),
    );
  }

  Widget _buildChatTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _coaches.length,
      itemBuilder: (context, index) {
        final coach = _coaches[index];
        return ChatCoachListItem(
          coach: coach,
          onTap: () => _navigateToCoachChat(coach),
        );
      },
    );
  }

  Widget _buildMessageTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentChats.length,
      itemBuilder: (context, index) {
        final chat = _recentChats[index];
        return ChatRecentItem(
          name: chat['name'],
          lastMessage: chat['lastMessage'],
          avatar: chat['avatar'],
          time: chat['time'],
          onTap: () {
            // Tìm coach tương ứng theo avatar hoặc name
            final coach = _coaches.firstWhere(
              (c) => c['avatar'] == chat['avatar'],
              orElse: () => {
                'name': chat['name'],
                'avatar': chat['avatar'],
                'specialty': 'Unknown',
                'isOnline': false,
                'rating': 0.0,
              },
            );
            _navigateToCoachChat(coach);
          },
        );
      },
    );
  }

  void _navigateToCoachChat(Map<String, dynamic> coach) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CoachChatScreen(coach: coach)),
    );
  }

  final List<Map<String, dynamic>> _coaches = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Addiction Specialist',
      'avatar': 'https://i.pravatar.cc/150?img=47',
      'isOnline': true,
      'rating': 4.9,
    },
    {
      'name': 'Michael Chen',
      'specialty': 'Behavioral Therapist',
      'avatar': 'https://i.pravatar.cc/150?img=48',
      'isOnline': true,
      'rating': 4.8,
    },
    {
      'name': 'Dr. Emily Rodriguez',
      'specialty': 'Health Coach',
      'avatar': 'https://i.pravatar.cc/150?img=49',
      'isOnline': false,
      'rating': 4.9,
    },
  ];

  final List<Map<String, dynamic>> _recentChats = [
    {
      'name': 'Maximillian Jacobson',
      'lastMessage': 'It was a pleasure to accommodate your request...',
      'avatar': 'https://i.pravatar.cc/150?img=50',
      'time': 'Just now',
    },
    {
      'name': 'Dr. Sarah Johnson',
      'lastMessage': 'Great progress! Keep it up!',
      'avatar': 'https://i.pravatar.cc/150?img=47',
      'time': '2 min ago',
    },
    {
      'name': 'Michael Chen',
      'lastMessage': 'Remember to practice the breathing exercises',
      'avatar': 'https://i.pravatar.cc/150?img=48',
      'time': '1 hour ago',
    },
  ];
}

class CoachChatScreen extends StatelessWidget {
  final Map<String, dynamic> coach;

  const CoachChatScreen({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(coach['avatar']),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coach['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  coach['specialty'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ChatMessageBubble(
                  text: 'Welcome, I am your virtual assistant.',
                  isFromCoach: true,
                  time: '14:00',
                  coachAvatar: coach['avatar'],
                ),
                ChatMessageBubble(
                  text: 'How can I help you today?',
                  isFromCoach: true,
                  time: '14:01',
                  coachAvatar: coach['avatar'],
                ),
                ChatMessageBubble(
                  text:
                      'Hello! I have a question. How can I record my expenses by date?',
                  isFromCoach: false,
                  time: '14:03',
                ),
                ChatMessageBubble(
                  text:
                      'Response to your request: You can register expenses in the top menu of the homepage.',
                  isFromCoach: true,
                  time: '14:05',
                  coachAvatar: coach['avatar'],
                ),
                ChatMessageBubble(
                  text:
                      'Enter the purchase information, including the date, etc.',
                  isFromCoach: true,
                  time: '14:05',
                  coachAvatar: coach['avatar'],
                ),
                ChatMessageBubble(
                  text: 'OK, thanks a lot.',
                  isFromCoach: false,
                  time: '14:06',
                ),
                ChatMessageBubble(
                  text:
                      'It was a pleasure to accommodate your request. See you soon!',
                  isFromCoach: true,
                  time: '14:06',
                  coachAvatar: coach['avatar'],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '14:06 | Chat Ended',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: const AiChatMessageInput(hintText: 'Write Here...'),
    );
  }
}
