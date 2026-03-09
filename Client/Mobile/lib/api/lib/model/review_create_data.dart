//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReviewCreateData {
  /// Returns a new [ReviewCreateData] instance.
  ReviewCreateData({
    this.reviewId,
    this.rating,
    this.comment,
  });

  String? reviewId;

  int? rating;

  String? comment;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReviewCreateData &&
    other.reviewId == reviewId &&
    other.rating == rating &&
    other.comment == comment;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (reviewId == null ? 0 : reviewId!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (comment == null ? 0 : comment!.hashCode);

  @override
  String toString() => 'ReviewCreateData[reviewId=$reviewId, rating=$rating, comment=$comment]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.reviewId != null) {
      json[r'reviewId'] = this.reviewId;
    } else {
      json[r'reviewId'] = null;
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
    return json;
  }

  /// Returns a new [ReviewCreateData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReviewCreateData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReviewCreateData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReviewCreateData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReviewCreateData(
        reviewId: mapValueOfType<String>(json, r'reviewId'),
        rating: mapValueOfType<int>(json, r'rating'),
        comment: mapValueOfType<String>(json, r'comment'),
      );
    }
    return null;
  }

  static List<ReviewCreateData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReviewCreateData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReviewCreateData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReviewCreateData> mapFromJson(dynamic json) {
    final map = <String, ReviewCreateData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReviewCreateData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReviewCreateData-objects as value to a dart map
  static Map<String, List<ReviewCreateData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReviewCreateData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReviewCreateData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

