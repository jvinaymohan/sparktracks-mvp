import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

/// Screen for coaches to manage (approve/reject) reviews
class ManageReviewsScreen extends StatefulWidget {
  const ManageReviewsScreen({super.key});

  @override
  State<ManageReviewsScreen> createState() => _ManageReviewsScreenState();
}

class _ManageReviewsScreenState extends State<ManageReviewsScreen> {
  String _filter = 'pending'; // pending, approved, rejected, all

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coachId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Reviews'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('Pending', 'pending'),
                _buildFilterChip('Approved', 'approved'),
                _buildFilterChip('Rejected', 'rejected'),
                _buildFilterChip('All', 'all'),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getReviewsStream(coachId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final reviews = snapshot.data!.docs
              .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _filter = value);
          }
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Stream<QuerySnapshot> _getReviewsStream(String coachId) {
    var query = FirebaseFirestore.instance
        .collection('reviews')
        .where('coachId', isEqualTo: coachId);

    if (_filter != 'all') {
      query = query.where('status', isEqualTo: _filter);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Widget _buildReviewCard(Review review) {
    final statusColor = review.status == ReviewStatus.approved
        ? AppTheme.successColor
        : review.status == ReviewStatus.rejected
            ? AppTheme.errorColor
            : AppTheme.warningColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    review.parentName[0].toUpperCase(),
                    style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.parentName, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        DateFormat('MMM d, y').format(review.createdAt),
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    review.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  Icon(
                    i <= review.rating ? Icons.star : Icons.star_outline,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  '${review.rating.toStringAsFixed(1)} / 5.0',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            if (review.className != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'For: ${review.className}',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.infoColor),
                ),
              ),
            ],

            if (review.comment != null) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: AppTheme.bodyMedium,
              ),
            ],

            if (review.isVerified) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.verified, color: AppTheme.successColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Verified Parent',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.successColor),
                  ),
                ],
              ),
            ],

            // Actions (only for pending reviews)
            if (review.status == ReviewStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectReview(review),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: BorderSide(color: AppTheme.errorColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveReview(review),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _approveReview(Review review) async {
    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(review.id)
          .update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Review approved!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Review?'),
        content: const Text(
          'This review will be marked as rejected and won\'t appear on your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(review.id)
          .update({'status': 'rejected'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    final message = _filter == 'pending'
        ? 'No pending reviews'
        : _filter == 'approved'
            ? 'No approved reviews yet'
            : _filter == 'rejected'
                ? 'No rejected reviews'
                : 'No reviews yet';

    final subtitle = _filter == 'pending'
        ? 'New reviews will appear here for approval'
        : 'Reviews will appear here once submitted';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: AppTheme.neutral400),
          const SizedBox(height: 16),
          Text(message, style: AppTheme.headline6),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

