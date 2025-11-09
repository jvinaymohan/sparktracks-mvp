import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../models/class_model.dart';
import '../services/ical_service.dart';
import '../utils/app_theme.dart';

/// Button widget to export class(es) to iCal format
class ICalExportButton extends StatelessWidget {
  final Class? singleClass;
  final List<Class>? multipleClasses;
  final String? coachName;
  final Map<String, String>? coachNames;
  final bool isIconButton;
  
  const ICalExportButton({
    super.key,
    this.singleClass,
    this.multipleClasses,
    this.coachName,
    this.coachNames,
    this.isIconButton = false,
  }) : assert(singleClass != null || multipleClasses != null, 'Must provide either singleClass or multipleClasses');

  @override
  Widget build(BuildContext context) {
    if (isIconButton) {
      return IconButton(
        icon: const Icon(Icons.calendar_month),
        tooltip: 'Add to Calendar',
        onPressed: () => _exportToICal(context),
      );
    }
    
    return OutlinedButton.icon(
      onPressed: () => _exportToICal(context),
      icon: const Icon(Icons.calendar_month),
      label: const Text('Add to Calendar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _exportToICal(BuildContext context) {
    try {
      String icalContent;
      String filename;
      
      if (singleClass != null) {
        // Export single class
        icalContent = ICalService.generateICalForClass(singleClass!, coachName: coachName);
        filename = ICalService.getFileName(singleClass!);
      } else {
        // Export multiple classes
        icalContent = ICalService.generateICalForClasses(
          multipleClasses!,
          coachNames: coachNames,
        );
        filename = ICalService.getFileNameForMultiple();
      }
      
      // Trigger download
      _downloadFile(icalContent, filename);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✅ Calendar file downloaded!'),
                    const SizedBox(height: 4),
                    Text(
                      'Open with Google Calendar, Apple Calendar, or Outlook',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting calendar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _downloadFile(String content, String filename) {
    // Create a Blob from the iCal content
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'text/calendar');
    
    // Create a download link and trigger it
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = filename;
    
    // Trigger download
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    // Clean up
    html.Url.revokeObjectUrl(url);
  }
}

/// Show dialog with calendar export options
class CalendarExportDialog extends StatelessWidget {
  final Class classItem;
  final String? coachName;
  
  const CalendarExportDialog({
    super.key,
    required this.classItem,
    this.coachName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_month, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('Add to Calendar'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Export this class to your calendar app:',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Google Calendar
          _buildCalendarOption(
            context,
            icon: Icons.calendar_today,
            label: 'Google Calendar',
            color: const Color(0xFF4285F4),
            onTap: () => _exportToGoogleCalendar(context),
          ),
          
          const SizedBox(height: 12),
          
          // Download iCal
          _buildCalendarOption(
            context,
            icon: Icons.download,
            label: 'Download iCal (.ics)',
            subtitle: 'Works with Apple Calendar, Outlook, etc.',
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.pop(context);
              ICalExportButton(
                singleClass: classItem,
                coachName: coachName,
              )._exportToICal(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildCalendarOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.neutral400),
          ],
        ),
      ),
    );
  }

  void _exportToGoogleCalendar(BuildContext context) {
    final startTime = classItem.startTime.toUtc();
    final endTime = classItem.endTime.toUtc();
    
    final title = Uri.encodeComponent(classItem.title);
    final description = Uri.encodeComponent(classItem.description);
    final location = classItem.location != null
        ? Uri.encodeComponent(classItem.location!)
        : '';
    
    final startStr = startTime.toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.')[0] + 'Z';
    final endStr = endTime.toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.')[0] + 'Z';
    
    final url = 'https://calendar.google.com/calendar/render?action=TEMPLATE'
        '&text=$title'
        '&dates=$startStr/$endStr'
        '&details=$description'
        '&location=$location'
        '&sf=true'
        '&output=xml';
    
    html.window.open(url, '_blank');
    Navigator.pop(context);
  }
}

