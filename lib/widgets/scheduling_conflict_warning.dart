import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_model.dart';
import '../services/scheduling_service.dart';
import '../utils/app_theme.dart';

/// Warning widget to show scheduling conflicts
class SchedulingConflictWarning extends StatelessWidget {
  final List<Class> conflicts;
  final int bufferMinutes;
  final DateTime? suggestedTime;
  
  const SchedulingConflictWarning({
    super.key,
    required this.conflicts,
    this.bufferMinutes = 15,
    this.suggestedTime,
  });

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Conflicts!',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                    ),
                  ),
                  Text(
                    'This time slot is available (including $bufferMinutes min buffer)',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Conflict Detected!',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This time overlaps with ${conflicts.length} existing ${conflicts.length == 1 ? 'class' : 'classes'} (including $bufferMinutes min buffer time)',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          ...conflicts.map((conflict) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.class_, color: AppTheme.errorColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conflict.title,
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${DateFormat('h:mm a').format(conflict.startTime)} - ${DateFormat('h:mm a').format(conflict.endTime)}',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          if (suggestedTime != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppTheme.infoColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Suggested: ${DateFormat('h:mm a').format(suggestedTime!)}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.infoColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Buffer time selector widget
class BufferTimeSelector extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onChanged;
  
  const BufferTimeSelector({
    super.key,
    required this.selectedMinutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Buffer Time Between Classes',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Recommended time before/after class for preparation',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
        ),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('None')),
            ButtonSegment(value: 15, label: Text('15 min')),
            ButtonSegment(value: 30, label: Text('30 min')),
            ButtonSegment(value: 45, label: Text('45 min')),
          ],
          selected: {selectedMinutes},
          onSelectionChanged: (Set<int> newSelection) {
            onChanged(newSelection.first);
          },
        ),
      ],
    );
  }
}

