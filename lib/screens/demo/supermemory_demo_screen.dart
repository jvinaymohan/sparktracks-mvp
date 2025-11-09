import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/supermemory_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/app_memory_helper.dart';
import '../../utils/app_theme.dart';

/// Demo screen to test Supermemory AI integration
/// Access at: /supermemory-demo
class SupermemoryDemoScreen extends StatefulWidget {
  const SupermemoryDemoScreen({Key? key}) : super(key: key);

  @override
  State<SupermemoryDemoScreen> createState() => _SupermemoryDemoScreenState();
}

class _SupermemoryDemoScreenState extends State<SupermemoryDemoScreen> {
  final _queryController = TextEditingController();
  final _contentController = TextEditingController();
  
  List<String> _results = [];
  String? _insight;
  bool _isLoading = false;

  @override
  void dispose() {
    _queryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_queryController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _results = [];
    });

    final supermemoryProvider = Provider.of<SupermemoryProvider>(context, listen: false);
    
    try {
      final results = await supermemoryProvider.search(_queryController.text.trim());
      
      setState(() {
        _results = results.map((r) => '${r.content} (score: ${r.score.toStringAsFixed(2)})').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _results = ['Error: $e'];
        _isLoading = false;
      });
    }
  }

  Future<void> _addMemory() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 'demo_user';
    
    final supermemoryProvider = Provider.of<SupermemoryProvider>(context, listen: false);
    
    try {
      await supermemoryProvider.addMemory(
        content: _contentController.text.trim(),
        metadata: {
          'user_id': userId,
          'source': 'demo_screen',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Memory added successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _contentController.clear();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _getInsight() async {
    if (_queryController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _insight = null;
    });

    final supermemoryProvider = Provider.of<SupermemoryProvider>(context, listen: false);
    
    try {
      final insight = await supermemoryProvider.getInsights(_queryController.text.trim());
      
      setState(() {
        _insight = insight;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _insight = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testQuickScenario(String scenario) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 'demo_user';
    final supermemoryProvider = Provider.of<SupermemoryProvider>(context, listen: false);
    final helper = AppMemoryHelper(supermemoryProvider._service);

    setState(() => _isLoading = true);

    try {
      switch (scenario) {
        case 'track_browsing':
          await helper.trackClassBrowsing(
            userId: userId,
            category: 'Music',
            className: 'Piano Lessons for Beginners',
          );
          _showSuccess('Tracked class browsing!');
          break;

        case 'track_preference':
          await helper.trackPreference(
            userId: userId,
            preferenceType: 'class_time',
            preferenceValue: 'weekends_afternoon',
          );
          _showSuccess('Tracked preference!');
          break;

        case 'get_recommendations':
          final recommendations = await helper.getClassRecommendations(userId);
          _showInsightDialog('Class Recommendations', recommendations ?? 'No recommendations yet. Track some activities first!');
          break;

        case 'get_usage':
          final usage = await helper.getUsageInsights(userId);
          _showInsightDialog('Usage Insights', usage ?? 'No usage data yet. Track some activities first!');
          break;
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showInsightDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.accentColor),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Supermemory AI Demo'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Supermemory AI Integration',
              style: AppTheme.headline3,
            ),
            const SizedBox(height: 8),
            Text(
              'Test AI-powered memory and recommendations',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 32),

            // Quick Test Scenarios
            Text('Quick Test Scenarios', style: AppTheme.headline5),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _testQuickScenario('track_browsing'),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Track Class Browsing'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _testQuickScenario('track_preference'),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Track Preference'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _testQuickScenario('get_recommendations'),
                  icon: const Icon(Icons.recommend),
                  label: const Text('Get Recommendations'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _testQuickScenario('get_usage'),
                  icon: const Icon(Icons.analytics),
                  label: const Text('Get Usage Insights'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),

            // Add Memory Section
            Text('Add Memory', style: AppTheme.headline5),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Memory Content',
                hintText: 'Enter information to remember...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addMemory,
              icon: const Icon(Icons.add),
              label: const Text('Add to Memory'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 32),

            // Search Section
            Text('Search Memory', style: AppTheme.headline5),
            const SizedBox(height: 16),
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                labelText: 'Search Query',
                hintText: 'What do you know about me?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _search,
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getInsight,
                    icon: const Icon(Icons.lightbulb),
                    label: const Text('Get AI Insight'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Loading Indicator
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),
            ],

            // Results Section
            if (_results.isNotEmpty) ...[
              Text('Search Results', style: AppTheme.headline5),
              const SizedBox(height: 16),
              ...List.generate(_results.length, (index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(_results[index]),
                  ),
                );
              }),
            ],

            // Insight Section
            if (_insight != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor.withValues(alpha: 0.1),
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.accentColor),
                        const SizedBox(width: 8),
                        Text('AI Insight', style: AppTheme.headline6),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_insight!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

