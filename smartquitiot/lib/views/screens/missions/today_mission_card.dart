import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../repositories/auth_repository.dart';
import '../quitplans/quit_plan_screen.dart';

class Mission {
  final String title;
  final String description;
  final IconData icon;

  Mission({
    required this.title,
    required this.description,
    this.icon = Icons.self_improvement,
  });
}

class TodayMissionCard extends StatefulWidget {
  const TodayMissionCard({super.key});

  @override
  State<TodayMissionCard> createState() => _TodayMissionCardState();
}

class _TodayMissionCardState extends State<TodayMissionCard> {
  List<Mission> missions = [];
  bool isLoading = true;
  String? error;

  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    fetchMissions();
  }

  Future<void> fetchMissions() async {
    final url = dotenv.env['API_QUIT_PLAN_URL'];
    if (url == null) {
      setState(() {
        error = "API_QUIT_PLAN_URL not set in .env";
        isLoading = false;
      });
      return;
    }

    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        setState(() {
          error = "No access token found";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final phases = data['phases'] as List;
        if (phases.isEmpty) {
          setState(() {
            error = "No phases found in quit plan";
            isLoading = false;
          });
          return;
        }

        final firstPhase = phases.first;
        final firstDay = firstPhase['details'].first;
        final missionsJson = firstDay['missions'] as List;

        final fetchedMissions = missionsJson.map((m) {
          return Mission(
            title: m['name'] ?? '',
            description: m['description'] ?? '',
            icon: Icons.self_improvement,
          );
        }).toList();

        setState(() {
          missions = fetchedMissions;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load missions: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null)
      return Text('Error: $error', style: const TextStyle(color: Colors.red));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today Missions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuitPlanScreen()),
                    );
                  },
                  child: const Text(
                    'View More',
                    style: TextStyle(
                      color: Color(0xFF00D09E),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Column(
            children: missions.map((mission) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuitPlanScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09E),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          mission.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mission.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mission.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
