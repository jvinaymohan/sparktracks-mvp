import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/classes_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/class_model.dart';
import '../../utils/app_theme.dart';
import 'class_detail_screen.dart';

class BrowseClassesScreen extends StatefulWidget {
  const BrowseClassesScreen({super.key});

  @override
  State<BrowseClassesScreen> createState() => _BrowseClassesScreenState();
}

class _BrowseClassesScreenState extends State<BrowseClassesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  ClassType? _selectedType;
  LocationType? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Classes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search classes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: Consumer<ClassesProvider>(
        builder: (context, classesProvider, _) {
          // Get ONLY public classes
          // v3.0: Only show classes created by coaches (not test/default data)
          var publicClasses = classesProvider.classes.where((c) => 
            c.isPublic == true && 
            c.coachId.isNotEmpty &&
            c.category != null // Ensures it's a properly created class
          ).toList();
          
          // Apply filters
          if (_searchQuery.isNotEmpty) {
            publicClasses = publicClasses.where((c) =>
              c.title.toLowerCase().contains(_searchQuery) ||
              c.description.toLowerCase().contains(_searchQuery)
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
                      label: const Text('All'),
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
                      label: const Text('Online'),
                      selected: _selectedLocation == LocationType.online,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLocation = selected ? LocationType.online : null;
                        });
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
      ),
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
                        Row(
                          children: [
                            Icon(
                              classItem.isGroupClass ? Icons.groups : Icons.person,
                              size: 14,
                              color: AppTheme.neutral600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              classItem.isGroupClass ? 'Group Class' : 'Individual (1-on-1)',
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
}

