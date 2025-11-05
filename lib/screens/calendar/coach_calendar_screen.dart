import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/classes_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../models/class_model.dart';
import '../../utils/app_theme.dart';

/// Coach-specific calendar showing only their classes (not child tasks)
class CoachCalendarScreen extends StatefulWidget {
  const CoachCalendarScreen({super.key});

  @override
  State<CoachCalendarScreen> createState() => _CoachCalendarScreenState();
}

class _CoachCalendarScreenState extends State<CoachCalendarScreen> {
  late final ValueNotifier<List<ClassEvent>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // Convert classes to calendar events
  Map<DateTime, List<ClassEvent>> _getEventsFromClasses(List<Class> classes) {
    final Map<DateTime, List<ClassEvent>> events = {};
    
    for (final classItem in classes) {
      final day = DateTime(
        classItem.startTime.year,
        classItem.startTime.month,
        classItem.startTime.day,
      );
      
      events.putIfAbsent(day, () => []).add(
        ClassEvent(
          id: classItem.id,
          title: classItem.title,
          description: classItem.description,
          classItem: classItem,
          startTime: classItem.startTime,
          endTime: classItem.endTime,
          color: _getColorForClassType(classItem.type),
        ),
      );
    }
    
    return events;
  }

  Color _getColorForClassType(ClassType type) {
    switch (type) {
      case ClassType.oneTime:
        return AppTheme.accentColor;
      case ClassType.weekly:
        return AppTheme.successColor;
      case ClassType.monthly:
        return AppTheme.warningColor;
    }
  }

  List<ClassEvent> _getEventsForDay(DateTime day, Map<DateTime, List<ClassEvent>> events) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return events[dayKey] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay, Map<DateTime, List<ClassEvent>> events) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay, events);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes Calendar'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/create-class'),
            tooltip: 'Create Class',
          ),
        ],
      ),
      body: Consumer<ClassesProvider>(
        builder: (context, classesProvider, _) {
          final coachClasses = classesProvider.getClassesForCoach(currentUser?.id ?? '');
          final events = _getEventsFromClasses(coachClasses);
          
          return Column(
            children: [
              // Calendar
              Card(
                margin: const EdgeInsets.all(AppTheme.spacingL),
                elevation: 4,
                child: TableCalendar<ClassEvent>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) => _getEventsForDay(day, events),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    markersMaxCount: 3,
                    markerDecoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                  ),
                  onDaySelected: (selectedDay, focusedDay) => _onDaySelected(selectedDay, focusedDay, events),
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Divider(),
              ),
              
              // Classes for selected day
              Expanded(
                child: ValueListenableBuilder<List<ClassEvent>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    if (value.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 64, color: AppTheme.neutral400),
                            const SizedBox(height: 16),
                            Text(
                              'No classes scheduled for this day',
                              style: AppTheme.bodyLarge.copyWith(color: AppTheme.neutral600),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/create-class'),
                              icon: const Icon(Icons.add),
                              label: const Text('Create a Class'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final event = value[index];
                        return _buildClassCard(event);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClassCard(ClassEvent event) {
    final classItem = event.classItem;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spacingM),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                classItem.locationType == LocationType.online
                    ? Icons.computer
                    : Icons.location_on,
                color: event.color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                classItem.type == ClassType.weekly
                    ? 'Weekly'
                    : classItem.type == ClassType.monthly
                        ? 'Monthly'
                        : 'Once',
                style: TextStyle(
                  fontSize: 10,
                  color: event.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (event.description != null && event.description!.isNotEmpty)
              Text(
                event.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppTheme.neutral600),
                const SizedBox(width: 4),
                Text(
                  '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                  '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: AppTheme.neutral600, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.people, size: 14, color: AppTheme.neutral600),
                const SizedBox(width: 4),
                Text(
                  '${classItem.enrolledStudentIds.length}/${classItem.maxStudents} students',
                  style: TextStyle(color: AppTheme.neutral600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit Class'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'students',
              child: Row(
                children: [
                  Icon(Icons.people, size: 18),
                  SizedBox(width: 8),
                  Text('View Students'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'attendance',
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18),
                  SizedBox(width: 8),
                  Text('Mark Attendance'),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleClassAction(value as String, classItem),
        ),
      ),
    );
  }

  void _handleClassAction(String action, Class classItem) {
    switch (action) {
      case 'edit':
        context.push('/create-class?classId=${classItem.id}');
        break;
      case 'students':
        _showStudentsDialog(classItem);
        break;
      case 'attendance':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mark attendance for ${classItem.title}'),
            action: SnackBarAction(
              label: 'GO',
              onPressed: () => context.push('/mark-attendance?classId=${classItem.id}'),
            ),
          ),
        );
        break;
    }
  }

  void _showStudentsDialog(Class classItem) {
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    final enrolledStudents = childrenProvider.children
        .where((child) => classItem.enrolledStudentIds.contains(child.userId))
        .toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Students in ${classItem.title}'),
        content: enrolledStudents.isEmpty
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 48, color: AppTheme.neutral400),
                  SizedBox(height: 16),
                  Text('No students enrolled yet.'),
                ],
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: enrolledStudents.length,
                  itemBuilder: (context, index) {
                    final student = enrolledStudents[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          student.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(student.name),
                      subtitle: Text(student.email),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (enrolledStudents.isEmpty)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Go back to dashboard to assign students
                context.go('/coach-dashboard');
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Assign Students'),
            ),
        ],
      ),
    );
  }
}

class ClassEvent {
  final String id;
  final String title;
  final String? description;
  final Class classItem;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;

  ClassEvent({
    required this.id,
    required this.title,
    this.description,
    required this.classItem,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}

