import 'package:SmartQuitIoT/views/screens/coach_chat/chat_screen_detail.dart';
import 'package:flutter/material.dart';

           // ========================================
// Fake data model
// ========================================
class Coach {
  final String name;
  final String specialty;
  final String avatar;
  final String bio;
  final double rating;
  final bool isOnline;

  Coach({
    required this.name,
    required this.specialty,
    required this.avatar,
    required this.bio,
    required this.rating,
    required this.isOnline,
  });
}

// ========================================
// Chat Screen with Tabs
// ========================================
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Coach> coaches = [
    Coach(
      name: 'Coach Michael',
      specialty: 'Quit Smoking Specialist',
      avatar:
      'https://images.unsplash.com/photo-1598994291074-0c334b2f7d4b?auto=format&fit=crop&q=80&w=1000',
      bio: 'I help people quit smoking using science-based techniques.',
      rating: 4.9,
      isOnline: true,
    ),
    Coach(
      name: 'Coach Sarah',
      specialty: 'Health Coach',
      avatar:
      'https://images.unsplash.com/photo-1556157382-97eda2d62296?auto=format&fit=crop&q=80&w=1000',
      bio: 'I focus on holistic health and mental wellbeing.',
      rating: 4.7,
      isOnline: false,
    ),
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

  void _showCoachDetailModal(Coach coach) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 12),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(coach.avatar),
                ),
                const SizedBox(height: 12),
                Text(
                  coach.name,
                  style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  coach.specialty,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(coach.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    const Icon(Icons.group, color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 4),
                    const Text('120+ students',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Languages: English, Spanish', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 12),
                Text(
                  coach.bio,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close modal
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreenDetail(
                          coachName: coach.name,
                          coachAvatar: coach.avatar,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09E),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Chat Now',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
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
                onTap: () => _showCoachDetailModal(coach),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(coach.avatar),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coach.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              coach.specialty,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ),
              );
            },
          ),
          // Tab 2: Messages
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recentChats.length,
            itemBuilder: (context, index) {
              final chat = recentChats[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreenDetail(
                        coachName: chat['name'] ?? 'Unknown',
                        coachAvatar: chat['avatar'] ?? '',
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(chat['avatar'] ?? ''),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat['name'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chat['message'] ?? '',
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        chat['time'] ?? '',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ),
              );
            },
          )

        ],
      ),
    );
  }
}
