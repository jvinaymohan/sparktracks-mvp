import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/task_model.dart';
import '../../models/class_model.dart';
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

  // Mock data for calendar events
  final Map<DateTime, List<CalendarEvent>> _events = {
    DateTime.now(): [
      CalendarEvent(
        id: '1',
        title: 'Math Homework Due',
        type: CalendarEventType.task,
        startTime: DateTime.now().copyWith(hour: 18, minute: 0),
        endTime: DateTime.now().copyWith(hour: 19, minute: 0),
        color: AppTheme.warningColor,
      ),
      CalendarEvent(
        id: '2',
        title: 'Soccer Training',
        type: CalendarEventType.classEvent,
        startTime: DateTime.now().copyWith(hour: 16, minute: 0),
        endTime: DateTime.now().copyWith(hour: 17, minute: 0),
        color: AppTheme.primaryColor,
      ),
    ],
    DateTime.now().add(const Duration(days: 1)): [
      CalendarEvent(
        id: '3',
        title: 'Piano Practice',
        type: CalendarEventType.task,
        startTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 15, minute: 0),
        endTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 16, minute: 0),
        color: AppTheme.infoColor,
      ),
    ],
    DateTime.now().add(const Duration(days: 2)): [
      CalendarEvent(
        id: '4',
        title: 'Piano Lessons',
        type: CalendarEventType.classEvent,
        startTime: DateTime.now().add(const Duration(days: 2)).copyWith(hour: 16, minute: 0),
        endTime: DateTime.now().add(const Duration(days: 2)).copyWith(hour: 17, minute: 0),
        color: AppTheme.successColor,
      ),
    ],
    DateTime.now().add(const Duration(days: 3)): [
      CalendarEvent(
        id: '5',
        title: 'Reading Assignment',
        type: CalendarEventType.task,
        startTime: DateTime.now().add(const Duration(days: 3)).copyWith(hour: 14, minute: 0),
        endTime: DateTime.now().add(const Duration(days: 3)).copyWith(hour: 15, minute: 0),
        color: AppTheme.warningColor,
      ),
    ],
  };

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

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  List<CalendarEvent> _getEventsForRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (DateTime d = start; d.isBefore(end.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else {
      _selectedEvents.value = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEventDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(AppTheme.spacingL),
            child: TableCalendar<CalendarEvent>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
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
              onDaySelected: _onDaySelected,
              onRangeSelected: _onRangeSelected,
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
          
          // Events List
          Expanded(
            child: ValueListenableBuilder<List<CalendarEvent>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      child: ListTile(
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: event.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(event.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatTime(event.startTime)),
                            Text(
                              event.type == CalendarEventType.task ? 'Task' : 'Class',
                              style: AppTheme.bodySmall.copyWith(
                                color: event.color,
                                fontWeight: FontWeight.bold,
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
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (action) => _handleEventAction(action, event),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: const Icon(Icons.add),
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
        _showEditEventDialog(event);
        break;
      case 'delete':
        _showDeleteEventDialog(event);
        break;
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: const Text('Event creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Create event
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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

  void _showEditEventDialog(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: const Text('Event editing form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Update event
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteEventDialog(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete event
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

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}
