import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../services/csv_export_service.dart';
import '../utils/app_theme.dart';

/// Reusable CSV export button widget
class CsvExportButton extends StatefulWidget {
  final Future<String> Function() generateCsv;
  final String fileName;
  final String label;
  final IconData icon;
  final bool isIconButton;

  const CsvExportButton({
    Key? key,
    required this.generateCsv,
    required this.fileName,
    this.label = 'Export CSV',
    this.icon = Icons.download,
    this.isIconButton = false,
  }) : super(key: key);

  @override
  State<CsvExportButton> createState() => _CsvExportButtonState();
}

class _CsvExportButtonState extends State<CsvExportButton> {
  bool _isExporting = false;

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);

    try {
      final csvContent = await widget.generateCsv();
      final csvService = CsvExportService();
      
      // Create data URI
      final dataUri = csvService.createCsvDataUri(csvContent);
      
      // Trigger download
      final anchor = html.AnchorElement(href: dataUri)
        ..setAttribute('download', widget.fileName)
        ..click();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('✅ ${widget.fileName} downloaded successfully!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isIconButton) {
      return IconButton(
        onPressed: _isExporting ? null : _exportCsv,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(widget.icon),
        tooltip: widget.label,
      );
    }

    return ElevatedButton.icon(
      onPressed: _isExporting ? null : _exportCsv,
      icon: _isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(widget.icon),
      label: Text(widget.label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Show export options dialog
Future<void> showExportOptionsDialog({
  required BuildContext context,
  required List<ExportOption> options,
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.file_download, color: AppTheme.primaryColor),
          SizedBox(width: 12),
          Text('Export Data'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: options.map((option) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(option.icon, color: AppTheme.primaryColor),
                title: Text(option.title),
                subtitle: Text(option.description),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _performExport(context, option);
                },
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

Future<void> _performExport(BuildContext context, ExportOption option) async {
  try {
    final csvContent = await option.generateCsv();
    final csvService = CsvExportService();
    
    // Create data URI
    final dataUri = csvService.createCsvDataUri(csvContent);
    
    // Trigger download
    final anchor = html.AnchorElement(href: dataUri)
      ..setAttribute('download', option.fileName)
      ..click();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('✅ ${option.fileName} downloaded!'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}

class ExportOption {
  final String title;
  final String description;
  final IconData icon;
  final String fileName;
  final Future<String> Function() generateCsv;

  ExportOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.fileName,
    required this.generateCsv,
  });
}

