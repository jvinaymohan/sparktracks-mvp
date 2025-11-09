import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/classes_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';
import '../../models/coach_profile_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import 'class_detail_screen.dart';

/// Modern Browse Classes Screen - Optimized for Coach Advertisement
/// Beautiful cards, easy navigation, visual hierarchy
class BrowseClassesModern extends StatefulWidget {
  const BrowseClassesModern({super.key});

  @override
  State<BrowseClassesModern> createState() => _BrowseClassesModernState();
}

class _BrowseClassesModernState extends State<BrowseClassesModern> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  LocationType? _filterLocation;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          // Modern Header
          _buildModernHeader(isMobile, authProvider),
          
          // Search & Filters
          _buildSearchSection(isMobile),
          
          // Content Tabs
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildClassesGrid(isMobile),
                _buildCoachesGrid(isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(bool isMobile, AuthProvider authProvider) {
    return SliverAppBar(
      expandedHeight: isMobile ? 160 : 200,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF6B9D),
                const Color(0xFF8B5CF6),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Discover Amazing Classes',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find expert coaches and book instantly',
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 18,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFFF6B9D),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFFFF6B9D),
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.school_rounded), text: 'Classes'),
              Tab(icon: Icon(Icons.person_rounded), text: 'Coaches'),
            ],
          ),
        ),
      ),
      actions: [
        if (!authProvider.isLoggedIn) ...[
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => context.go('/register'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
            child: const Text('Join Beta', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            onPressed: () {
              final userType = authProvider.currentUser?.type;
              switch (userType) {
                case UserType.parent:
                  context.go('/parent-dashboard');
                  break;
                case UserType.coach:
                  context.go('/coach-dashboard');
                  break;
                case UserType.child:
                  context.go('/child-dashboard');
                  break;
                default:
                  context.go('/');
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _buildSearchSection(bool isMobile) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          children: [
            // Search Bar
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search classes, coaches, or activities...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 24),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFFF6B9D), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', _filterLocation == null, () {
                    setState(() => _filterLocation = null);
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Online', _filterLocation == LocationType.online, () {
                    setState(() => _filterLocation = LocationType.online);
                  }, Icons.computer_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('In-Person', _filterLocation == LocationType.inPerson, () {
                    setState(() => _filterLocation = LocationType.inPerson);
                  }, Icons.location_on_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap, [IconData? icon]) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (value) => onTap(),
      selectedColor: const Color(0xFFFF6B9D),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF6B7280),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      elevation: selected ? 4 : 0,
      shadowColor: const Color(0xFFFF6B9D).withOpacity(0.4),
    );
  }

  Widget _buildClassesGrid(bool isMobile) {
    return Consumer<ClassesProvider>(
      builder: (context, classesProvider, _) {
        var classes = classesProvider.classes.where((c) => c.isPublic == true).toList();
        
        // Apply filters
        if (_searchQuery.isNotEmpty) {
          classes = classes.where((c) =>
            c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (c.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
          ).toList();
        }
        
        if (_filterLocation != null) {
          classes = classes.where((c) => c.locationType == _filterLocation).toList();
        }
        
        if (classes.isEmpty) {
          return _buildEmptyState('No classes found', 'Try adjusting your filters or check back soon!');
        }
        
        return GridView.builder(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : (MediaQuery.of(context).size.width > 1200 ? 3 : 2),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isMobile ? 1.1 : 0.85,
          ),
          itemCount: classes.length,
          itemBuilder: (context, index) => _buildModernClassCard(classes[index], isMobile),
        );
      },
    );
  }

  Widget _buildModernClassCard(Class classItem, bool isMobile) {
    return FutureBuilder<String>(
      future: _getCoachName(classItem.coachId),
      builder: (context, snapshot) {
        final coachName = snapshot.data ?? 'Loading...';
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassDetailScreen(classItem: classItem),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image/Header Section
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor(classItem.category),
                        _getCategoryColor(classItem.category).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Category Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            classItem.category ?? 'Class',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ),
                      
                      // Location Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: classItem.locationType == LocationType.online
                                ? const Color(0xFF10B981)
                                : const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                classItem.locationType == LocationType.online
                                    ? Icons.computer_rounded
                                    : Icons.location_on_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                classItem.locationType == LocationType.online ? 'Online' : 'In-Person',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Class Type Indicator
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(classItem.category),
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          classItem.title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Coach Name
                        Row(
                          children: [
                            const Icon(Icons.person_rounded, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'by $coachName',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Description
                        Expanded(
                          child: Text(
                            classItem.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Footer Info
                        Row(
                          children: [
                            // Price
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.attach_money_rounded, size: 16, color: Color(0xFF10B981)),
                                  Text(
                                    '${classItem.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            
                            // Spots Available
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people_rounded, size: 14, color: Color(0xFF3B82F6)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${classItem.maxStudents - classItem.enrolledStudentIds.length} spots',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoachesGrid(bool isMobile) {
    return FutureBuilder<List<CoachProfile>>(
      future: FirestoreService().getAllCoachProfiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No coaches yet', 'Check back soon for expert coaches!');
        }
        
        var coaches = snapshot.data!;
        
        if (_searchQuery.isNotEmpty) {
          coaches = coaches.where((coach) =>
            coach.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (coach.bio?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            coach.categories.any((cat) => cat.toLowerCase().contains(_searchQuery.toLowerCase()))
          ).toList();
        }
        
        return GridView.builder(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : (MediaQuery.of(context).size.width > 1200 ? 3 : 2),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isMobile ? 1.3 : 0.9,
          ),
          itemCount: coaches.length,
          itemBuilder: (context, index) => _buildModernCoachCard(coaches[index], isMobile),
        );
      },
    );
  }

  Widget _buildModernCoachCard(CoachProfile coach, bool isMobile) {
    return GestureDetector(
      onTap: () => context.push('/coach/${coach.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6),
                    const Color(0xFF8B5CF6).withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: coach.photoUrl != null ? NetworkImage(coach.photoUrl!) : null,
                      child: coach.photoUrl == null
                          ? Text(
                              coach.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF8B5CF6),
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Verified Badge
                  if (coach.isVerified)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      coach.headline ?? 'Expert Coach',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Categories
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: coach.categories.take(3).map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cat,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF6B9D),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Spacer(),
                    
                    // Footer
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            coach.location?.city ?? 'Online',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFA500)),
                        const SizedBox(width: 4),
                        const Text(
                          '5.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getCoachName(String coachId) async {
    try {
      final user = await FirestoreService().getUser(coachId);
      return user?.name ?? 'Coach';
    } catch (e) {
      return 'Coach';
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'sports':
        return const Color(0xFF10B981);
      case 'music':
        return const Color(0xFF8B5CF6);
      case 'arts':
        return const Color(0xFFFF6B9D);
      case 'stem':
        return const Color(0xFF3B82F6);
      case 'academic':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'arts':
        return Icons.palette_rounded;
      case 'stem':
        return Icons.science_rounded;
      case 'academic':
        return Icons.menu_book_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}

