import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../widgets/review_submission_dialog.dart';

class CoachReviewsSection extends StatefulWidget {
  final String coachId;
  final String coachName;

  const CoachReviewsSection({
    Key? key,
    required this.coachId,
    required this.coachName,
  }) : super(key: key);

  @override
  State<CoachReviewsSection> createState() => _CoachReviewsSectionState();
}

class _CoachReviewsSectionState extends State<CoachReviewsSection> {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Review> _reviews = [];
  CoachRatingStats? _ratingStats;
  Review? _userReview;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reviews = await _firestoreService.getCoachReviews(widget.coachId);
      final stats = await _firestoreService.getCoachRatingStats(widget.coachId);

      // Check if current user has reviewed this coach
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Review? userReview;
      if (authProvider.isLoggedIn && authProvider.currentUser?.type == UserType.parent) {
        userReview = await _firestoreService.getParentReviewForCoach(
          authProvider.currentUser!.id,
          widget.coachId,
        );
      }

      setState(() {
        _reviews = reviews;
        _ratingStats = stats;
        _userReview = userReview;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showReviewDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReviewSubmissionDialog(
        coachId: widget.coachId,
        coachName: widget.coachName,
        existingReview: _userReview,
      ),
    );

    if (result == true) {
      _loadReviews(); // Refresh reviews after submission
    }
  }

  Future<void> _deleteReview() async {
    if (_userReview == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete your review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteReview(_userReview!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Review deleted'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          _loadReviews();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting review: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text('Error loading reviews: $_error', style: AppTheme.bodyMedium),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final canReview = authProvider.isLoggedIn && authProvider.currentUser?.type == UserType.parent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating Summary
        _buildRatingSummary(),
        const SizedBox(height: 24),
        
        // Write Review Button
        if (canReview) ...[
          _buildReviewButton(),
          const SizedBox(height: 24),
        ],
        
        // Reviews List
        if (_reviews.isEmpty)
          _buildNoReviews()
        else
          _buildReviewsList(),
      ],
    );
  }

  Widget _buildRatingSummary() {
    if (_ratingStats == null || _ratingStats!.totalReviews == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.neutral100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.star_border, size: 48, color: AppTheme.neutral400),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No Reviews Yet', style: AppTheme.headline6),
                  const SizedBox(height: 4),
                  Text('Be the first to review this coach!', style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Average Rating
          Column(
            children: [
              Text(
                _ratingStats!.displayRating,
                style: AppTheme.headline3.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  final averageRating = _ratingStats!.averageRating;
                  return Icon(
                    starValue <= averageRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '${_ratingStats!.totalReviews} ${_ratingStats!.totalReviews == 1 ? 'review' : 'reviews'}',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(width: 32),
          
          // Rating Distribution
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                final count = _ratingStats!.ratingDistribution[stars] ?? 0;
                final percentage = _ratingStats!.totalReviews > 0
                    ? (count / _ratingStats!.totalReviews)
                    : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$stars', style: AppTheme.bodySmall),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppTheme.neutral200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$count',
                          style: AppTheme.bodySmall,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton() {
    if (_userReview != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showReviewDialog,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Your Review'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _deleteReview,
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.errorColor,
            tooltip: 'Delete Review',
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: _showReviewDialog,
      icon: const Icon(Icons.rate_review),
      label: const Text('Write a Review'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildNoReviews() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.reviews_outlined, size: 64, color: AppTheme.neutral400),
            const SizedBox(height: 16),
            Text('No reviews yet', style: AppTheme.headline6),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your experience!',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                review.parentName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.parentName, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        final starValue = index + 1;
                        return Icon(
                          starValue <= review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(review.createdAt),
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(review.comment!, style: AppTheme.bodyMedium),
        ],
        if (review.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: review.tags.map((tag) {
              return Chip(
                label: Text(tag, style: AppTheme.bodySmall),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}

