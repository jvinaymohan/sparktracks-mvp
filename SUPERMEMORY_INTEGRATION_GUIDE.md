# 🧠 Supermemory AI Integration Guide

## Overview

Supermemory is now integrated into your Sparktracks app! It provides AI-powered memory and knowledge management to:
- Track user preferences and behavior
- Provide personalized class recommendations
- Give insights about child progress
- Suggest relevant coaches based on history
- Enhance onboarding with smart tips

---

## 🚀 Quick Start

### 1. Initialize Supermemory in `lib/main.dart`

Add the Supermemory provider to your app:

```dart
import 'providers/supermemory_provider.dart';

// In your main() function, add to MultiProvider:
MultiProvider(
  providers: [
    // ... existing providers ...
    ChangeNotifierProvider(
      create: (_) => SupermemoryProvider(
        apiKey: 'sm_yh1fUH6A74UcuEZBNfCgcD_QObWVGHfZrpCMSEKbZDUEORjjqFeksOYHDgRoJaLSavqHCezyOZXqlIjkgWqlUBL',
        baseUrl: 'https://api.supermemory.ai',
      ),
    ),
  ],
  child: MyApp(),
)
```

### 2. Store API Key Securely (Recommended)

For production, store the API key in environment variables:

Create `lib/config/supermemory_config.dart`:
```dart
class SupermemoryConfig {
  static const String apiKey = String.fromEnvironment(
    'SUPERMEMORY_API_KEY',
    defaultValue: 'sm_yh1fUH6A74UcuEZBNfCgcD_QObWVGHfZrpCMSEKbZDUEORjjqFeksOYHDgRoJaLSavqHCezyOZXqlIjkgWqlUBL',
  );
}
```

---

## 📚 Usage Examples

### Example 1: Track Class Browsing

When a user views a class:

```dart
import 'package:provider/provider.dart';
import '../services/supermemory_service.dart';
import '../services/app_memory_helper.dart';

// In your class detail screen:
@override
void initState() {
  super.initState();
  _trackClassView();
}

Future<void> _trackClassView() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final userId = authProvider.currentUser?.id ?? '';
  
  final supermemoryProvider = Provider.of<SupermemoryProvider>(context, listen: false);
  final helper = AppMemoryHelper(supermemoryProvider._service);
  
  await helper.trackClassBrowsing(
    userId: userId,
    category: widget.classItem.category ?? 'General',
    className: widget.classItem.title,
  );
}
```

### Example 2: Get Personalized Class Recommendations

Show AI-powered recommendations on the parent dashboard:

```dart
import '../services/app_memory_helper.dart';

class ParentDashboardScreen extends StatefulWidget {
  // ...
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  String? _recommendations;
  bool _loadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _loadingRecommendations = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? '';
    
    final supermemoryProvider = Provider.of<SupermemoryProvider>(context, listen: false);
    final helper = AppMemoryHelper(supermemoryProvider._service);
    
    final recommendations = await helper.getClassRecommendations(userId);
    
    setState(() {
      _recommendations = recommendations;
      _loadingRecommendations = false;
    });
  }

  Widget _buildRecommendationsCard() {
    if (_loadingRecommendations) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recommendations == null) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.accentColor),
                SizedBox(width: 8),
                Text('AI Recommendations', style: AppTheme.headline6),
              ],
            ),
            SizedBox(height: 12),
            Text(_recommendations!),
          ],
        ),
      ),
    );
  }
}
```

### Example 3: Track Task Completion

Auto-track when tasks are completed:

```dart
// In your task completion handler:
Future<void> _completeTask(Task task) async {
  // ... existing completion logic ...
  
  // Track in Supermemory
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final userId = authProvider.currentUser?.id ?? '';
  
  final supermemoryProvider = Provider.of<SupermemoryProvider>(context, listen: false);
  final helper = AppMemoryHelper(supermemoryProvider._service);
  
  await helper.trackTaskCompletion(
    userId: userId,
    childId: task.childId,
    task: task,
  );
}
```

### Example 4: Get Child Progress Insights

Show AI insights about child's progress:

```dart
Future<void> _showProgressInsights(String childId) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final userId = authProvider.currentUser?.id ?? '';
  
  final supermemoryProvider = Provider.of<SupermemoryProvider>(context, listen: false);
  final helper = AppMemoryHelper(supermemoryProvider._service);
  
  // Show loading
  showDialog(
    context: context,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );
  
  final insights = await helper.getChildProgressInsights(
    userId: userId,
    childId: childId,
  );
  
  Navigator.pop(context); // Close loading
  
  if (insights != null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.insights, color: AppTheme.accentColor),
            SizedBox(width: 8),
            Text('AI Insights'),
          ],
        ),
        content: Text(insights),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}
```

### Example 5: Smart Onboarding Tips

Show personalized tips during welcome screen:

```dart
// In welcome_screen.dart:
Future<void> _loadOnboardingTips() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final userId = authProvider.currentUser?.id ?? '';
  final userType = authProvider.currentUser?.type ?? UserType.parent;
  
  final supermemoryProvider = Provider.of<SupermemoryProvider>(context, listen: false);
  final helper = AppMemoryHelper(supermemoryProvider._service);
  
  final tips = await helper.getOnboardingTips(userId, userType);
  
  if (tips != null && mounted) {
    setState(() {
      _aiTips = tips;
    });
  }
}
```

