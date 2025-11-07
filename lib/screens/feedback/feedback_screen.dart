import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  FeedbackCategory _selectedCategory = FeedbackCategory.general;
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Dashboard',
          onPressed: () => NavigationHelper.goToDashboard(context),
        ),
        actions: [
          NavigationHelper.buildGradientHomeButton(context),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Your Feedback',
                      style: AppTheme.headline4.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Help us improve SparkTracks for you and your family',
                      style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // User Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          user?.name[0] ?? 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: AppTheme.headline6,
                            ),
                            Text(
                              user?.email ?? '',
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                            ),
                            Text(
                              '${user?.type.name.toUpperCase()} Account',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Rating Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Rating',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = index + 1;
                              });
                            },
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: AppTheme.warningColor,
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        _getRatingText(_rating),
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Category Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      DropdownButtonFormField<FeedbackCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select a category',
                        ),
                        items: FeedbackCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryDisplayName(category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Title Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Brief title for your feedback',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Description Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description (Optional)',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Tell us more about your experience (optional)...',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: AppTheme.spacingM),
                            Text('Submitting...'),
                          ],
                        )
                      : const Text('Submit Feedback'),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Recent Feedback
              Text(
                'Recent Feedback',
                style: AppTheme.headline6,
              ),
              const SizedBox(height: AppTheme.spacingM),
              ..._buildRecentFeedbackList(),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor - We need to improve significantly';
      case 2:
        return 'Fair - There\'s room for improvement';
      case 3:
        return 'Good - It meets expectations';
      case 4:
        return 'Very Good - Exceeds expectations';
      case 5:
        return 'Excellent - Outstanding experience';
      default:
        return '';
    }
  }

  String _getCategoryDisplayName(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.general:
        return 'General Feedback';
      case FeedbackCategory.bug:
        return 'Bug Report';
      case FeedbackCategory.feature:
        return 'Feature Request';
      case FeedbackCategory.ui:
        return 'User Interface';
      case FeedbackCategory.performance:
        return 'Performance';
      case FeedbackCategory.support:
        return 'Customer Support';
    }
  }

  List<Widget> _buildRecentFeedbackList() {
    final recentFeedback = [
      FeedbackItem(
        title: 'Great app for managing kids\' activities',
        category: FeedbackCategory.general,
        rating: 5,
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: FeedbackStatus.reviewed,
      ),
      FeedbackItem(
        title: 'Calendar view could be improved',
        category: FeedbackCategory.ui,
        rating: 4,
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: FeedbackStatus.inProgress,
      ),
      FeedbackItem(
        title: 'Task completion photos not uploading',
        category: FeedbackCategory.bug,
        rating: 2,
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: FeedbackStatus.resolved,
      ),
    ];

    return recentFeedback.map((feedback) => Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(feedback.status),
          child: Icon(
            _getStatusIcon(feedback.status),
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(feedback.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getCategoryDisplayName(feedback.category)),
            Row(
              children: [
                ...List.generate(5, (index) => Icon(
                  index < feedback.rating ? Icons.star : Icons.star_border,
                  color: AppTheme.warningColor,
                  size: 16,
                )),
                const SizedBox(width: 8),
                Text(
                  _formatDate(feedback.date),
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          _getStatusText(feedback.status),
          style: AppTheme.bodySmall.copyWith(
            color: _getStatusColor(feedback.status),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    )).toList();
  }

  Color _getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return AppTheme.warningColor;
      case FeedbackStatus.reviewed:
        return AppTheme.infoColor;
      case FeedbackStatus.inProgress:
        return AppTheme.primaryColor;
      case FeedbackStatus.resolved:
        return AppTheme.successColor;
    }
  }

  IconData _getStatusIcon(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return Icons.pending;
      case FeedbackStatus.reviewed:
        return Icons.visibility;
      case FeedbackStatus.inProgress:
        return Icons.work;
      case FeedbackStatus.resolved:
        return Icons.check;
    }
  }

  String _getStatusText(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return 'Pending';
      case FeedbackStatus.reviewed:
        return 'Reviewed';
      case FeedbackStatus.inProgress:
        return 'In Progress';
      case FeedbackStatus.resolved:
        return 'Resolved';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.currentUser;
        
        if (user == null) {
          throw Exception('User not logged in');
        }

        // Create feedback submission
        final feedbackId = 'feedback_${DateTime.now().millisecondsSinceEpoch}';
        final feedback = {
          'id': feedbackId,
          'userId': user.id,
          'userName': user.name,
          'userEmail': user.email,
          'userType': user.type.toString().split('.').last,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          'category': _selectedCategory.toString().split('.').last,
          'rating': _rating,
          'status': 'pending',
          'submittedAt': FieldValue.serverTimestamp(),
          'metadata': {},
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('feedback')
            .doc(feedbackId)
            .set(feedback);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your feedback! We\'ll review it soon.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Clear form
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _rating = 5;
            _selectedCategory = FeedbackCategory.general;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting feedback: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}

enum FeedbackCategory {
  general,
  bug,
  feature,
  ui,
  performance,
  support,
}

enum FeedbackStatus {
  pending,
  reviewed,
  inProgress,
  resolved,
}

class FeedbackItem {
  final String title;
  final FeedbackCategory category;
  final int rating;
  final DateTime date;
  final FeedbackStatus status;

  FeedbackItem({
    required this.title,
    required this.category,
    required this.rating,
    required this.date,
    required this.status,
  });
}
