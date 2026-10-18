//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfListOfBookedRangeDto {
  /// Returns a new [ApiResponseOfListOfBookedRangeDto] instance.
  ApiResponseOfListOfBookedRangeDto({
    this.data = const [],
    this.error,
    this.errorCode = const [],
    this.messages = const [],
    this.total,
    this.page,
    this.pages,
    this.successCode,
  });

  List<BookedRangeDto>? data;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? error;

  List<int>? errorCode;

  List<String>? messages;

  int? total;

  int? page;

  int? pages;

  int? successCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfListOfBookedRangeDto &&
    _deepEquality.equals(other.data, data) &&
    other.error == error &&
    _deepEquality.equals(other.errorCode, errorCode) &&
    _deepEquality.equals(other.messages, messages) &&
    other.total == total &&
    other.page == page &&
    other.pages == pages &&
    other.successCode == successCode;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (data == null ? 0 : data!.hashCode) +
    (error == null ? 0 : error!.hashCode) +
    (errorCode == null ? 0 : errorCode!.hashCode) +
    (messages == null ? 0 : messages!.hashCode) +
    (total == null ? 0 : total!.hashCode) +
    (page == null ? 0 : page!.hashCode) +
    (pages == null ? 0 : pages!.hashCode) +
    (successCode == null ? 0 : successCode!.hashCode);

  @override
  String toString() => 'ApiResponseOfListOfBookedRangeDto[data=$data, error=$error, errorCode=$errorCode, messages=$messages, total=$total, page=$page, pages=$pages, successCode=$successCode]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.data != null) {
      json[r'data'] = this.data;
    } else {
      json[r'data'] = null;
    }
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
    if (this.errorCode != null) {
      json[r'errorCode'] = this.errorCode;
    } else {
      json[r'errorCode'] = null;
    }
    if (this.messages != null) {
      json[r'messages'] = this.messages;
    } else {
      json[r'messages'] = null;
    }
    if (this.total != null) {
      json[r'total'] = this.total;
    } else {
      json[r'total'] = null;
    }
    if (this.page != null) {
      json[r'page'] = this.page;
    } else {
      json[r'page'] = null;
    }
    if (this.pages != null) {
      json[r'pages'] = this.pages;
    } else {
      json[r'pages'] = null;
    }
    if (this.successCode != null) {
      json[r'successCode'] = this.successCode;
    } else {
      json[r'successCode'] = null;
    }
    return json;
  }

  /// Returns a new [ApiResponseOfListOfBookedRangeDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfListOfBookedRangeDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfListOfBookedRangeDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfListOfBookedRangeDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfListOfBookedRangeDto(
        data: BookedRangeDto.listFromJson(json[r'data']),
        error: mapValueOfType<bool>(json, r'error'),
        errorCode: json[r'errorCode'] is Iterable
            ? (json[r'errorCode'] as Iterable).cast<int>().toList(growable: false)
            : const [],
        messages: json[r'messages'] is Iterable
            ? (json[r'messages'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        total: mapValueOfType<int>(json, r'total'),
        page: mapValueOfType<int>(json, r'page'),
        pages: mapValueOfType<int>(json, r'pages'),
        successCode: mapValueOfType<int>(json, r'successCode'),
      );
    }
    return null;
  }

  static List<ApiResponseOfListOfBookedRangeDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfListOfBookedRangeDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfListOfBookedRangeDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfListOfBookedRangeDto> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfListOfBookedRangeDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfListOfBookedRangeDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfListOfBookedRangeDto-objects as value to a dart map
  static Map<String, List<ApiResponseOfListOfBookedRangeDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfListOfBookedRangeDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfListOfBookedRangeDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

