//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfGetRecommendationsResponseData {
  /// Returns a new [ApiResponseOfGetRecommendationsResponseData] instance.
  ApiResponseOfGetRecommendationsResponseData({
    this.recommendations = const [],
  });

  List<RecommendationEntryDto> recommendations;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfGetRecommendationsResponseData &&
    _deepEquality.equals(other.recommendations, recommendations);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (recommendations.hashCode);

  @override
  String toString() => 'ApiResponseOfGetRecommendationsResponseData[recommendations=$recommendations]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'recommendations'] = this.recommendations;
    return json;
  }

  /// Returns a new [ApiResponseOfGetRecommendationsResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfGetRecommendationsResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfGetRecommendationsResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfGetRecommendationsResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfGetRecommendationsResponseData(
        recommendations: RecommendationEntryDto.listFromJson(json[r'recommendations']),
      );
    }
    return null;
  }

  static List<ApiResponseOfGetRecommendationsResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfGetRecommendationsResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfGetRecommendationsResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfGetRecommendationsResponseData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfGetRecommendationsResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfGetRecommendationsResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfGetRecommendationsResponseData-objects as value to a dart map
  static Map<String, List<ApiResponseOfGetRecommendationsResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfGetRecommendationsResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfGetRecommendationsResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

