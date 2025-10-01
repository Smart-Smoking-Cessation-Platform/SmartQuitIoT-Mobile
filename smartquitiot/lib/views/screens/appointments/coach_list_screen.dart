// lib/features/coaching/screens/coach_list_screen.dart
import 'package:SmartQuitIoT/views/screens/appointments/coach_rating_screen.dart';
import 'package:flutter/material.dart';
import 'coach_detail_screen.dart';
import 'coach_list_items.dart';

class CoachListScreen extends StatelessWidget {
  CoachListScreen({Key? key}) : super(key: key);

  final List<Coach> coaches = [
    Coach(
      id: '1',
      name: 'Nguyen Van An',
      specialty: 'Psychology Expert',
      rating: 4.9,
      reviews: 127,
      experience: '8 years of experience',
      imageUrl: 'https://i.pravatar.cc/150?img=12',
      bio: 'Psychology expert with more than 8 years of experience helping hundreds of people quit smoking successfully.',
    ),
    Coach(
      id: '2',
      name: 'Tran Thi Binh',
      specialty: 'Health Coach',
      rating: 4.8,
      reviews: 98,
      experience: '6 years of experience',
      imageUrl: 'https://i.pravatar.cc/150?img=47',
      bio: 'Health coach specializing in nutrition and healthy lifestyle.',
    ),
    Coach(
      id: '3',
      name: 'Le Minh Chau',
      specialty: 'Addiction Specialist',
      rating: 5.0,
      reviews: 203,
      experience: '10 years of experience',
      imageUrl: 'https://i.pravatar.cc/150?img=32',
      bio: 'Leading expert in smoking cessation with modern treatment methods.',
    ),
    Coach(
      id: '4',
      name: 'Pham Hoang Duy',
      specialty: 'Behavior Consultant',
      rating: 4.7,
      reviews: 85,
      experience: '5 years of experience',
      imageUrl: 'https://i.pravatar.cc/150?img=51',
      bio: 'Behavior consultant helping people change negative habits.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFF7E2), // ✅ background xanh nhạt
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00D09E),
        centerTitle: true,
        title: const Text(
          'Choose a Coach',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: coaches.length,
        itemBuilder: (context, index) {
          final coach = coaches[index];
          return CoachListItem(
            coach: coach,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoachDetailScreen(coach: coach),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