---

## 🎯 Practical Use Cases

### 1. **Smart Class Discovery**
Track which classes users browse and provide better recommendations

```dart
await helper.trackClassBrowsing(
  userId: currentUserId,
  category: 'Music',
  className: 'Piano Lessons for Beginners',
);
```

### 2. **Personalized Coach Suggestions**
Recommend coaches based on user preferences and history

```dart
final suggestions = await helper.getCoachRecommendations(
  userId: currentUserId,
  category: 'Sports',
  location: 'Austin, TX',
);
```

### 3. **Child Progress Analytics**
Get AI-generated insights about child's learning patterns

```dart
final insights = await helper.getChildProgressInsights(
  userId: parentId,
  childId: childId,
);
```

### 4. **Preference Learning**
Track user preferences over time

```dart
await helper.trackPreference(
  userId: currentUserId,
  preferenceType: 'class_time',
  preferenceValue: 'weekends_afternoon',
);

await helper.trackPreference(
  userId: currentUserId,
  preferenceType: 'learning_style',
  preferenceValue: 'one_on_one',
);
```

---

## 🔧 Advanced Usage

### Direct Search

Search the memory directly:

```dart
final supermemoryProvider = Provider.of<SupermemoryProvider>(context);

final results = await supermemoryProvider.search(
  'What chess coaches has this user viewed?'
);

for (var result in results) {
  print('${result.content} (score: ${result.score})');
}
```

### Add Custom Memory

Add any custom information:

```dart
await supermemoryProvider.addMemory(
  content: 'User completed onboarding successfully',
  metadata: {
    'user_id': userId,
    'timestamp': DateTime.now().toIso8601String(),
    'platform': 'web',
  },
);
```

### Get AI Insights

Ask Supermemory for insights:

```dart
final insight = await supermemoryProvider.getInsights(
  'Based on this user\'s activity, what class schedule would work best for them?'
);
```

---

## 📊 Integration Points

### Where to Add Supermemory Tracking:

1. **Browse Classes Screen**
   - Track class views
   - Track search queries
   - Track filter selections

2. **Class Enrollment**
   - Track enrollments
   - Track class preferences

3. **Task Management**
   - Track task completions
   - Track task categories
   - Track recurring patterns

4. **Coach Browsing**
   - Track coach profile views
   - Track review reading
   - Track booking attempts

5. **User Preferences**
   - Track location preferences
   - Track time preferences
   - Track price range preferences

---

## 🎨 UI Components

### Recommendation Card Widget

Create a reusable widget for showing AI recommendations:

```dart
class AIRecommendationCard extends StatelessWidget {
  final String title;
  final String recommendation;
  final VoidCallback? onAction;

  const AIRecommendationCard({
    Key? key,
    required this.title,
    required this.recommendation,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.headline6.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              recommendation,
              style: AppTheme.bodyMedium,
            ),
            if (onAction != null) ...[
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onAction,
                  child: Text('Explore'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 🔒 Security Notes

1. **Never commit API keys to git**
   - Use environment variables
   - Add to `.gitignore`

2. **User Privacy**
   - Only track necessary information
   - Respect user privacy preferences
   - Provide opt-out options

3. **Data Minimization**
   - Don't store sensitive information
   - Use user IDs instead of names
   - Anonymize data when possible

---

## 🐛 Troubleshooting

### Issue: "SupermemoryException: Search failed with status 401"
**Solution:** Check that your API key is correct and not expired

### Issue: "SupermemoryException: Search failed with status 429"
**Solution:** You've hit the rate limit. Implement caching or reduce frequency

### Issue: No recommendations returned
**Solution:** Ensure you've tracked enough user activity first (at least 5-10 interactions)

---

## 📈 Next Steps

1. **Test the Integration**
   - Browse some classes
   - Complete some tasks
   - Check if recommendations appear

2. **Add More Tracking Points**
   - Identify key user actions
   - Add tracking calls
   - Monitor what gets stored

3. **Build UI Components**
   - Create recommendation cards
   - Add "AI Insights" buttons
   - Show personalized tips

4. **Optimize**
   - Cache results
   - Batch tracking calls
   - Monitor performance

---

## 🎉 Benefits

With Supermemory integrated, your app will:
- ✅ Provide personalized class recommendations
- ✅ Offer smart coach suggestions
- ✅ Give insights about child progress
- ✅ Learn user preferences over time
- ✅ Improve onboarding experience
- ✅ Make smarter suggestions automatically

---

## 📞 Support

- Supermemory Docs: https://docs.supermemory.ai
- API Reference: https://api.supermemory.ai/docs
- Your API Key: `sm_yh1fUH6A74UcuEZBNfCgcD_QObWVGHfZrpCMSEKbZDUEORjjqFeksOYHDgRoJaLSavqHCezyOZXqlIjkgWqlUBL`

---

**Happy coding! 🚀 Your app is now smarter with AI-powered memory!**

