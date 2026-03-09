//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfGetItemReviewsResponseData {
  /// Returns a new [ApiResponseOfGetItemReviewsResponseData] instance.
  ApiResponseOfGetItemReviewsResponseData({
    this.reviews = const [],
    this.avgRating,
    this.totalReviews,
  });

  List<ReviewDto> reviews;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? avgRating;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? totalReviews;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfGetItemReviewsResponseData &&
    _deepEquality.equals(other.reviews, reviews) &&
    other.avgRating == avgRating &&
    other.totalReviews == totalReviews;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (reviews.hashCode) +
    (avgRating == null ? 0 : avgRating!.hashCode) +
    (totalReviews == null ? 0 : totalReviews!.hashCode);

  @override
  String toString() => 'ApiResponseOfGetItemReviewsResponseData[reviews=$reviews, avgRating=$avgRating, totalReviews=$totalReviews]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'reviews'] = this.reviews;
    if (this.avgRating != null) {
      json[r'avgRating'] = this.avgRating;
    } else {
      json[r'avgRating'] = null;
    }
    if (this.totalReviews != null) {
      json[r'totalReviews'] = this.totalReviews;
    } else {
      json[r'totalReviews'] = null;
    }
    return json;
  }

  /// Returns a new [ApiResponseOfGetItemReviewsResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfGetItemReviewsResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfGetItemReviewsResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfGetItemReviewsResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfGetItemReviewsResponseData(
        reviews: ReviewDto.listFromJson(json[r'reviews']),
        avgRating: mapValueOfType<double>(json, r'avgRating'),
        totalReviews: mapValueOfType<int>(json, r'totalReviews'),
      );
    }
    return null;
  }

  static List<ApiResponseOfGetItemReviewsResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfGetItemReviewsResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfGetItemReviewsResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfGetItemReviewsResponseData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfGetItemReviewsResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfGetItemReviewsResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfGetItemReviewsResponseData-objects as value to a dart map
  static Map<String, List<ApiResponseOfGetItemReviewsResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfGetItemReviewsResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfGetItemReviewsResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

