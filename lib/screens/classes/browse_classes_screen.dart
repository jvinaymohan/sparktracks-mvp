import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/classes_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';
import '../../models/coach_profile_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import 'class_detail_screen.dart';

class BrowseClassesScreen extends StatefulWidget {
  const BrowseClassesScreen({super.key});

  @override
  State<BrowseClassesScreen> createState() => _BrowseClassesScreenState();
}

class _BrowseClassesScreenState extends State<BrowseClassesScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  ClassType? _selectedType;
  LocationType? _selectedLocation;
  bool _showNearbyOnly = false;
  String? _userCity; // For location-based search
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Classes & Coaches'),
        actions: [
          if (!isLoggedIn) ...[
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => context.go('/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(width: 16),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Navigate to appropriate dashboard
                final userType = authProvider.currentUser?.type;
                switch (userType) {
                  case UserType.parent:
                    context.go('/parent-dashboard');
                    break;
                  case UserType.child:
                    context.go('/child-dashboard');
                    break;
                  case UserType.coach:
                    context.go('/coach-dashboard');
                    break;
                  case UserType.admin:
                    context.go('/admin/dashboard');
                    break;
                  default:
                    context.go('/');
                }
              },
              tooltip: 'Back to Dashboard',
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Classes'),
            Tab(icon: Icon(Icons.person), text: 'Coaches'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search classes or coaches...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.neutral100,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter city or location...',
                    prefixIcon: const Icon(Icons.location_city),
                    suffixIcon: _userCity != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _userCity = null;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.neutral100,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _userCity = value.isEmpty ? null : value.toLowerCase();
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Tabs Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildClassesTab(),
                _buildCoachesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    return Consumer<ClassesProvider>(
      builder: (context, classesProvider, _) {
        // Get ONLY public classes
        // Show all public classes created by coaches
        var publicClasses = classesProvider.classes.where((c) => 
          c.isPublic == true && 
          c.coachId.isNotEmpty
        ).toList();
        
        // Apply filters
        if (_searchQuery.isNotEmpty) {
          publicClasses = publicClasses.where((c) =>
            c.title.toLowerCase().contains(_searchQuery) ||
            c.description.toLowerCase().contains(_searchQuery) ||
            (c.category?.toLowerCase().contains(_searchQuery) ?? false)
          ).toList();
        }
        
        // Location-based filtering
        if (_userCity != null && _userCity!.isNotEmpty) {
          publicClasses = publicClasses.where((c) =>
            c.location?.toLowerCase().contains(_userCity!) ?? false
          ).toList();
        }
        
        if (_selectedType != null) {
          publicClasses = publicClasses.where((c) => c.type == _selectedType).toList();
        }
        
        if (_selectedLocation != null) {
          publicClasses = publicClasses.where((c) => c.locationType == _selectedLocation).toList();
        }
        
        return Column(
          children: [
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Classes'),
                    selected: _selectedType == null && _selectedLocation == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = null;
                        _selectedLocation = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: const Icon(Icons.computer, size: 18),
                    label: const Text('Online Only'),
                    selected: _selectedLocation == LocationType.online,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLocation = selected ? LocationType.online : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: const Icon(Icons.location_on, size: 18),
                    label: const Text('In-Person'),
                    selected: _selectedLocation == LocationType.inPerson,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLocation = selected ? LocationType.inPerson : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Weekly'),
                    selected: _selectedType == ClassType.weekly,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? ClassType.weekly : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: const Icon(Icons.event, size: 18),
                    label: const Text('Monthly'),
                    selected: _selectedType == ClassType.monthly,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? ClassType.monthly : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: const Icon(Icons.person, size: 18),
                    label: const Text('1-on-1'),
                    selected: publicClasses.any((c) => !c.isGroupClass),
                    onSelected: (selected) {
                      // Filter handled in the list
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: const Icon(Icons.groups, size: 18),
                    label: const Text('Group'),
                    selected: publicClasses.any((c) => c.isGroupClass),
                    onSelected: (selected) {
                      // Filter handled in the list
                    },
                  ),
                ],
              ),
            ),
            
            // Class list
            Expanded(
              child: publicClasses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 64, color: AppTheme.neutral400),
                          const SizedBox(height: AppTheme.spacingL),
                          Text('No classes found', style: AppTheme.headline6),
                          const SizedBox(height: AppTheme.spacingS),
                          Text('Try adjusting your filters', style: AppTheme.bodyMedium),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      itemCount: publicClasses.length,
                      itemBuilder: (context, index) {
                        final classItem = publicClasses[index];
                        return _buildClassCard(classItem);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassCard(Class classItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetailScreen(classItem: classItem),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(
                      classItem.locationType == LocationType.online
                          ? Icons.videocam
                          : Icons.location_on,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem.title,
                          style: AppTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: _getCoachName(classItem.coachId),
                          builder: (context, snapshot) {
                            return Text(
                              'by ${snapshot.data ?? 'Coach'}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              classItem.isGroupClass ? Icons.groups : Icons.person,
                              size: 14,
                              color: AppTheme.neutral600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              classItem.isGroupClass ? 'Group Class' : '1-on-1 Private',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getCurrencySymbol(classItem.currency) + classItem.price.toStringAsFixed(0),
                        style: AppTheme.headline6.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        classItem.paymentSchedule.replaceAll('_', ' '),
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Description
              Text(
                classItem.description,
                style: AppTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Details
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    classItem.type.toString().split('.').last.toUpperCase(),
                  ),
                  _buildInfoChip(
                    classItem.locationType == LocationType.online ? Icons.computer : Icons.location_on,
                    classItem.locationType == LocationType.online ? 'Online' : 'In-Person',
                  ),
                  _buildInfoChip(
                    Icons.schedule,
                    '${classItem.durationMinutes} min',
                  ),
                  _buildInfoChip(
                    Icons.people,
                    '${classItem.enrolledStudentIds.length}/${classItem.maxStudents}',
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Enroll button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassDetailScreen(classItem: classItem),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('View Details & Enroll'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.neutral600),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
        ),
      ],
    );
  }

  String _getCurrencySymbol(Currency currency) {
    switch (currency) {
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.gbp:
        return '£';
      case Currency.cad:
        return 'C\$';
      case Currency.aud:
        return 'A\$';
      case Currency.inr:
        return '₹';
    }
  }

  Future<String> _getCoachName(String coachId) async {
    try {
      final profile = await FirestoreService().getCoachProfile(coachId);
      if (profile != null) {
        return profile.name;
      }
      // Fallback: try to get user name
      final user = await FirestoreService().getUser(coachId);
      return user?.name ?? 'Coach';
    } catch (e) {
      return 'Coach';
    }
  }

  Widget _buildCoachesTab() {
    return FutureBuilder<List<CoachProfile>>(
      future: FirestoreService().getAllCoachProfiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 64, color: AppTheme.neutral400),
                const SizedBox(height: 16),
                Text(
                  'No coaches available yet',
                  style: AppTheme.headline6.copyWith(color: AppTheme.neutral600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back soon for amazing coaches!',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral500),
                ),
              ],
            ),
          );
        }
        
        var coaches = snapshot.data!;
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          coaches = coaches.where((coach) =>
            coach.name.toLowerCase().contains(_searchQuery) ||
            (coach.headline?.toLowerCase().contains(_searchQuery) ?? false) ||
            coach.categories.any((cat) => cat.toLowerCase().contains(_searchQuery))
          ).toList();
        }
        
        if (coaches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppTheme.neutral400),
                const SizedBox(height: 16),
                Text(
                  'No coaches found matching "$_searchQuery"',
                  style: AppTheme.headline6.copyWith(color: AppTheme.neutral600),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppTheme.getCrossAxisCount(context, mobile: 1, tablet: 2, desktop: 3),
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: coaches.length,
          itemBuilder: (context, index) {
            return _buildCoachCard(coaches[index]);
          },
        );
      },
    );
  }

  Widget _buildCoachCard(CoachProfile coach) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/coach/${coach.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: coach.photoUrl != null ? NetworkImage(coach.photoUrl!) : null,
                child: coach.photoUrl == null
                    ? Text(
                        coach.name.isNotEmpty ? coach.name[0].toUpperCase() : 'C',
                        style: const TextStyle(fontSize: 32, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                coach.name,
                style: AppTheme.headline6,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                coach.headline ?? 'Coach',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (coach.yearsExperience != null)
                Text(
                  '${coach.yearsExperience} years experience',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.successColor),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: coach.categories.take(2).map((cat) => Chip(
                  label: Text(
                    cat,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  context.push('/coach/${coach.id}');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('View Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

