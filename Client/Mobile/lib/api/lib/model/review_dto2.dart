//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReviewDto2 {
  /// Returns a new [ReviewDto2] instance.
  ReviewDto2({
    this.id,
    this.rating,
    this.comment,
    this.reviewerName,
    this.reviewerImage,
    this.createdAt,
    this.role,
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
  String? reviewerName;

  String? reviewerImage;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? role;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReviewDto2 &&
    other.id == id &&
    other.rating == rating &&
    other.comment == comment &&
    other.reviewerName == reviewerName &&
    other.reviewerImage == reviewerImage &&
    other.createdAt == createdAt &&
    other.role == role;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (comment == null ? 0 : comment!.hashCode) +
    (reviewerName == null ? 0 : reviewerName!.hashCode) +
    (reviewerImage == null ? 0 : reviewerImage!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (role == null ? 0 : role!.hashCode);

  @override
  String toString() => 'ReviewDto2[id=$id, rating=$rating, comment=$comment, reviewerName=$reviewerName, reviewerImage=$reviewerImage, createdAt=$createdAt, role=$role]';

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
    if (this.reviewerName != null) {
      json[r'reviewerName'] = this.reviewerName;
    } else {
      json[r'reviewerName'] = null;
    }
    if (this.reviewerImage != null) {
      json[r'reviewerImage'] = this.reviewerImage;
    } else {
      json[r'reviewerImage'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    if (this.role != null) {
      json[r'role'] = this.role;
    } else {
      json[r'role'] = null;
    }
    return json;
  }

  /// Returns a new [ReviewDto2] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReviewDto2? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReviewDto2[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReviewDto2[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReviewDto2(
        id: mapValueOfType<String>(json, r'id'),
        rating: mapValueOfType<int>(json, r'rating'),
        comment: mapValueOfType<String>(json, r'comment'),
        reviewerName: mapValueOfType<String>(json, r'reviewerName'),
        reviewerImage: mapValueOfType<String>(json, r'reviewerImage'),
        createdAt: mapDateTime(json, r'createdAt', r''),
        role: mapValueOfType<String>(json, r'role'),
      );
    }
    return null;
  }

  static List<ReviewDto2> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReviewDto2>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReviewDto2.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReviewDto2> mapFromJson(dynamic json) {
    final map = <String, ReviewDto2>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReviewDto2.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReviewDto2-objects as value to a dart map
  static Map<String, List<ReviewDto2>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReviewDto2>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReviewDto2.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

