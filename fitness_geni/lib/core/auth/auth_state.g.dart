// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) =>
    _$UserImpl(id: json['id'] as String, email: json['email'] as String);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{'id': instance.id, 'email': instance.email};

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      age: (json['age'] as num?)?.toInt(),
      heightCm: (json['height_cm'] as num?)?.toInt(),
      weightKg: (json['weight_kg'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      dietType: json['diet_type'] as String?,
      goal: json['goal'] as String?,
      bmi: (json['bmi'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt?.toIso8601String(),
      'age': instance.age,
      'height_cm': instance.heightCm,
      'weight_kg': instance.weightKg,
      'gender': instance.gender,
      'diet_type': instance.dietType,
      'goal': instance.goal,
      'bmi': instance.bmi,
    };
