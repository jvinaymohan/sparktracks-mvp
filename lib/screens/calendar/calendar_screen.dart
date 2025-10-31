import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/children_provider.dart';
import '../../models/task_model.dart';
import '../../models/class_model.dart';
import '../../models/student_model.dart';
import '../../utils/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<CalendarEvent>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // Convert tasks to calendar events with child grouping and recurring support
  Map<DateTime, List<CalendarEvent>> _getEventsFromTasks(
    List<Task> tasks,
    List<Student> children,
  ) {
    final Map<DateTime, List<CalendarEvent>> events = {};
    
    for (final task in tasks) {
      if (task.dueDate == null) continue;
      
      // Get child color for this task
      final child = children.firstWhere(
        (c) => c.id == task.childId,
        orElse: () => children.isNotEmpty ? children.first : Student(
          id: task.childId,
          userId: '',
          parentId: '',
          name: 'Unknown',
          email: '',
          dateOfBirth: DateTime.now(),
          enrolledAt: DateTime.now(),
        ),
      );
      final childColor = child.colorCode != null
          ? Color(int.parse(child.colorCode!.replaceFirst('#', '0xFF')))
          : AppTheme.primaryColor;
      
      if (task.isRecurring && task.recurringPattern != null) {
        // Generate recurring events
        _addRecurringTaskEvents(task, childColor, events);
      } else {
        // Single task event
        _addSingleTaskEvent(task, childColor, events);
      }
    }
    
    return events;
  }
  
  void _addSingleTaskEvent(
    Task task,
    Color color,
    Map<DateTime, List<CalendarEvent>> events,
  ) {
    if (task.dueDate == null) return;
    
    final day = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    final startTime = task.dueDate!;
    final endTime = startTime.add(const Duration(hours: 1)); // Default 1 hour duration
    
    events.putIfAbsent(day, () => []).add(
      CalendarEvent(
        id: task.id,
        title: task.title,
        description: task.description,
        type: CalendarEventType.task,
        startTime: startTime,
        endTime: endTime,
        color: color,
        task: task, // Store reference to task for editing
      ),
    );
  }
  
  void _addRecurringTaskEvents(
    Task task,
    Color color,
    Map<DateTime, List<CalendarEvent>> events,
  ) {
    if (task.dueDate == null || task.recurringPattern == null) return;
    
    final startDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    final endDate = DateTime.now().add(const Duration(days: 90)); // Show next 90 days
    
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final startTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        task.dueDate!.hour,
        task.dueDate!.minute,
      );
      final endTime = startTime.add(const Duration(hours: 1));
      
      events.putIfAbsent(currentDate, () => []).add(
        CalendarEvent(
          id: '${task.id}_${currentDate.millisecondsSinceEpoch}',
          title: task.title,
          description: task.description,
          type: CalendarEventType.task,
          startTime: startTime,
          endTime: endTime,
          color: color,
          task: task,
          isRecurring: true,
        ),
      );
      
      // Move to next occurrence
      switch (task.recurringPattern) {
        case 'daily':
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case 'weekly':
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case 'monthly':
          currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        default:
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<CalendarEvent> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<CalendarEvent>> events,
  ) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return events[dayKey] ?? [];
  }

  List<CalendarEvent> _getEventsForRange(
    DateTime start,
    DateTime end,
    Map<DateTime, List<CalendarEvent>> events,
  ) {
    final days = <DateTime>[];
    for (DateTime d = start; d.isBefore(end.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      days.add(DateTime(d.year, d.month, d.day));
    }
    return [
      for (final d in days) ..._getEventsForDay(d, events),
    ];
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update selected events when tasks change
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    final events = _getEventsFromTasks(tasksProvider.tasks, childrenProvider.children);
    final selectedEventsForDay = _getEventsForDay(_selectedDay ?? DateTime.now(), events);
    _selectedEvents.value = selectedEventsForDay;
  }

  void _onDaySelected(
    DateTime selectedDay,
    DateTime focusedDay,
    Map<DateTime, List<CalendarEvent>> events,
  ) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay, events);
    }
  }

  void _onRangeSelected(
    DateTime? start,
    DateTime? end,
    DateTime focusedDay,
    Map<DateTime, List<CalendarEvent>> events,
  ) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end, events);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start, events);
    } else {
      _selectedEvents.value = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/create-task'),
          ),
        ],
      ),
      body: Consumer2<TasksProvider, ChildrenProvider>(
        builder: (context, tasksProvider, childrenProvider, _) {
          final tasks = tasksProvider.tasks;
          final children = childrenProvider.children;
          final events = _getEventsFromTasks(tasks, children);
          
          return Column(
            children: [
              // Calendar
              Card(
                margin: const EdgeInsets.all(AppTheme.spacingL),
                child: TableCalendar<CalendarEvent>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) => _getEventsForDay(day, events),
                  startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) => _onDaySelected(selectedDay, focusedDay, events),
              onRangeSelected: (start, end, focusedDay) => _onRangeSelected(start, end, focusedDay, events),
              rangeSelectionMode: _rangeSelectionMode,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
            ),
          ),
          
          // Events List - Grouped by Child
          Expanded(
            child: ValueListenableBuilder<List<CalendarEvent>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note, size: 64, color: AppTheme.neutral400),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks on this day',
                          style: AppTheme.bodyLarge.copyWith(color: AppTheme.neutral600),
                        ),
                      ],
                    ),
                  );
                }
                
                // Group events by child
                final groupedEvents = <String, List<CalendarEvent>>{};
                for (final event in value) {
                  if (event.task != null) {
                    final childId = event.task!.childId;
                    final child = children.firstWhere(
                      (c) => c.id == childId,
                      orElse: () => children.isNotEmpty ? children.first : Student(
                        id: childId,
                        userId: '',
                        parentId: '',
                        name: 'Unknown',
                        email: '',
                        dateOfBirth: DateTime.now(),
                        enrolledAt: DateTime.now(),
                      ),
                    );
                    final childName = child.name;
                    groupedEvents.putIfAbsent(childName, () => []).add(event);
                  } else {
                    groupedEvents.putIfAbsent('Other', () => []).add(event);
                  }
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  itemCount: groupedEvents.length,
                  itemBuilder: (context, index) {
                    final childName = groupedEvents.keys.elementAt(index);
                    final childEvents = groupedEvents[childName]!;
                    final firstEvent = childEvents.first;
                    final childColor = firstEvent.color;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Child header
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: childColor.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: childColor,
                                  child: Text(
                                    childName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    childName,
                                    style: AppTheme.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${childEvents.length} ${childEvents.length == 1 ? 'task' : 'tasks'}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.neutral600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tasks for this child
                          ...childEvents.map((event) => ListTile(
                            leading: Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: event.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(event.title)),
                                if (event.isRecurring)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.repeat,
                                      size: 16,
                                      color: AppTheme.infoColor,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatTime(event.startTime)} • ${event.task?.category?.toUpperCase() ?? 'TASK'}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.neutral600,
                                  ),
                                ),
                                if (event.task?.rewardAmount != null && event.task!.rewardAmount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.star, size: 14, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${event.task!.rewardAmount.toInt()} pts',
                                          style: AppTheme.bodySmall.copyWith(
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('View Details'),
                                ),
                                if (event.task != null)
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit Task'),
                                  ),
                                if (event.task != null)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete Task'),
                                  ),
                              ],
                              onSelected: (action) => _handleEventAction(action, event),
                            ),
                            onTap: event.task != null
                                ? () => context.go('/create-task?taskId=${event.task!.id}')
                                : null,
                          )),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
            ],
          ),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/create-task'),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleEventAction(String action, CalendarEvent event) {
    switch (action) {
      case 'view':
        _showEventDetails(event);
        break;
      case 'edit':
        if (event.task != null) {
          // Navigate to task wizard with existing task
          context.go('/create-task?taskId=${event.task!.id}');
        }
        break;
      case 'delete':
        _showDeleteEventDialog(event);
        break;
    }
  }

  void _showEventDetails(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${event.type == CalendarEventType.task ? 'Task' : 'Class'}'),
            Text('Time: ${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}'),
            if (event.description != null) Text('Description: ${event.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteEventDialog(CalendarEvent event) {
    if (event.task == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete: Task not found')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
              tasksProvider.deleteTask(event.task!.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

enum CalendarEventType {
  task,
  classEvent,
}

class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final CalendarEventType type;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final Task? task; // Reference to the task for editing
  final bool isRecurring; // Whether this is a recurring task instance

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.task,
    this.isRecurring = false,
  });
}
