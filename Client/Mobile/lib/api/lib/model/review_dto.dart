//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReviewDto {
  /// Returns a new [ReviewDto] instance.
  ReviewDto({
    this.id,
    this.rating,
    this.comment,
    this.reviewer,
    this.createdAt,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? rating;

  String? comment;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ReviewerDto? reviewer;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReviewDto &&
    other.id == id &&
    other.rating == rating &&
    other.comment == comment &&
    other.reviewer == reviewer &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (comment == null ? 0 : comment!.hashCode) +
    (reviewer == null ? 0 : reviewer!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'ReviewDto[id=$id, rating=$rating, comment=$comment, reviewer=$reviewer, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
    if (this.comment != null) {
      json[r'comment'] = this.comment;
    } else {
      json[r'comment'] = null;
    }
    if (this.reviewer != null) {
      json[r'reviewer'] = this.reviewer;
    } else {
      json[r'reviewer'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [ReviewDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReviewDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReviewDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReviewDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReviewDto(
        id: mapValueOfType<String>(json, r'id'),
        rating: mapValueOfType<int>(json, r'rating'),
        comment: mapValueOfType<String>(json, r'comment'),
        reviewer: ReviewerDto.fromJson(json[r'reviewer']),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<ReviewDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReviewDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReviewDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReviewDto> mapFromJson(dynamic json) {
    final map = <String, ReviewDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReviewDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReviewDto-objects as value to a dart map
  static Map<String, List<ReviewDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReviewDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReviewDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

