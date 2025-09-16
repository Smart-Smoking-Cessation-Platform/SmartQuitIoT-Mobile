import 'package:flutter/material.dart';

class CreateNewPostPage extends StatefulWidget {
  @override
  _CreateNewPostPageState createState() => _CreateNewPostPageState();
}

class _CreateNewPostPageState extends State<CreateNewPostPage> {
  String selectedCategory = '';

  final List<Map<String, dynamic>> categories = [
    {'title': 'Wellness', 'color': Colors.pink[100], 'icon': '🧘'},
    {'title': 'Healthcare', 'color': Colors.blue[100], 'icon': '⚕️'},
    {'title': 'Diet', 'color': Colors.orange[100], 'icon': '🥗'},
    {'title': 'Fitness', 'color': Color(0xFF00D09E)[100], 'icon': '💪'},
    {'title': 'Nutrition', 'color': Colors.purple[100], 'icon': '🥑'},
    {'title': 'Mindful', 'color': Colors.cyan[100], 'icon': '🧠'},
    {'title': 'Sleep', 'color': Colors.yellow[100], 'icon': '😴'},
    {'title': 'HealthTech', 'color': Colors.grey[100], 'icon': '📱'},
    {'title': 'Other', 'color': Colors.grey[50], 'icon': '⚪'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Community Post',
                      style: TextStyle(
                        color: Color(0xFF4A90E2),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Create New Post',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select post category',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 32),

                    // Categories Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected =
                            selectedCategory == category['title'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category['title'];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF4A90E2).withOpacity(0.1)
                                  : category['color'],
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(
                                      color: Color(0xFF4A90E2),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category['icon'],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  category['title'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedCategory.isNotEmpty
                      ? () {
                          // Navigate to next page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostContentPage(category: selectedCategory),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory.isNotEmpty
                        ? Color(0xFF4A90E2)
                        : Colors.grey[300],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          color: selectedCategory.isNotEmpty
                              ? Colors.white
                              : Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: selectedCategory.isNotEmpty
                            ? Colors.white
                            : Colors.grey[600],
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Import this class in the third file
class PostContentPage extends StatefulWidget {
  final String category;

  const PostContentPage({Key? key, required this.category}) : super(key: key);

  @override
  _PostContentPageState createState() => _PostContentPageState();
}

class _PostContentPageState extends State<PostContentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post Content - ${widget.category}')),
      body: Center(
        child: Text(
          'Write your post about ${widget.category} here...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
