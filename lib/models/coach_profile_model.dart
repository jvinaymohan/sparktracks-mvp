import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'coach_profile_model.g.dart';

/// Enhanced Coach Profile Model for v3.0
/// Comprehensive profile with location, languages, expertise, and marketing features

@JsonSerializable(explicitToJson: true)
class CoachProfile {
  final String id; // userId
  final String name;
  final String? headline; // e.g., "Expert Tennis Coach | 15 Years Experience"
  final String? bio;
  final String? photoUrl;
  final String? profileVideoUrl;
  
  // Location Information
  final CoachLocation? location;
  
  // Languages
  final List<LanguageSkill> languages;
  
  // Expertise
  final List<String> categories; // ['Sports', 'Music', etc.]
  final List<String> specializations; // ['Tennis', 'Piano', etc.]
  final List<Certification> certifications;
  final List<Education> education;
  final List<String> awards;
  
  // Teaching Information
  final String? teachingPhilosophy;
  final List<String> ageGroups; // ['kids_5_10', 'teens_11_17', 'adults_18+']
  final List<String> skillLevels; // ['beginner', 'intermediate', 'advanced']
  final List<String> classTypes; // ['group', 'individual', 'hybrid']
  final int? yearsExperience;
  
  // Availability
  final Map<String, bool>? availableDays; // {monday: true, tuesday: false, ...}
  final String? availableTimeRange; // e.g., "9 AM - 5 PM"
  
  // Social & Marketing
  final List<String> galleryUrls;
  final List<Testimonial> testimonials;
  final double? rating; // Average rating
  final int? totalReviews;
  final String? website;
  final Map<String, String>? socialMedia; // {facebook: url, instagram: url, ...}
  
  // Business Information
  final bool isVerified;
  final bool isActive;
  final int? totalStudents;
  final int? totalClasses;
  final DateTime? joinedDate;
  
  // Preferences
  final Map<String, dynamic> preferences;
  
  CoachProfile({
    required this.id,
    required this.name,
    this.headline,
    this.bio,
    this.photoUrl,
    this.profileVideoUrl,
    this.location,
    this.languages = const [],
    this.categories = const [],
    this.specializations = const [],
    this.certifications = const [],
    this.education = const [],
    this.awards = const [],
    this.teachingPhilosophy,
    this.ageGroups = const [],
    this.skillLevels = const [],
    this.classTypes = const [],
    this.yearsExperience,
    this.availableDays,
    this.availableTimeRange,
    this.galleryUrls = const [],
    this.testimonials = const [],
    this.rating,
    this.totalReviews,
    this.website,
    this.socialMedia,
    this.isVerified = false,
    this.isActive = true,
    this.totalStudents,
    this.totalClasses,
    this.joinedDate,
    this.preferences = const {},
  });

  factory CoachProfile.fromJson(Map<String, dynamic> json) => _$CoachProfileFromJson(json);
  Map<String, dynamic> toJson() => _$CoachProfileToJson(this);

