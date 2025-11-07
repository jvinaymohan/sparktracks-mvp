/// AI-Powered Class Suggestion Engine
/// Provides intelligent class suggestions based on coach's specialization

class AIClassSuggestionsService {
  /// Get class suggestions based on specialization
  static List<ClassSuggestion> getSuggestions(String specialization) {
    return _suggestions[specialization.toLowerCase()] ?? [];
  }

  /// Get all available specializations for a category
  static List<String> getSpecializations(String category) {
    switch (category) {
      case 'Sports & Fitness':
        return ['Tennis', 'Swimming', 'Soccer', 'Basketball', 'Golf', 
                'Martial Arts', 'Yoga', 'Dance', 'Gymnastics'];
      case 'Music':
        return ['Piano', 'Guitar', 'Violin', 'Drums', 'Voice/Singing',
                'Flute', 'Clarinet', 'Trumpet', 'Saxophone'];
      case 'Academic':
        return ['Math', 'Science', 'English/Writing', 'Foreign Languages',
                'Test Prep', 'Homework Help', 'Reading', 'Computer Science'];
      case 'Arts & Creativity':
        return ['Painting', 'Drawing', 'Photography', 'Chess',
                'Coding/Programming', 'Graphic Design'];
      case 'Life Skills':
        return ['Public Speaking', 'Leadership', 'Study Skills', 
                'Time Management'];
      default:
        return [];
    }
  }

