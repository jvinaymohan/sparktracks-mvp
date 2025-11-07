import '../models/class_model.dart';
import 'ai_class_suggestions_service.dart';

/// Class Templates Service (v3.0)
/// Manages pre-built class templates for coaches
class ClassTemplatesService {
  /// Get all templates for a specialization
  static List<ClassTemplate> getTemplates(String specialization) {
    final suggestions = AIClassSuggestionsService.getSuggestions(specialization);
    return suggestions.map((s) => ClassTemplate.fromSuggestion(s)).toList();
  }
  
  /// Get popular templates across all categories
  static List<ClassTemplate> getPopularTemplates() {
    final List<ClassTemplate> popular = [];
    
    // Add most popular from each category
    popular.addAll(getTemplates('tennis').take(2));
    popular.addAll(getTemplates('piano').take(2));
    popular.addAll(getTemplates('math').take(2));
    popular.addAll(getTemplates('chess').take(1));
    
    return popular;
  }
  
  /// Save a custom template created by coach
  static Future<void> saveCustomTemplate(ClassTemplate template) async {
    // TODO: Implement saving to Firestore
    // await FirestoreService().saveClassTemplate(template);
  }
  
  /// Get coach's saved custom templates
  static Future<List<ClassTemplate>> getCoachTemplates(String coachId) async {
    // TODO: Implement fetching from Firestore
    return [];
  }
}

/// Class Template Model
class ClassTemplate {
  final String id;
  final String title;
  final String description;
  final String category;
  final String subcategory;
  final SkillLevel skillLevel;
  final int minAge;
  final int maxAge;
  final int minStudents;
  final int maxStudents;
  final int duration;
  final PricingModel pricingModel;
  final double suggestedPrice;
  final List<String> materials;
  final List<String> prerequisites;
  final bool includesProgressReports;
  final bool includesHomework;
  final bool offersTrial;
  final String? marketInsight;
  
  ClassTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.skillLevel,
    required this.minAge,
    required this.maxAge,
    required this.minStudents,
    required this.maxStudents,
    required this.duration,
    required this.pricingModel,
    required this.suggestedPrice,
    this.materials = const [],
    this.prerequisites = const [],
    this.includesProgressReports = false,
    this.includesHomework = false,
    this.offersTrial = true,
    this.marketInsight,
  });
  
  /// Create template from AI suggestion
  factory ClassTemplate.fromSuggestion(ClassSuggestion suggestion) {
    // Parse group size
    int minStudents = 1;
    int maxStudents = 10;
    if (suggestion.recommendedGroupSize.contains('-')) {
      final parts = suggestion.recommendedGroupSize.split('-');
      minStudents = int.tryParse(parts[0]) ?? 1;
      maxStudents = int.tryParse(parts[1]) ?? 10;
    } else if (suggestion.recommendedGroupSize == '1') {
      minStudents = 1;
      maxStudents = 1;
    }
    
    // Parse skill level
    SkillLevel skillLevel;
    switch (suggestion.skillLevel.toLowerCase()) {
      case 'beginner':
        skillLevel = SkillLevel.beginner;
        break;
      case 'intermediate':
        skillLevel = SkillLevel.intermediate;
        break;
      case 'advanced':
        skillLevel = SkillLevel.advanced;
        break;
      case 'all levels':
        skillLevel = SkillLevel.allLevels;
        break;
      default:
        skillLevel = SkillLevel.beginner;
    }
    
    // Parse suggested price (use middle of range)
    double suggestedPrice = 50;
    if (suggestion.priceRange.contains('-')) {
      final cleaned = suggestion.priceRange.replaceAll('\$', '').replaceAll(' ', '');
      final parts = cleaned.split('-');
      final low = double.tryParse(parts[0]) ?? 50;
      final high = double.tryParse(parts[1]) ?? 50;
      suggestedPrice = (low + high) / 2;
    }
    
    return ClassTemplate(
      id: 'template_${suggestion.subcategory.toLowerCase()}_${suggestion.skillLevel.toLowerCase()}',
      title: suggestion.title,
      description: suggestion.description,
      category: suggestion.category,
      subcategory: suggestion.subcategory,
      skillLevel: skillLevel,
      minAge: suggestion.minAge,
      maxAge: suggestion.maxAge,
      minStudents: minStudents,
      maxStudents: maxStudents,
      duration: suggestion.recommendedDuration,
      pricingModel: maxStudents == 1 ? PricingModel.perSession : PricingModel.perSession,
      suggestedPrice: suggestedPrice,
      materials: _getDefaultMaterials(suggestion.subcategory),
      prerequisites: _getDefaultPrerequisites(suggestion.skillLevel),
      includesProgressReports: suggestion.skillLevel != 'Beginner',
      includesHomework: suggestion.skillLevel == 'Intermediate' || suggestion.skillLevel == 'Advanced',
      offersTrial: true,
      marketInsight: suggestion.marketInsight,
    );
  }
  
  /// Get default materials based on specialization
  static List<String> _getDefaultMaterials(String subcategory) {
    switch (subcategory.toLowerCase()) {
      case 'tennis':
        return ['Tennis racket', 'Water bottle', 'Athletic shoes', 'Sunscreen'];
      case 'piano':
        return ['Sheet music (will be provided)', 'Notebook for notes'];
      case 'math':
        return ['Pencil', 'Paper', 'Calculator (scientific)', 'Textbook'];
      case 'chess':
        return ['Chess set (provided)', 'Notebook'];
      case 'swimming':
        return ['Swimsuit', 'Towel', 'Goggles', 'Swim cap'];
      case 'guitar':
        return ['Guitar', 'Tuner', 'Picks', 'Music stand'];
      case 'soccer':
        return ['Cleats', 'Shin guards', 'Water bottle', 'Soccer ball'];
      default:
        return [];
    }
  }
  
  /// Get default prerequisites based on skill level
  static List<String> _getDefaultPrerequisites(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'beginner':
        return ['None - beginners welcome!'];
      case 'intermediate':
        return ['6+ months of experience recommended'];
      case 'advanced':
        return ['18+ months of experience required'];
      case 'expert':
        return ['Competitive experience required'];
      default:
        return [];
    }
  }
  
  /// Apply template to create a new class (returns partial class data)
  static Map<String, dynamic> applyTemplate(ClassTemplate template, String coachId) {
    return {
      'title': template.title,
      'description': template.description,
      'category': template.category,
      'subcategory': template.subcategory,
      'skillLevel': template.skillLevel,
      'minAge': template.minAge,
      'maxAge': template.maxAge,
      'minStudents': template.minStudents,
      'maxStudents': template.maxStudents,
      'durationMinutes': template.duration,
      'price': template.suggestedPrice,
      'materials': template.materials,
      'prerequisites': template.prerequisites,
      'includesProgressReports': template.includesProgressReports,
      'includesHomework': template.includesHomework,
      'offersTrial': template.offersTrial,
    };
  }
}

