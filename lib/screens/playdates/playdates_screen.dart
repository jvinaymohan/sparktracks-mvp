import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/playdate_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/playdate_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';
import 'create_playdate_screen.dart';
import 'playdate_detail_screen.dart';

/// Main playdates screen - coordinate activities with other families
class PlaydatesScreen extends StatefulWidget {
  const PlaydatesScreen({Key? key}) : super(key: key);

  @override
  State<PlaydatesScreen> createState() => _PlaydatesScreenState();
}

class _PlaydatesScreenState extends State<PlaydatesScreen>
    with SingleTickerProviderStateMixin {
  final PlaydateService _playdateService = PlaydateService();
  late TabController _tabController;
  
  List<Playdate> _playdates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPlaydates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaydates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final parentId = authProvider.currentUser?.id ?? '';

      final playdates = await _playdateService.getPlaydatesForParent(parentId);

      setState(() {
        _playdates = playdates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playdates & Activities'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.goToDashboard(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'My Balances',
            onPressed: _showBalances,
          ),
          NavigationHelper.buildGradientHomeButton(context),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.event, size: 20)),
            Tab(text: 'My Events', icon: Icon(Icons.calendar_today, size: 20)),
            Tab(text: 'Invites', icon: Icon(Icons.mail, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingTab(),
                    _buildMyEventsTab(),
                    _buildInvitesTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPlaydate,
        icon: const Icon(Icons.add),
        label: const Text('New Playdate'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text('Error loading playdates', style: AppTheme.headline6),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error', style: AppTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPlaydates,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    final now = DateTime.now();
    final upcoming = _playdates
        .where((p) => p.startTime.isAfter(now) && p.status != PlaydateStatus.cancelled)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (upcoming.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_available,
        title: 'No Upcoming Playdates',
        message: 'Create a playdate to coordinate activities with other families!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlaydates,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcoming.length,
        itemBuilder: (context, index) => _buildPlaydateCard(upcoming[index]),
      ),
    );
  }

  Widget _buildMyEventsTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final parentId = authProvider.currentUser?.id ?? '';
    
    final myEvents = _playdates
        .where((p) => p.organizerId == parentId)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (myEvents.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_note,
        title: 'No Events Created',
        message: 'Organize your first playdate and invite other families!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myEvents.length,
      itemBuilder: (context, index) => _buildPlaydateCard(myEvents[index], isOrganizer: true),
    );
  }

  Widget _buildInvitesTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final parentId = authProvider.currentUser?.id ?? '';
    
    final invites = _playdates.where((p) {
      return p.invites.any((invite) => invite.parentId == parentId);
    }).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (invites.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mail_outline,
        title: 'No Invitations',
        message: 'You\'ll see invitations to playdates here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invites.length,
      itemBuilder: (context, index) => _buildPlaydateCard(invites[index], showRSVP: true),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppTheme.neutral400),
            const SizedBox(height: 24),
            Text(title, style: AppTheme.headline5),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _createPlaydate,
              icon: const Icon(Icons.add),
              label: const Text('Create Playdate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaydateCard(Playdate playdate, {bool isOrganizer = false, bool showRSVP = false}) {
    final authProvider = Provider.of<AuthProvider>(context);
    final parentId = authProvider.currentUser?.id ?? '';
    final myInvite = playdate.invites.firstWhere(
      (invite) => invite.parentId == parentId,
      orElse: () => PlaydateInvite(
        parentId: '',
        parentName: '',
        childIds: [],
        childNames: [],
        invitedAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewPlaydate(playdate),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getActivityColor(playdate.activityType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getActivityIcon(playdate.activityType),
                      color: _getActivityColor(playdate.activityType),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(playdate.title, style: AppTheme.headline6),
                        const SizedBox(height: 4),
                        Text(
                          'by ${playdate.organizerName}',
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                        ),
                      ],
                    ),
                  ),
                  if (isOrganizer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Organizer',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Date, time, location
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppTheme.neutral600),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEE, MMM d').format(playdate.startTime),
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: AppTheme.neutral600),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('h:mm a').format(playdate.startTime),
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppTheme.neutral600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      playdate.location,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Participants & features
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.people, size: 16),
                    label: Text('${playdate.currentParticipants}/${playdate.maxParticipants} families'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  if (playdate.needsTransportation)
                    const Chip(
                      avatar: Icon(Icons.directions_car, size: 16),
                      label: Text('Carpool available'),
                      backgroundColor: AppTheme.successColor,
                      labelStyle: TextStyle(color: Colors.white),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  if (playdate.hasSharedExpenses)
                    const Chip(
                      avatar: Icon(Icons.attach_money, size: 16),
                      label: Text('Shared expenses'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
              
              // RSVP section for invites
              if (showRSVP && myInvite.parentId.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Your RSVP: ',
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    _buildRSVPStatus(myInvite.status),
                    const Spacer(),
                    if (myInvite.status == RSVPStatus.pending)
                      TextButton(
                        onPressed: () => _quickRSVP(playdate.id, RSVPStatus.accepted),
                        child: const Text('Accept'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRSVPStatus(RSVPStatus status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case RSVPStatus.accepted:
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        label = 'Accepted';
        break;
      case RSVPStatus.declined:
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        label = 'Declined';
        break;
      case RSVPStatus.maybe:
        color = AppTheme.warningColor;
        icon = Icons.help;
        label = 'Maybe';
        break;
      case RSVPStatus.pending:
      default:
        color = AppTheme.neutral600;
        icon = Icons.pending;
        label = 'Pending';
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'park':
        return Icons.park;
      case 'sports':
        return Icons.sports_soccer;
      case 'class':
        return Icons.school;
      case 'party':
        return Icons.cake;
      case 'study_group':
        return Icons.menu_book;
      case 'playdate':
      default:
        return Icons.child_care;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'park':
        return Colors.green;
      case 'sports':
        return Colors.orange;
      case 'class':
        return Colors.blue;
      case 'party':
        return Colors.pink;
      case 'study_group':
        return Colors.purple;
      case 'playdate':
      default:
        return AppTheme.primaryColor;
    }
  }

  void _createPlaydate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePlaydateScreen(),
      ),
    );

    if (result == true) {
      _loadPlaydates();
    }
  }

  void _viewPlaydate(Playdate playdate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaydateDetailScreen(playdate: playdate),
      ),
    );

    if (result == true) {
      _loadPlaydates();
    }
  }

  Future<void> _quickRSVP(String playdateId, RSVPStatus status) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final parentId = authProvider.currentUser?.id ?? '';

    try {
      await _playdateService.updateRSVP(
        playdateId: playdateId,
        parentId: parentId,
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ RSVP updated to ${status.name}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _loadPlaydates();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating RSVP: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showBalances() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Expense Balances'),
          ],
        ),
        content: const Text('Balance tracking coming soon!\n\nYou\'ll see who owes you and whom you owe for shared playdate expenses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

