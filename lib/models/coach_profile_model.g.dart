// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachProfile _$CoachProfileFromJson(Map<String, dynamic> json) => CoachProfile(
  id: json['id'] as String,
  name: json['name'] as String,
  headline: json['headline'] as String?,
  bio: json['bio'] as String?,
  photoUrl: json['photoUrl'] as String?,
  profileVideoUrl: json['profileVideoUrl'] as String?,
  location: json['location'] == null
      ? null
      : CoachLocation.fromJson(json['location'] as Map<String, dynamic>),
  languages:
      (json['languages'] as List<dynamic>?)
          ?.map((e) => LanguageSkill.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  specializations:
      (json['specializations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  certifications:
      (json['certifications'] as List<dynamic>?)
          ?.map((e) => Certification.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  education:
      (json['education'] as List<dynamic>?)
          ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  awards:
      (json['awards'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  teachingPhilosophy: json['teachingPhilosophy'] as String?,
  ageGroups:
      (json['ageGroups'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  skillLevels:
      (json['skillLevels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  classTypes:
      (json['classTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  yearsExperience: (json['yearsExperience'] as num?)?.toInt(),
  availableDays: (json['availableDays'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as bool),
  ),
  availableTimeRange: json['availableTimeRange'] as String?,
  galleryUrls:
      (json['galleryUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  testimonials:
      (json['testimonials'] as List<dynamic>?)
          ?.map((e) => Testimonial.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  rating: (json['rating'] as num?)?.toDouble(),
  totalReviews: (json['totalReviews'] as num?)?.toInt(),
  website: json['website'] as String?,
  socialMedia: (json['socialMedia'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  isVerified: json['isVerified'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  totalStudents: (json['totalStudents'] as num?)?.toInt(),
  totalClasses: (json['totalClasses'] as num?)?.toInt(),
  joinedDate: json['joinedDate'] == null
      ? null
      : DateTime.parse(json['joinedDate'] as String),
  preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CoachProfileToJson(CoachProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'headline': instance.headline,
      'bio': instance.bio,
      'photoUrl': instance.photoUrl,
      'profileVideoUrl': instance.profileVideoUrl,
      'location': instance.location?.toJson(),
      'languages': instance.languages.map((e) => e.toJson()).toList(),
      'categories': instance.categories,
      'specializations': instance.specializations,
      'certifications': instance.certifications.map((e) => e.toJson()).toList(),
      'education': instance.education.map((e) => e.toJson()).toList(),
      'awards': instance.awards,
      'teachingPhilosophy': instance.teachingPhilosophy,
      'ageGroups': instance.ageGroups,
      'skillLevels': instance.skillLevels,
      'classTypes': instance.classTypes,
      'yearsExperience': instance.yearsExperience,
      'availableDays': instance.availableDays,
      'availableTimeRange': instance.availableTimeRange,
      'galleryUrls': instance.galleryUrls,
      'testimonials': instance.testimonials.map((e) => e.toJson()).toList(),
      'rating': instance.rating,
      'totalReviews': instance.totalReviews,
      'website': instance.website,
      'socialMedia': instance.socialMedia,
      'isVerified': instance.isVerified,
      'isActive': instance.isActive,
      'totalStudents': instance.totalStudents,
      'totalClasses': instance.totalClasses,
      'joinedDate': instance.joinedDate?.toIso8601String(),
      'preferences': instance.preferences,
    };

CoachLocation _$CoachLocationFromJson(Map<String, dynamic> json) =>
    CoachLocation(
      address: json['address'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      serviceRadiusMiles: (json['serviceRadiusMiles'] as num?)?.toInt(),
      travelOptions:
          (json['travelOptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['coach_location'],
    );

Map<String, dynamic> _$CoachLocationToJson(CoachLocation instance) =>
    <String, dynamic>{
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'zipCode': instance.zipCode,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'serviceRadiusMiles': instance.serviceRadiusMiles,
      'travelOptions': instance.travelOptions,
    };

LanguageSkill _$LanguageSkillFromJson(Map<String, dynamic> json) =>
    LanguageSkill(
      language: json['language'] as String,
      proficiency: json['proficiency'] as String,
    );

Map<String, dynamic> _$LanguageSkillToJson(LanguageSkill instance) =>
    <String, dynamic>{
      'language': instance.language,
      'proficiency': instance.proficiency,
    };

Certification _$CertificationFromJson(Map<String, dynamic> json) =>
    Certification(
      name: json['name'] as String,
      issuer: json['issuer'] as String?,
      year: (json['year'] as num?)?.toInt(),
      certificateUrl: json['certificateUrl'] as String?,
      expiryDate: json['expiryDate'] as String?,
    );

Map<String, dynamic> _$CertificationToJson(Certification instance) =>
    <String, dynamic>{
      'name': instance.name,
      'issuer': instance.issuer,
      'year': instance.year,
      'certificateUrl': instance.certificateUrl,
      'expiryDate': instance.expiryDate,
    };

Education _$EducationFromJson(Map<String, dynamic> json) => Education(
  degree: json['degree'] as String,
  institution: json['institution'] as String,
  graduationYear: (json['graduationYear'] as num?)?.toInt(),
  fieldOfStudy: json['fieldOfStudy'] as String?,
);

Map<String, dynamic> _$EducationToJson(Education instance) => <String, dynamic>{
  'degree': instance.degree,
  'institution': instance.institution,
  'graduationYear': instance.graduationYear,
  'fieldOfStudy': instance.fieldOfStudy,
};

Testimonial _$TestimonialFromJson(Map<String, dynamic> json) => Testimonial(
  id: json['id'] as String,
  studentName: json['studentName'] as String,
  studentPhotoUrl: json['studentPhotoUrl'] as String?,
  text: json['text'] as String,
  rating: (json['rating'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  isVerified: json['isVerified'] as bool? ?? false,
  relationship: json['relationship'] as String?,
);

Map<String, dynamic> _$TestimonialToJson(Testimonial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentName': instance.studentName,
      'studentPhotoUrl': instance.studentPhotoUrl,
      'text': instance.text,
      'rating': instance.rating,
      'date': instance.date.toIso8601String(),
      'isVerified': instance.isVerified,
      'relationship': instance.relationship,
    };