  static final Map<String, List<ClassSuggestion>> _suggestions = {
    'tennis': [
      ClassSuggestion(
        title: 'Beginner Tennis (Ages 6-10)',
        description: 'Perfect for kids new to tennis. Focus on fundamentals, hand-eye coordination, and having fun while learning the basics of tennis.',
        category: 'Sports & Fitness',
        subcategory: 'Tennis',
        skillLevel: 'Beginner',
        minAge: 6,
        maxAge: 10,
        recommendedGroupSize: '4-6',
        recommendedDuration: 60,
        recommendedFrequency: 'Weekly',
        priceRange: '\$30-40',
        tags: ['beginner', 'kids', 'group', 'fundamentals'],
        popularity: 'High',
        marketInsight: 'High demand for kids beginner classes in your area',
      ),
      ClassSuggestion(
        title: 'Intermediate Tennis (Ages 11-15)',
        description: 'For students with 6+ months experience. Focus on stroke development, strategy, and match play.',
        category: 'Sports & Fitness',
        subcategory: 'Tennis',
        skillLevel: 'Intermediate',
        minAge: 11,
        maxAge: 15,
        recommendedGroupSize: '4-6',
        recommendedDuration: 90,
        recommendedFrequency: 'Twice weekly',
        priceRange: '\$35-45',
        tags: ['intermediate', 'teens', 'group', 'strategy'],
        popularity: 'Medium',
        marketInsight: 'Growing segment with good retention',
      ),
      ClassSuggestion(
        title: 'Tournament Preparation',
        description: 'Advanced training for competitive players. Private lessons focusing on match strategy, mental game, and performance optimization.',
        category: 'Sports & Fitness',
        subcategory: 'Tennis',
        skillLevel: 'Advanced',
        minAge: 10,
        maxAge: 18,
        recommendedGroupSize: '1-2',
        recommendedDuration: 60,
        recommendedFrequency: 'Flexible',
        priceRange: '\$60-80',
        tags: ['advanced', 'competitive', 'private', 'tournament'],
        popularity: 'Medium',
        marketInsight: 'Premium pricing opportunity, lower volume',
      ),
      ClassSuggestion(
        title: 'Adult Tennis Fitness',
        description: 'Fun, social tennis class for adults focused on fitness, skill development, and stress relief.',
        category: 'Sports & Fitness',
        subcategory: 'Tennis',
        skillLevel: 'All Levels',
        minAge: 18,
        maxAge: 65,
        recommendedGroupSize: '6-10',
        recommendedDuration: 75,
        recommendedFrequency: 'Twice weekly',
        priceRange: '\$25-35',
        tags: ['adult', 'fitness', 'group', 'social'],
        popularity: 'Growing',
        marketInsight: 'Emerging market, good for filling morning slots',
      ),
    ],
    'piano': [
      ClassSuggestion(
        title: 'Beginner Piano (Ages 5-8)',
        description: 'Introduction to piano for young children. Focus on note reading, hand position, simple melodies, and developing love for music.',
        category: 'Music',
        subcategory: 'Piano',
        skillLevel: 'Beginner',
        minAge: 5,
        maxAge: 8,
        recommendedGroupSize: '1',
        recommendedDuration: 30,
        recommendedFrequency: 'Weekly',
        priceRange: '\$40-60',
        tags: ['beginner', 'kids', 'private', 'fundamentals'],
        popularity: 'Very High',
        marketInsight: 'Highest demand segment, year-round interest',
      ),
      ClassSuggestion(
        title: 'Intermediate Piano (Ages 9-14)',
        description: 'For students with 1+ years experience. Focus on technique, music theory, repertoire building, and performance preparation.',
        category: 'Music',
        subcategory: 'Piano',
        skillLevel: 'Intermediate',
        minAge: 9,
        maxAge: 14,
        recommendedGroupSize: '1',
        recommendedDuration: 45,
        recommendedFrequency: 'Weekly',
        priceRange: '\$50-70',
        tags: ['intermediate', 'kids', 'private', 'performance'],
        popularity: 'High',
        marketInsight: 'Good retention, parents invested in progress',
      ),
      ClassSuggestion(
        title: 'Adult Beginner Piano',
        description: 'Never too late to learn! Piano lessons for adults focusing on popular songs, music reading, and achieving personal goals.',
        category: 'Music',
        subcategory: 'Piano',
        skillLevel: 'Beginner',
        minAge: 18,
        maxAge: 100,
        recommendedGroupSize: '1',
        recommendedDuration: 45,
        recommendedFrequency: 'Weekly or bi-weekly',
        priceRange: '\$50-70',
        tags: ['beginner', 'adult', 'private', 'flexible'],
        popularity: 'Medium',
        marketInsight: 'Growing market, flexible scheduling',
      ),
      ClassSuggestion(
        title: 'Piano & Music Theory',
        description: 'Combined piano and theory lessons for students preparing for exams or advancing their musical understanding.',
        category: 'Music',
        subcategory: 'Piano',
        skillLevel: 'Intermediate',
        minAge: 10,
        maxAge: 18,
        recommendedGroupSize: '1-2',
        recommendedDuration: 60,
        recommendedFrequency: 'Weekly',
        priceRange: '\$60-80',
        tags: ['intermediate', 'theory', 'exams', 'private'],
        popularity: 'Medium',
        marketInsight: 'Premium pricing for exam preparation',
      ),
    ],
    'math': [
      ClassSuggestion(
        title: 'Elementary Math Tutoring (Grades 1-5)',
        description: 'Fun, engaging math tutoring covering addition, subtraction, multiplication, division, and problem-solving skills.',
        category: 'Academic',
        subcategory: 'Math',
        skillLevel: 'Elementary',
        minAge: 6,
        maxAge: 11,
        recommendedGroupSize: '1-3',
        recommendedDuration: 45,
        recommendedFrequency: 'Weekly or twice weekly',
        priceRange: '\$35-50',
        tags: ['elementary', 'fundamentals', 'small_group'],
        popularity: 'Very High',
        marketInsight: 'Year-round demand, especially during school year',
      ),
      ClassSuggestion(
        title: 'Algebra & Pre-Algebra (Grades 6-9)',
        description: 'Master algebra concepts including equations, functions, graphing, and word problems. Build confidence in math.',
        category: 'Academic',
        subcategory: 'Math',
        skillLevel: 'Middle School',
        minAge: 11,
        maxAge: 15,
        recommendedGroupSize: '1-2',
        recommendedDuration: 60,
        recommendedFrequency: 'Twice weekly',
        priceRange: '\$45-65',
        tags: ['algebra', 'middle_school', 'private'],
        popularity: 'Very High',
        marketInsight: 'Critical transition period, parents very motivated',
      ),
      ClassSuggestion(
        title: 'SAT/ACT Math Prep',
        description: 'Focused test preparation for SAT and ACT math sections. Strategies, practice problems, and confidence building.',
        category: 'Academic',
        subcategory: 'Math',
        skillLevel: 'Test Prep',
        minAge: 14,
        maxAge: 18,
        recommendedGroupSize: '1-4',
        recommendedDuration: 90,
        recommendedFrequency: 'Twice weekly',
        priceRange: '\$60-90',
        tags: ['test_prep', 'high_school', 'SAT', 'ACT'],
        popularity: 'High',
        marketInsight: 'Premium pricing, seasonal demand (fall/spring)',
      ),
    ],
    'chess': [
      ClassSuggestion(
        title: 'Chess for Beginners (Ages 6-12)',
        description: 'Learn chess from scratch! Rules, basic strategies, opening principles, and simple tactics in a fun, engaging environment.',
        category: 'Arts & Creativity',
        subcategory: 'Chess',
        skillLevel: 'Beginner',
        minAge: 6,
        maxAge: 12,
        recommendedGroupSize: '4-8',
        recommendedDuration: 60,
        recommendedFrequency: 'Weekly',
        priceRange: '\$20-30',
        tags: ['beginner', 'kids', 'group', 'fundamentals'],
        popularity: 'High',
        marketInsight: 'Growing interest, especially after Queen\'s Gambit',
      ),
      ClassSuggestion(
        title: 'Intermediate Chess Strategy',
        description: 'For players who know the basics. Focus on middle game strategy, tactics, endgame techniques, and tournament play.',
        category: 'Arts & Creativity',
        subcategory: 'Chess',
        skillLevel: 'Intermediate',
        minAge: 8,
        maxAge: 16,
        recommendedGroupSize: '4-6',
        recommendedDuration: 90,
        recommendedFrequency: 'Weekly',
        priceRange: '\$30-45',
        tags: ['intermediate', 'strategy', 'tournament'],
        popularity: 'Medium',
        marketInsight: 'Dedicated students, good retention',
      ),
      ClassSuggestion(
        title: 'Chess Tournament Preparation',
        description: 'Advanced training for competitive chess players. Opening preparation, analysis, game review, and mental preparation.',
        category: 'Arts & Creativity',
        subcategory: 'Chess',
        skillLevel: 'Advanced',
        minAge: 10,
        maxAge: 18,
        recommendedGroupSize: '1-3',
        recommendedDuration: 120,
        recommendedFrequency: 'Twice weekly',
        priceRange: '\$50-75',
        tags: ['advanced', 'tournament', 'competitive'],
        popularity: 'Low',
        marketInsight: 'Niche market, premium pricing possible',
      ),
    ],
    // Add more specializations here...
  };
}

class ClassSuggestion {
  final String title;
  final String description;
  final String category;
  final String subcategory;
  final String skillLevel;
  final int minAge;
  final int maxAge;
  final String recommendedGroupSize;
  final int recommendedDuration; // minutes
  final String recommendedFrequency;
  final String priceRange;
  final List<String> tags;
  final String popularity; // 'Very High', 'High', 'Medium', 'Low'
  final String marketInsight;

  ClassSuggestion({
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.skillLevel,
    required this.minAge,
    required this.maxAge,
    required this.recommendedGroupSize,
    required this.recommendedDuration,
    required this.recommendedFrequency,
    required this.priceRange,
    required this.tags,
    required this.popularity,
    required this.marketInsight,
  });

  /// Convert suggestion to a class template that can be used
  Map<String, dynamic> toClassTemplate() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'skillLevel': skillLevel,
      'minAge': minAge,
      'maxAge': maxAge,
      'duration': recommendedDuration,
      'tags': tags,
    };
  }
}

