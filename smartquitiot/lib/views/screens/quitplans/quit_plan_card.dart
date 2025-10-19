import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../repositories/auth_repository.dart';

class QuitPlanCard extends StatefulWidget {
  const QuitPlanCard({super.key});

  @override
  State<QuitPlanCard> createState() => _QuitPlanCardState();
}

class _QuitPlanCardState extends State<QuitPlanCard> {
  double progress = 0.0;
  String stage = "";
  List<String> steps = [];
  bool isLoading = true;
  String? error;

  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    fetchQuitPlan();
  }

  Future<void> fetchQuitPlan() async {
    final url = dotenv.env['API_QUIT_PLAN_URL'];
    if (url == null) {
      setState(() {
        error = "API_QUIT_PLAN_URL not set";
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

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final phases = data['phases'] as List;

        final phaseNames = phases
            .map<String>((p) => p['name'] as String)
            .toList();

        final currentPhase = phases.firstWhere(
          (p) => (p['progress'] ?? 0) < 100,
          orElse: () => phases.last,
        );

        setState(() {
          progress = (currentPhase['progress'] ?? 0) / 100.0;
          stage = currentPhase['name'] ?? "";
          steps = phaseNames;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load quit plan: ${res.statusCode}";
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

    final int percent = (progress * 100).round();
    const Color progressColorStart = Color(0xFF00D09E);
    const Color progressColorEnd = Color(0xFF3FCF8E);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smoke_free,
                  color: Color(0xFF00D09E),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Quit Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF00D09E,
                  ), // background xanh lá
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text(
                  'View More',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // chữ trắng
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current stage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 16, color: Color(0xFF00D09E)),
                const SizedBox(width: 6),
                Text(
                  stage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D09E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFF1FFF3), // background bar
              borderRadius: BorderRadius.circular(6),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth * progress;
                return Stack(
                  children: [
                    // Foreground bar: màu xanh
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: barWidth,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D09E), Color(0xFF3FCF8E)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Optional: thêm Text % trên thanh progress
                    Positioned(
                      left: (barWidth - 20).clamp(0, constraints.maxWidth - 30),
                      top: -18,
                      child: Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D09E),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFF1FFF3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth * progress;
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: barWidth,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [progressColorStart, progressColorEnd],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Steps labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map((step) {
              final int stepIndex = steps.indexOf(step);
              final bool completed =
                  stepIndex < steps.indexOf(stage) || progress >= 1.0;
              final bool isCurrentStage = step == stage;

              return Column(
                children: [
                  Icon(
                    completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCurrentStage
                        ? const Color(0xFF00D09E) // green for current stage
                        : (completed
                              ? const Color(0xFF00D09E)
                              : Colors.grey[300]),
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step,
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentStage
                          ? const Color(0xFF00D09E)
                          : (completed ? Colors.black87 : Colors.grey),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
