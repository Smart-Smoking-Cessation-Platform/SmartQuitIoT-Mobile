import 'package:flutter/material.dart';
import '../widgets/filter_posts_modal.dart'; // import file FilterPostsModal.dart của bạn

void main() {
  runApp(MaterialApp(home: CommunityPage()));
}

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String selectedCategory = 'Wellness';
  Map<String, dynamic>? currentFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1FFF3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  // Profile Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/200/200',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Dokomon Senee',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              ],
                            ),
                            Text(
                              '35 2 hours  🏆 18  📈 91%',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Browse By Section
                  Row(
                    children: [
                      Text(
                        'Browse By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: _openFilterModal,
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Trending',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Category Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryTabWithModal('🧘', 'Wellness'),
                        SizedBox(width: 12),
                        _buildCategoryTabWithModal('💪', 'Health'),
                        SizedBox(width: 12),
                        _buildCategoryTabWithModal('🧠', 'Mindfulness'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Posts List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildPost(
                    username: 'Dokomon Senee',
                    avatarUrl: 'https://picsum.photos/100/100?1',
                    isVerified: true,
                    timeAgo: '2 hours',
                    content:
                        'Shot Fat HIIT METHOD workout is another excellent way to burn calories and accelerate fat-burning process! #HitWorkout #BurnMoreCals',
                    imageUrl: 'https://picsum.photos/400/200?1',
                    likes: '1.5K',
                    comments: '215',
                    shares: '3',
                  ),
                  _buildPost(
                    username: 'Dokomon Senee',
                    avatarUrl: 'https://picsum.photos/100/100?2',
                    isVerified: true,
                    timeAgo: '5 hours',
                    content:
                        'HIIT x LIFTING! Absolutely part this because of its effectiveness and most it got two training time! This saved it a lot TIME! 🔥 #GoodWorkout',
                    imageUrl: null,
                    likes: '1.5K',
                    comments: '215',
                    shares: '3',
                  ),
                  _buildPost(
                    username: 'Dokomon Senee',
                    avatarUrl: 'https://picsum.photos/100/100?5',
                    isVerified: true,
                    timeAgo: '3 hours',
                    content: 'Check out this workout video! 🔥 #HIIT #FullBody',
                    imageUrl:
                        'https://picsum.photos/400/200?video', // dùng ảnh đại diện video
                    hasVideo: true, // bật icon play
                    likes: '2K',
                    comments: '120',
                    shares: '10',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Category tab with modal ---
  Widget _buildCategoryTabWithModal(String emoji, String title) {
    bool isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() => selectedCategory = title);
        _openFilterModal();
      },
      child: _buildCategoryTab(emoji, title, isSelected),
    );
  }

  Widget _buildCategoryTab(String emoji, String title, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF00D09E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- Open Filter Modal ---
  void _openFilterModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => FilterPostsModal(
          controller: controller,
          currentFilter: currentFilter,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        currentFilter = result;
        selectedCategory = result['category'];
        // postType, videoLength có thể dùng để lọc posts
      });
    }
  }

  // --- Post widget ---
  Widget _buildPost({
    required String username,
    required String avatarUrl,
    required bool isVerified,
    required String timeAgo,
    required String content,
    String? imageUrl,
    bool hasVideo = false,
    required String likes,
    required String comments,
    required String shares,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        if (isVerified) ...[
                          SizedBox(width: 4),
                          Icon(Icons.verified, color: Colors.blue, size: 14),
                        ],
                      ],
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
          if (imageUrl != null) ...[
            SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (hasVideo)
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          SizedBox(height: 16),
          Row(
            children: [
              _buildActionButton(Icons.favorite_border, likes),
              SizedBox(width: 20),
              _buildActionButton(Icons.chat_bubble_outline, comments),
              SizedBox(width: 20),
              _buildActionButton(Icons.share_outlined, shares),
              Spacer(),
              _buildActionButton(Icons.bookmark_border, ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        if (count.isNotEmpty) ...[
          SizedBox(width: 4),
          Text(count, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ],
    );
  }
}
