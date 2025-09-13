import 'package:flutter/material.dart';
import '../widgets/chat_coach_list_item.dart';

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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Message Box',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00D09E),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00D09E),
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
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _coaches.length,
            itemBuilder: (context, index) {
              final coach = _coaches[index];
              return ChatCoachListItem(
                coach: coach,
                onTap: () => _navigateToCoachChat(coach),
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentChats.length,
      itemBuilder: (context, index) {
        final chat = _recentChats[index];
        return _buildRecentChatItem(chat);
      },
    );
  }

  Widget _buildRecentChatItem(Map<String, dynamic> chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(chat['avatar']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  chat['lastMessage'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              const SizedBox(height: 4),
              Text(
                chat['time'],
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Write Here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00D09E),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCoachChat(Map<String, dynamic> coach) {
    // Navigate to individual coach chat
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CoachChatScreen(coach: coach)),
    );
  }

  final List<Map<String, dynamic>> _coaches = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Addiction Specialist',
      'avatar': 'https://via.placeholder.com/50',
      'isOnline': true,
      'rating': 4.9,
    },
    {
      'name': 'Michael Chen',
      'specialty': 'Behavioral Therapist',
      'avatar': 'https://via.placeholder.com/50',
      'isOnline': true,
      'rating': 4.8,
    },
    {
      'name': 'Dr. Emily Rodriguez',
      'specialty': 'Health Coach',
      'avatar': 'https://via.placeholder.com/50',
      'isOnline': false,
      'rating': 4.9,
    },
  ];

  final List<Map<String, dynamic>> _recentChats = [
    {
      'name': 'Maximillian Jacobson',
      'lastMessage': 'It was a pleasure to accommodate your request...',
      'avatar': 'https://via.placeholder.com/50',
      'time': 'Just now',
    },
    {
      'name': 'Dr. Sarah Johnson',
      'lastMessage': 'Great progress! Keep it up!',
      'avatar': 'https://via.placeholder.com/50',
      'time': '2 min ago',
    },
    {
      'name': 'Michael Chen',
      'lastMessage': 'Remember to practice the breathing exercises',
      'avatar': 'https://via.placeholder.com/50',
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                  coach['name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  coach['specialty'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
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
                _buildMessage(
                  'Welcome, I am your virtual assistant.',
                  true,
                  '14:00',
                ),
                _buildMessage('How can I help you today?', true, '14:01'),
                _buildMessage(
                  'Hello! I have a question. How can I record my expenses by date?',
                  false,
                  '14:03',
                ),
                _buildMessage(
                  'Response to your request: You can register expenses in the top menu of the homepage.',
                  true,
                  '14:05',
                ),
                _buildMessage(
                  'Enter the purchase information, including the date, etc.',
                  true,
                  '14:05',
                ),
                _buildMessage('OK, thanks a lot.', false, '14:06'),
                _buildMessage(
                  'It was a pleasure to accommodate your request. See you soon!',
                  true,
                  '14:06',
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

  Widget _buildMessage(String text, bool isFromCoach, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isFromCoach
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (isFromCoach) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(coach['avatar']),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromCoach ? Colors.white : const Color(0xFF00D09E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isFromCoach ? Colors.black : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: isFromCoach ? Colors.grey[500] : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isFromCoach) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF00D09E),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Write Here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00D09E),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
