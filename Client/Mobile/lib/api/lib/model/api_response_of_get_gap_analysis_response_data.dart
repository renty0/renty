//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfGetGapAnalysisResponseData {
  /// Returns a new [ApiResponseOfGetGapAnalysisResponseData] instance.
  ApiResponseOfGetGapAnalysisResponseData({
    this.gaps = const [],
  });

  List<GapDto> gaps;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfGetGapAnalysisResponseData &&
    _deepEquality.equals(other.gaps, gaps);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (gaps.hashCode);

  @override
  String toString() => 'ApiResponseOfGetGapAnalysisResponseData[gaps=$gaps]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'gaps'] = this.gaps;
    return json;
  }

  /// Returns a new [ApiResponseOfGetGapAnalysisResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfGetGapAnalysisResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfGetGapAnalysisResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfGetGapAnalysisResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfGetGapAnalysisResponseData(
        gaps: GapDto.listFromJson(json[r'gaps']),
      );
    }
    return null;
  }

  static List<ApiResponseOfGetGapAnalysisResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfGetGapAnalysisResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfGetGapAnalysisResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfGetGapAnalysisResponseData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfGetGapAnalysisResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfGetGapAnalysisResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfGetGapAnalysisResponseData-objects as value to a dart map
  static Map<String, List<ApiResponseOfGetGapAnalysisResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfGetGapAnalysisResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfGetGapAnalysisResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

