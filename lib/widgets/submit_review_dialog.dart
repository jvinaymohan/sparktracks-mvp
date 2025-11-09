import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/review_model.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

/// Dialog for parents to submit reviews for coaches
class SubmitReviewDialog extends StatefulWidget {
  final String coachId;
  final String coachName;
  final String? classId;
  final String? className;
  
  const SubmitReviewDialog({
    super.key,
    required this.coachId,
    required this.coachName,
    this.classId,
    this.className,
  });

  @override
  State<SubmitReviewDialog> createState() => _SubmitReviewDialogState();
}

class _SubmitReviewDialogState extends State<SubmitReviewDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to submit a review')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reviewId = FirebaseFirestore.instance.collection('reviews').doc().id;
      
      final review = Review(
        id: reviewId,
        coachId: widget.coachId,
        parentId: currentUser.id,
        parentName: currentUser.name,
        classId: widget.classId,
        className: widget.className,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
        createdAt: DateTime.now(),
        status: ReviewStatus.pending,
        isVerified: true, // TODO: Check if parent actually enrolled
      );

      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .set(review.toJson());

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('✅ Review submitted! Waiting for coach approval.'),
                ),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star_rounded, color: AppTheme.accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Review ${widget.coachName}',
                  style: AppTheme.headline6,
                ),
              ),
            ],
          ),
          if (widget.className != null) ...[
            const SizedBox(height: 8),
            Text(
              'For: ${widget.className}',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
            ),
          ],
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Stars
            Text('Your Rating', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(
                      i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 40,
                    ),
                    color: AppTheme.accentColor,
                    onPressed: () => setState(() => _rating = i.toDouble()),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _getRatingText(_rating),
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Comment
            Text('Your Review (Optional)', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your experience with ${widget.coachName}...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppTheme.neutral100,
              ),
            ),
            const SizedBox(height: 16),
            
            // Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your review will be visible after coach approval',
                      style: AppTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitReview,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send),
          label: Text(_isSubmitting ? 'Submitting...' : 'Submit Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return '⭐ Excellent!';
    if (rating >= 4) return '⭐ Great!';
    if (rating >= 3) return '⭐ Good';
    if (rating >= 2) return '⭐ Fair';
    return '⭐ Needs Improvement';
  }
}

