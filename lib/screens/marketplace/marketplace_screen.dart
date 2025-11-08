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
import '../classes/class_detail_screen.dart';

/// Public Marketplace - Browse Classes and Coaches
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
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
        title: const Text('Marketplace'),
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
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: TextField(
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
          ),
          
          // Category Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                'All',
                ...CoachingCategories.all,
              ].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Tab Content
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
        var publicClasses = classesProvider.classes.where((c) => 
          c.isPublic == true && 
          c.coachId.isNotEmpty
        ).toList();
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          publicClasses = publicClasses.where((c) =>
            c.title.toLowerCase().contains(_searchQuery) ||
            c.description.toLowerCase().contains(_searchQuery) ||
            (c.category?.toLowerCase().contains(_searchQuery) ?? false)
          ).toList();
        }
        
        // Apply category filter
        if (_selectedCategory != 'All') {
          publicClasses = publicClasses.where((c) =>
            c.category == _selectedCategory
          ).toList();
        }
        
        if (publicClasses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppTheme.neutral400),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No classes found matching "$_searchQuery"'
                      : 'No public classes available yet',
                  style: AppTheme.headline6.copyWith(color: AppTheme.neutral600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral500),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppTheme.getCrossAxisCount(context, mobile: 1, tablet: 2, desktop: 3),
            childAspectRatio: 1.3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: publicClasses.length,
          itemBuilder: (context, index) {
            return _buildClassCard(publicClasses[index]);
          },
        );
      },
    );
  }

  Widget _buildClassCard(Class classItem) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetailScreen(classItem: classItem),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Image or Placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(classItem.category),
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classItem.title,
                    style: AppTheme.headline6,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    classItem.description,
                    style: AppTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: AppTheme.neutral600),
                      const SizedBox(width: 4),
                      Text(
                        '${classItem.enrolledStudentIds.length}/${classItem.maxStudents}',
                        style: AppTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.attach_money, size: 14, color: AppTheme.successColor),
                      Text(
                        '\$${classItem.price.toStringAsFixed(0)}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (classItem.category != null)
                    Chip(
                      label: Text(
                        classItem.category!,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        
        // Apply category filter
        if (_selectedCategory != 'All') {
          coaches = coaches.where((coach) =>
            coach.categories.contains(_selectedCategory)
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
            childAspectRatio: 0.8,
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

  IconData _getCategoryIcon(String? category) {
    if (category == null || category.isEmpty) return Icons.school;
    
    final cat = category.toLowerCase();
    if (cat.contains('sports')) return Icons.sports_tennis;
    if (cat.contains('music')) return Icons.music_note;
    if (cat.contains('academic')) return Icons.book;
    if (cat.contains('arts')) return Icons.palette;
    if (cat.contains('strategy')) return Icons.psychology;
    if (cat.contains('life')) return Icons.psychology_alt;
    
    return Icons.school;
  }
}