  CoachProfile copyWith({
    String? id,
    String? name,
    String? headline,
    String? bio,
    String? photoUrl,
    String? profileVideoUrl,
    CoachLocation? location,
    List<LanguageSkill>? languages,
    List<String>? categories,
    List<String>? specializations,
    List<Certification>? certifications,
    List<Education>? education,
    List<String>? awards,
    String? teachingPhilosophy,
    List<String>? ageGroups,
    List<String>? skillLevels,
    List<String>? classTypes,
    int? yearsExperience,
    Map<String, bool>? availableDays,
    String? availableTimeRange,
    List<String>? galleryUrls,
    List<Testimonial>? testimonials,
    double? rating,
    int? totalReviews,
    String? website,
    Map<String, String>? socialMedia,
    bool? isVerified,
    bool? isActive,
    int? totalStudents,
    int? totalClasses,
    DateTime? joinedDate,
    Map<String, dynamic>? preferences,
  }) {
    return CoachProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      profileVideoUrl: profileVideoUrl ?? this.profileVideoUrl,
      location: location ?? this.location,
      languages: languages ?? this.languages,
      categories: categories ?? this.categories,
      specializations: specializations ?? this.specializations,
      certifications: certifications ?? this.certifications,
      education: education ?? this.education,
      awards: awards ?? this.awards,
      teachingPhilosophy: teachingPhilosophy ?? this.teachingPhilosophy,
      ageGroups: ageGroups ?? this.ageGroups,
      skillLevels: skillLevels ?? this.skillLevels,
      classTypes: classTypes ?? this.classTypes,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      availableDays: availableDays ?? this.availableDays,
      availableTimeRange: availableTimeRange ?? this.availableTimeRange,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      testimonials: testimonials ?? this.testimonials,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      totalStudents: totalStudents ?? this.totalStudents,
      totalClasses: totalClasses ?? this.totalClasses,
      joinedDate: joinedDate ?? this.joinedDate,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Calculate profile completion percentage
  int getProfileCompletionPercentage() {
    int completed = 0;
    int total = 15;

    if (headline != null && headline!.isNotEmpty) completed++;
    if (bio != null && bio!.isNotEmpty) completed++;
    if (photoUrl != null && photoUrl!.isNotEmpty) completed++;
    if (location != null) completed++;
    if (languages.isNotEmpty) completed++;
    if (categories.isNotEmpty) completed++;
    if (specializations.isNotEmpty) completed++;
    if (certifications.isNotEmpty) completed++;
    if (teachingPhilosophy != null && teachingPhilosophy!.isNotEmpty) completed++;
    if (ageGroups.isNotEmpty) completed++;
    if (skillLevels.isNotEmpty) completed++;
    if (classTypes.isNotEmpty) completed++;
    if (yearsExperience != null) completed++;
    if (availableDays != null && availableDays!.isNotEmpty) completed++;
    if (galleryUrls.isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }
}

@JsonSerializable()
class CoachLocation {
  final String? address;
  final String city;
  final String state;
  final String? zipCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final int? serviceRadiusMiles; // How far coach will travel
  final List<String> travelOptions; // ['coach_location', 'travel_to_student', 'online']

  CoachLocation({
    this.address,
    required this.city,
    required this.state,
    this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.serviceRadiusMiles,
    this.travelOptions = const ['coach_location'],
  });

  factory CoachLocation.fromJson(Map<String, dynamic> json) => _$CoachLocationFromJson(json);
  Map<String, dynamic> toJson() => _$CoachLocationToJson(this);

  String get displayLocation => '$city, $state';
  String get fullDisplayLocation => address != null 
      ? '$address, $city, $state $zipCode'
      : '$city, $state';
}

@JsonSerializable()
class LanguageSkill {
  final String language; // e.g., 'English', 'Spanish', 'Mandarin'
  final String proficiency; // 'native', 'fluent', 'conversational', 'basic'

  LanguageSkill({
    required this.language,
    required this.proficiency,
  });

  factory LanguageSkill.fromJson(Map<String, dynamic> json) => _$LanguageSkillFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageSkillToJson(this);
}

@JsonSerializable()
class Certification {
  final String name;
  final String? issuer;
  final int? year;
  final String? certificateUrl; // URL to uploaded certificate
  final String? expiryDate;

  Certification({
    required this.name,
    this.issuer,
    this.year,
    this.certificateUrl,
    this.expiryDate,
  });

  factory Certification.fromJson(Map<String, dynamic> json) => _$CertificationFromJson(json);
  Map<String, dynamic> toJson() => _$CertificationToJson(this);
}

@JsonSerializable()
class Education {
  final String degree; // e.g., "Bachelor of Music"
  final String institution;
  final int? graduationYear;
  final String? fieldOfStudy;

  Education({
    required this.degree,
    required this.institution,
    this.graduationYear,
    this.fieldOfStudy,
  });

  factory Education.fromJson(Map<String, dynamic> json) => _$EducationFromJson(json);
  Map<String, dynamic> toJson() => _$EducationToJson(this);
}

@JsonSerializable()
class Testimonial {
  final String id;
  final String studentName;
  final String? studentPhotoUrl;
  final String text;
  final double rating; // 1-5
  final DateTime date;
  final bool isVerified;
  final String? relationship; // 'parent_of_student', 'student', 'fellow_coach'

  Testimonial({
    required this.id,
    required this.studentName,
    this.studentPhotoUrl,
    required this.text,
    required this.rating,
    required this.date,
    this.isVerified = false,
    this.relationship,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) => _$TestimonialFromJson(json);
  Map<String, dynamic> toJson() => _$TestimonialToJson(this);
}

/// Coaching category definitions
class CoachingCategories {
  static const String sports = 'Sports & Fitness';
  static const String music = 'Music';
  static const String academic = 'Academic';
  static const String arts = 'Arts & Creativity';
  static const String strategyGames = 'Strategy & Board Games';
  static const String lifeSkills = 'Life Skills';
  static const String other = 'Other/Custom';

  static List<String> get all => [
    sports, 
    music, 
    academic, 
    arts, 
    strategyGames, 
    lifeSkills, 
    other
  ];

  static Map<String, List<String>> get specializations => {
    sports: [
      'Tennis',
      'Swimming',
      'Soccer',
      'Basketball',
      'Golf',
      'Martial Arts (Karate, Taekwondo, etc.)',
      'Yoga',
      'Dance (Ballet, Hip Hop, etc.)',
      'Gymnastics',
      'Track & Field',
      'Baseball',
      'Volleyball',
      'Badminton',
      'Table Tennis',
      'Cricket',
      'Ice Skating',
      'Skiing',
      'Rock Climbing',
      'Cycling',
      'Boxing',
      'Wrestling',
      'Fencing',
      'Archery',
      'Horseback Riding',
      'Other Sport',
    ],
    music: [
      'Piano',
      'Guitar (Acoustic/Electric)',
      'Violin',
      'Drums',
      'Voice/Singing',
      'Flute',
      'Clarinet',
      'Trumpet',
      'Saxophone',
      'Cello',
      'Ukulele',
      'Bass Guitar',
      'Harp',
      'Music Theory',
      'Music Composition',
      'Other Instrument',
    ],
    academic: [
      'Math (Elementary)',
      'Math (Middle School)',
      'Math (High School)',
      'Algebra',
      'Geometry',
      'Calculus',
      'Statistics',
      'Science (General)',
      'Biology',
      'Chemistry',
      'Physics',
      'English/Writing',
      'Reading Comprehension',
      'Grammar & Vocabulary',
      'Foreign Languages (Spanish)',
      'Foreign Languages (French)',
      'Foreign Languages (Mandarin)',
      'Foreign Languages (Other)',
      'Test Prep (SAT/ACT)',
      'Test Prep (AP Exams)',
      'Homework Help',
      'History (US)',
      'History (World)',
      'Geography',
      'Computer Science',
      'Other Academic',
    ],
    arts: [
      'Painting (Watercolor)',
      'Painting (Acrylic)',
      'Painting (Oil)',
      'Drawing',
      'Sketching',
      'Digital Art',
      'Photography',
      'Coding/Programming',
      'Web Design',
      'Graphic Design',
      'Sculpture',
      'Pottery',
      'Ceramics',
      'Jewelry Making',
      'Origami',
      'Calligraphy',
      'Animation',
      'Video Editing',
      'Other Art Form',
    ],
    strategyGames: [
      'Chess',
      'Checkers',
      'Go',
      'Shogi',
      'Backgammon',
      'Bridge',
      'Poker',
      'Rubik\'s Cube',
      'Strategy Board Games',
      'Card Games',
      'Other Strategy Game',
    ],
    lifeSkills: [
      'Public Speaking',
      'Debate',
      'Leadership',
      'Study Skills',
      'Time Management',
      'Social Skills',
      'Communication Skills',
      'Critical Thinking',
      'Problem Solving',
      'Financial Literacy',
      'Cooking/Baking',
      'Gardening',
      'Other Life Skill',
    ],
    other: [
      'Enter your specialization...',
    ],
  };
}

