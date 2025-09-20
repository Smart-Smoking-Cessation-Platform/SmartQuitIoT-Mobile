// views/screens/api_demo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/user_profile_view_model.dart';

class ApiDemoScreen extends ConsumerStatefulWidget {
  const ApiDemoScreen({super.key});

  @override
  ConsumerState<ApiDemoScreen> createState() => _ApiDemoScreenState();
}

class _ApiDemoScreenState extends ConsumerState<ApiDemoScreen> {
  final String _userId = 'demo_user_123';

  @override
  void initState() {
    super.initState();
    // Load user profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileViewModelProvider.notifier).loadUserProfile(_userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = ref.watch(userProfileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Demo - Riverpod Flow'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SmartQuitIoT - API Integration Demo',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This screen demonstrates the MVVM architecture with Riverpod state management and API integration.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: userProfileState.isLoading ? null : () {
                      ref.read(userProfileViewModelProvider.notifier)
                          .loadUserProfile(_userId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: userProfileState.isLoading ? null : () {
                      ref.read(userProfileViewModelProvider.notifier)
                          .loadUserStatistics(_userId);
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('Load Stats'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Loading Indicator
            if (userProfileState.isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading data from API...'),
                  ],
                ),
              ),
            
            // Error Display
            if (userProfileState.error != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Error',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            Text(
                              userProfileState.error!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(userProfileViewModelProvider.notifier)
                              .clearError();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            
            // User Profile Display
            if (userProfileState.profile != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileRow('Name', userProfileState.profile!.name),
                      _buildProfileRow('Email', userProfileState.profile!.email),
                      _buildProfileRow('Smoke-free Days', 
                          '${userProfileState.profile!.smokeFreeDays} days'),
                      _buildProfileRow('Cigarettes Avoided', 
                          '${userProfileState.profile!.cigarettesAvoided}'),
                      _buildProfileRow('Money Saved', 
                          '\$${userProfileState.profile!.moneySaved.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            
            // Statistics Display
            if (userProfileState.statistics != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('Total Days', 
                          '${userProfileState.statistics!['totalDays']}'),
                      _buildStatRow('Health Score', 
                          '${userProfileState.statistics!['healthScore']}/100'),
                      _buildStatRow('Last Updated', 
                          _formatDate(userProfileState.statistics!['lastUpdated'])),
                    ],
                  ),
                ),
              ),
            
            const Spacer(),
            
            // Architecture Info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Architecture Flow',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. View (Screen) → 2. ViewModel (Riverpod) → 3. Service (API) → 4. Model (Data)',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'State management handled by Riverpod with proper error handling and loading states.',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
