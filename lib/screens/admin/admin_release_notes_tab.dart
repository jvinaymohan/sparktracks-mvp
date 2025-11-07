import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';

class AdminReleaseNotesTab extends StatefulWidget {
  const AdminReleaseNotesTab({super.key});

  @override
  State<AdminReleaseNotesTab> createState() => _AdminReleaseNotesTabState();
}

class _AdminReleaseNotesTabState extends State<AdminReleaseNotesTab> {
  @override
  void initState() {
    super.initState();
    _ensureReleaseNotesExist();
  }

  Future<void> _ensureReleaseNotesExist() async {
    // Check if release notes exist, if not, create initial ones
    final snapshot = await FirebaseFirestore.instance.collection('releaseNotes').limit(1).get();
    
    if (snapshot.docs.isEmpty) {
      await _createInitialReleaseNotes();
    }
  }

  Future<void> _createInitialReleaseNotes() async {
    final batch = FirebaseFirestore.instance.batch();
    
    // v2.5.3 - Current Release
    batch.set(
      FirebaseFirestore.instance.collection('releaseNotes').doc('v2.5.3'),
      {
        'version': 'v2.5.3',
        'releaseDate': DateTime(2025, 11, 5, 4, 30),
        'title': 'Navigation & Recurring Tasks Update',
        'description': 'Major UX improvements, recurring tasks, and product management tools',
        'features': [
          'Universal navigation with gradient home buttons',
          'Recurring tasks in quick dialog (Daily/Weekly/Monthly)',
          'Custom credentials for child creation',
          'Parent name in dashboard header',
          'Product roadmap Kanban board for admins',
          'Smart delete foundation for recurring tasks',
        ],
        'fixes': [
          'CRITICAL: Child task isolation (no cross-child data)',
          'Notification settings navigation',
          'Firestore permission errors resolved',
          'Navigation consistency across all user types',
        ],
        'security': [
          'Firestore rules balanced for functionality',
          'Task isolation per child enforced',
        ],
      },
    );

    // v2.5.0 - Privacy & Security Release
    batch.set(
      FirebaseFirestore.instance.collection('releaseNotes').doc('v2.5.0'),
      {
        'version': 'v2.5.0',
        'releaseDate': DateTime(2025, 11, 5, 3, 30),
        'title': 'Critical Privacy & Security Update',
        'description': 'Enterprise-grade coach-student privacy and database security',
        'features': [
          'Coach-student privacy isolation',
          'Complete feedback system with admin management',
          'Admin panel with 5 tabs',
          'Real-time feedback stream',
        ],
        'fixes': [
          'Admin login routing issues',
          'Admin password display mismatch',
          'Feedback save to Firestore',
        ],
        'security': [
          'Firestore security rules deployed',
          'Storage security rules created',
          'Coach privacy at database level',
          'Admin Firebase authentication',
        ],
      },
    );

    // v2.4.1 - UX Overhaul
    batch.set(
      FirebaseFirestore.instance.collection('releaseNotes').doc('v2.4.1'),
      {
        'version': 'v2.4.1',
        'releaseDate': DateTime(2025, 11, 5, 3, 0),
        'title': 'Major UX Improvements',
        'description': '9 critical UX fixes for parent, child, and coach experiences',
        'features': [
          'Points slider in multiples of 10',
          'Child name special character validation',
          'Advanced task creator link functional',
        ],
        'fixes': [
          'Removed "100% Free Forever" messaging',
          'Fixed welcome screen loops',
          'Complete Profile button working',
          'Skip for Now navigation',
          'No more redirect loops',
        ],
        'security': [],
      },
    );

    // v2.4.0 - Feature Complete
    batch.set(
      FirebaseFirestore.instance.collection('releaseNotes').doc('v2.4.0'),
      {
        'version': 'v2.4.0',
        'releaseDate': DateTime(2025, 11, 4, 22, 0),
        'title': 'Feature Complete Release',
        'description': 'Complete learning management platform with all core features',
        'features': [
          'Parent-child task management',
          'Coach class management',
          'Quick task & child creation dialogs',
          'Achievements system',
          'Financial ledger',
          'Class marketplace',
          'Analytics dashboard',
        ],
        'fixes': [
          'Data persistence issues',
          'Multi-tenancy filtering',
          'Task approval workflow',
        ],
        'security': [
          'Firebase authentication',
          'Role-based access',
        ],
      },
    );

    await batch.commit();
    print('✓ Initial release notes created');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Release Notes', style: AppTheme.headline4),
                  const SizedBox(height: 4),
                  Text(
                    'Track all platform updates and improvements',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddReleaseDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Release'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Release Notes Timeline
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('releaseNotes')
                  .orderBy('releaseDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 64, color: AppTheme.neutral400),
                        const SizedBox(height: 16),
                        Text('No release notes yet', style: AppTheme.headline6),
                        const SizedBox(height: 8),
                        Text('Add your first release note!', style: AppTheme.bodyMedium),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isLatest = index == 0;
                    
                    return _buildReleaseCard(data, doc.id, isLatest);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseCard(Map<String, dynamic> data, String docId, bool isLatest) {
    final version = data['version'] as String? ?? 'Unknown';
    final title = data['title'] as String? ?? 'Untitled Release';
    final description = data['description'] as String? ?? '';
    final releaseDate = (data['releaseDate'] as Timestamp?)?.toDate();
    final features = (data['features'] as List<dynamic>?)?.cast<String>() ?? [];
    final fixes = (data['fixes'] as List<dynamic>?)?.cast<String>() ?? [];
    final security = (data['security'] as List<dynamic>?)?.cast<String>() ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isLatest ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isLatest
            ? BorderSide(color: AppTheme.successColor, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isLatest ? AppTheme.primaryGradient : null,
              color: isLatest ? null : AppTheme.neutral50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLatest ? Colors.white : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    version,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLatest ? AppTheme.primaryColor : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLatest ? Colors.white : AppTheme.neutral900,
                        ),
                      ),
                      if (releaseDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy • h:mm a').format(releaseDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: isLatest ? Colors.white.withOpacity(0.9) : AppTheme.neutral600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isLatest)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'LATEST',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  Text(description, style: AppTheme.bodyLarge),
                  const SizedBox(height: 20),
                ],
                
                // Features
                if (features.isNotEmpty) ...[
                  _buildSection('✨ New Features', features, Colors.purple),
                  const SizedBox(height: 16),
                ],
                
                // Fixes
                if (fixes.isNotEmpty) ...[
                  _buildSection('🐛 Bug Fixes', fixes, Colors.green),
                  const SizedBox(height: 16),
                ],
                
                // Security
                if (security.isNotEmpty) ...[
                  _buildSection('🔒 Security Updates', security, Colors.red),
                ],
              ],
            ),
          ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showEditReleaseDialog(context, data, docId),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _deleteRelease(docId),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: AppTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _showAddReleaseDialog(BuildContext context) {
    final versionController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final features = <String>[];
    final fixes = <String>[];
    final security = <String>[];
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Release Notes'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Version & Date
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: versionController,
                          decoration: const InputDecoration(
                            labelText: 'Version *',
                            hintText: 'e.g., v2.6.0',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2026),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDate),
                              );
                              if (time != null) {
                                setDialogState(() {
                                  selectedDate = DateTime(
                                    date.year, date.month, date.day,
                                    time.hour, time.minute,
                                  );
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            DateFormat('MMM dd, h:mm a').format(selectedDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title & Description
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Release Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  
                  // Features
                  _buildItemListEditor(
                    'Features',
                    features,
                    Colors.purple,
                    setDialogState,
                  ),
                  const SizedBox(height: 16),
                  
                  // Fixes
                  _buildItemListEditor(
                    'Bug Fixes',
                    fixes,
                    Colors.green,
                    setDialogState,
                  ),
                  const SizedBox(height: 16),
                  
                  // Security
                  _buildItemListEditor(
                    'Security Updates',
                    security,
                    Colors.red,
                    setDialogState,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveRelease(
                dialogContext,
                versionController.text,
                titleController.text,
                descriptionController.text,
                selectedDate,
                features,
                fixes,
                security,
              ),
              child: const Text('Save Release'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemListEditor(String title, List<String> items, Color color, StateSetter setState) {
    final controller = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: color, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Add $title'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Enter item...'),
                      autofocus: true,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() => items.add(value.trim()));
                          Navigator.pop(context);
                        }
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            setState(() => items.add(controller.text.trim()));
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...items.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.circle, size: 6, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(entry.value, style: AppTheme.bodySmall)),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => items.removeAt(entry.key)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Future<void> _saveRelease(
    BuildContext dialogContext,
    String version,
    String title,
    String description,
    DateTime releaseDate,
    List<String> features,
    List<String> fixes,
    List<String> security,
  ) async {
    if (version.trim().isEmpty || title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Version and title are required')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('releaseNotes').doc(version).set({
        'version': version.trim(),
        'title': title.trim(),
        'description': description.trim(),
        'releaseDate': Timestamp.fromDate(releaseDate),
        'features': features,
        'fixes': fixes,
        'security': security,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Release notes saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditReleaseDialog(BuildContext context, Map<String, dynamic> data, String docId) {
    // Similar to add dialog but pre-filled
  }

  Future<void> _deleteRelease(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Release Notes?'),
        content: const Text('This action cannot be undone.'),
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
        await FirebaseFirestore.instance.collection('releaseNotes').doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Release notes deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

