import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_model.dart';
import '../../models/student_progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/classes_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';

/// Student Grouping & Management Screen (v3.0)
/// Allows coaches to organize students by various criteria
class StudentGroupingScreen extends StatefulWidget {
  const StudentGroupingScreen({super.key});

  @override
  State<StudentGroupingScreen> createState() => _StudentGroupingScreenState();
}

class _StudentGroupingScreenState extends State<StudentGroupingScreen> {
  String _selectedGrouping = StudentGrouping.byClass;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    final coachId = authProvider.currentUser?.id ?? '';
    
    // For now, just get all students visible to coach (enrolled in classes or created by coach)
    final students = childrenProvider.getStudentsVisibleToCoach(coachId, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Students'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.goToDashboard(context),
        ),
        actions: [
          NavigationHelper.buildGradientHomeButton(context),
        ],
      ),
      body: Column(
        children: [
          // Grouping Selector
          _buildGroupingSelector(),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: AppTheme.inputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          
          // Student List (grouped)
          Expanded(
            child: _buildGroupedStudentList(students),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildGroupingSelector() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSmall,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: StudentGrouping.allGroupingTypes.map((type) {
          final isSelected = _selectedGrouping == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                children: [
                  Icon(
                    StudentGrouping.getGroupingIcon(type),
                    size: 16,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.neutral600,
                  ),
                  const SizedBox(width: 8),
                  Text(StudentGrouping.getGroupingName(type)),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedGrouping = type);
                }
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGroupedStudentList(List<Student> students) {
    // Filter by search
    final filteredStudents = students.where((s) =>
      s.name.toLowerCase().contains(_searchQuery) ||
      s.userId.toLowerCase().contains(_searchQuery)
    ).toList();

    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: AppTheme.neutral400),
            const SizedBox(height: 16),
            Text('No students found', style: AppTheme.headline6),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'Try a different search'
                  : 'Add your first student!',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Group students
    final groups = _groupStudents(filteredStudents);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroupSection(group['title'], group['students']);
      },
    );
  }

  List<Map<String, dynamic>> _groupStudents(List<Student> students) {
    switch (_selectedGrouping) {
      case StudentGrouping.bySkillLevel:
        return _groupBySkillLevel(students);
      case StudentGrouping.byClass:
        return _groupByClass(students);
      case StudentGrouping.byAge:
        return _groupByAge(students);
      case StudentGrouping.byPaymentStatus:
        return _groupByPaymentStatus(students);
      default:
        return [
          {'title': 'All Students', 'students': students}
        ];
    }
  }

  List<Map<String, dynamic>> _groupBySkillLevel(List<Student> students) {
    return [
      {
        'title': '🌱 Beginners (0-6 months)',
        'students': students.where((s) => _getStudentSkillLevel(s) == 'beginner').toList(),
      },
      {
        'title': '📈 Intermediate (6-18 months)',
        'students': students.where((s) => _getStudentSkillLevel(s) == 'intermediate').toList(),
      },
      {
        'title': '🏆 Advanced (18+ months)',
        'students': students.where((s) => _getStudentSkillLevel(s) == 'advanced').toList(),
      },
      {
        'title': '⭐ Expert/Competitive',
        'students': students.where((s) => _getStudentSkillLevel(s) == 'expert').toList(),
      },
    ];
  }

  List<Map<String, dynamic>> _groupByClass(List<Student> students) {
    // TODO: Group by enrolled classes
    return [
      {'title': 'Beginner Tennis', 'students': students.take(5).toList()},
      {'title': 'Advanced Piano', 'students': students.skip(5).take(3).toList()},
      {'title': 'Not Enrolled', 'students': students.skip(8).toList()},
    ];
  }

  // Helper method to calculate age from dateOfBirth
  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  List<Map<String, dynamic>> _groupByAge(List<Student> students) {
    return [
      {
        'title': '👶 Kids (5-10)',
        'students': students.where((s) => _calculateAge(s.dateOfBirth) >= 5 && _calculateAge(s.dateOfBirth) <= 10).toList(),
      },
      {
        'title': '🧒 Tweens (11-13)',
        'students': students.where((s) => _calculateAge(s.dateOfBirth) >= 11 && _calculateAge(s.dateOfBirth) <= 13).toList(),
      },
      {
        'title': '👦 Teens (14-17)',
        'students': students.where((s) => _calculateAge(s.dateOfBirth) >= 14 && _calculateAge(s.dateOfBirth) <= 17).toList(),
      },
      {
        'title': '👨 Adults (18+)',
        'students': students.where((s) => _calculateAge(s.dateOfBirth) >= 18).toList(),
      },
    ];
  }

  List<Map<String, dynamic>> _groupByPaymentStatus(List<Student> students) {
    return [
      {
        'title': '✅ Active (Paid Up)',
        'students': students.where((s) => _getPaymentStatus(s) == 'active').toList(),
      },
      {
        'title': '⏰ Payment Due',
        'students': students.where((s) => _getPaymentStatus(s) == 'due').toList(),
      },
      {
        'title': '❌ Inactive',
        'students': students.where((s) => _getPaymentStatus(s) == 'inactive').toList(),
      },
    ];
  }

  String _getStudentSkillLevel(Student student) {
    // TODO: Get from StudentProgress model
    return 'beginner'; // Placeholder
  }

  String _getPaymentStatus(Student student) {
    // TODO: Get from payment records
    return 'active'; // Placeholder
  }

  Widget _buildGroupSection(String title, List<Student> students) {
    if (students.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(title, style: AppTheme.headline6),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${students.length}',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...students.map((student) => _buildStudentCard(student)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: student.colorCode != null
              ? Color(int.parse(student.colorCode!.replaceFirst('#', '0xFF')))
              : AppTheme.primaryColor,
          child: Text(
            student.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.name, style: AppTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Age: ${_calculateAge(student.dateOfBirth)}', style: AppTheme.bodySmall),
            _buildProgressBar(student),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleStudentAction(value, student),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_progress',
              child: Row(
                children: [
                  Icon(Icons.assessment, size: 20),
                  SizedBox(width: 12),
                  Text('View Progress'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assign_class',
              child: Row(
                children: [
                  Icon(Icons.class_, size: 20),
                  SizedBox(width: 12),
                  Text('Assign to Class'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'add_note',
              child: Row(
                children: [
                  Icon(Icons.note_add, size: 20),
                  SizedBox(width: 12),
                  Text('Add Note'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'message',
              child: Row(
                children: [
                  Icon(Icons.message, size: 20),
                  SizedBox(width: 12),
                  Text('Send Message'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _viewStudentDetails(student),
      ),
    );
  }

  Widget _buildProgressBar(Student student) {
    // TODO: Get actual progress from StudentProgress model
    final progress = 0.65; // Placeholder
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Progress:', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 8),
              Text('65%', style: TextStyle(fontSize: 11, color: AppTheme.successColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppTheme.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStudentAction(String action, Student student) {
    switch (action) {
      case 'view_progress':
        _viewStudentProgress(student);
        break;
      case 'assign_class':
        _assignToClass(student);
        break;
      case 'add_note':
        _addCoachNote(student);
        break;
      case 'message':
        _sendMessage(student);
        break;
    }
  }

  void _viewStudentDetails(Student student) {
    // Navigate to student detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailScreen(student: student),
      ),
    );
  }

  void _viewStudentProgress(Student student) {
    // Navigate to progress screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress tracking screen coming soon!')),
    );
  }

  void _assignToClass(Student student) {
    // Show class assignment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Class assignment coming soon!')),
    );
  }

  void _addCoachNote(Student student) {
    // Show note dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add note feature coming soon!')),
    );
  }

  void _sendMessage(Student student) {
    // Navigate to messaging
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Messaging coming soon!')),
    );
  }

  void _showAddStudentDialog() {
    // Show existing add student dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Use Manage Students screen to add students')),
    );
  }
}

/// Student Detail Screen with Tabs
class StudentDetailScreen extends StatefulWidget {
  final Student student;
  
  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  // Helper method to calculate age from dateOfBirth
  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
        actions: [
          NavigationHelper.buildGradientHomeButton(context),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'Progress', icon: Icon(Icons.trending_up, size: 20)),
            Tab(text: 'Classes', icon: Icon(Icons.class_, size: 20)),
            Tab(text: 'Financial', icon: Icon(Icons.payment, size: 20)),
          ],
          labelColor: AppTheme.primaryColor,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildProgressTab(),
          _buildClassesTab(),
          _buildFinancialTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: widget.student.colorCode != null
                        ? Color(int.parse(widget.student.colorCode!.replaceFirst('#', '0xFF')))
                        : AppTheme.primaryColor,
                    child: Text(
                      widget.student.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.student.name, style: AppTheme.headline4),
                  const SizedBox(height: 4),
                  Text('Age: ${_calculateAge(widget.student.dateOfBirth)}', style: AppTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Joined: Jan 2025', // TODO: Get actual join date
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Skill Level', 'Intermediate', Icons.bar_chart, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Attendance', '85%', Icons.check_circle, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Classes', '2', Icons.class_, Colors.purple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Sessions', '24', Icons.event, Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Notes
          Text('Recent Coach Notes', style: AppTheme.headline6),
          const SizedBox(height: 12),
          _buildNoteCard('Nov 5', 'Great improvement in backhand! Keep practicing.', 'positive'),
          _buildNoteCard('Nov 1', 'Needs to work on serve consistency.', 'needs_improvement'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.headline5.copyWith(color: color)),
            Text(label, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(String date, String note, String category) {
    Color color;
    IconData icon;
    
    switch (category) {
      case 'positive':
        color = AppTheme.successColor;
        icon = Icons.thumb_up;
        break;
      case 'needs_improvement':
        color = AppTheme.warningColor;
        icon = Icons.flag;
        break;
      default:
        color = AppTheme.infoColor;
        icon = Icons.note;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note, style: AppTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(date, style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skill Assessments', style: AppTheme.headline5),
          const SizedBox(height: 16),
          
          // Skill breakdown (example for Tennis)
          _buildSkillRow('Forehand', 4, 'Improving'),
          _buildSkillRow('Backhand', 3, 'Good progress'),
          _buildSkillRow('Serve', 2, 'Needs work'),
          _buildSkillRow('Footwork', 4, 'Excellent'),
          _buildSkillRow('Volleys', 3, 'Developing'),
          
          const SizedBox(height: 32),
          Text('Goals', style: AppTheme.headline5),
          const SizedBox(height: 16),
          _buildGoalItem('Master topspin forehand', true),
          _buildGoalItem('Improve serve consistency to 70%', true),
          _buildGoalItem('Ready for local tournament', false),
        ],
      ),
    );
  }

  Widget _buildSkillRow(String skill, int rating, String trend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(skill, style: AppTheme.bodyLarge),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: AppTheme.accentColor,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(trend, style: AppTheme.bodySmall.copyWith(color: AppTheme.successColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String goal, bool isCompleted) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? AppTheme.successColor : AppTheme.neutral400,
        ),
        title: Text(
          goal,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? AppTheme.neutral500 : AppTheme.neutral900,
          ),
        ),
      ),
    );
  }

  Widget _buildClassesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Enrollments', style: AppTheme.headline5),
          const SizedBox(height: 16),
          
          _buildClassEnrollmentCard(
            'Intermediate Tennis',
            'Mon/Wed 4-5pm',
            '32/50 sessions',
            'Paid through Dec 2025',
            Colors.green,
          ),
          _buildClassEnrollmentCard(
            'Tournament Prep',
            'Sat 10-11am',
            '8/12 sessions',
            '\$120 due Nov 15',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildClassEnrollmentCard(
    String className,
    String schedule,
    String sessions,
    String paymentStatus,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(className, style: AppTheme.headline6),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppTheme.neutral600),
                const SizedBox(width: 8),
                Text(schedule, style: AppTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event_available, size: 16, color: AppTheme.neutral600),
                const SizedBox(width: 8),
                Text(sessions, style: AppTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                paymentStatus,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Overview', style: AppTheme.headline5),
          const SizedBox(height: 16),
          
          // Balance Due
          Card(
            color: AppTheme.warningColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Balance Due', style: AppTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        '\$120.00',
                        style: AppTheme.headline3.copyWith(color: AppTheme.warningColor),
                      ),
                      Text('Due: Nov 15, 2025', style: AppTheme.bodySmall),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningColor,
                    ),
                    child: const Text('Send Invoice'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text('Transaction History', style: AppTheme.headline6),
          const SizedBox(height: 12),
          _buildTransactionItem('Oct 15', 'Payment Received', '+\$300.00', Colors.green),
          _buildTransactionItem('Oct 1', 'Invoice Sent', '\$150.00', Colors.orange),
          _buildTransactionItem('Sep 15', 'Payment Received', '+\$300.00', Colors.green),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String date, String description, String amount, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          amount.startsWith('+') ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
        title: Text(description),
        subtitle: Text(date, style: AppTheme.bodySmall),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

