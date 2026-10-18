//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfGetTicketResponseData {
  /// Returns a new [ApiResponseOfGetTicketResponseData] instance.
  ApiResponseOfGetTicketResponseData({
    this.found,
    this.error,
    this.ticket,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? found;

  String? error;

  GetTicketResponseTicket? ticket;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfGetTicketResponseData &&
    other.found == found &&
    other.error == error &&
    other.ticket == ticket;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (found == null ? 0 : found!.hashCode) +
    (error == null ? 0 : error!.hashCode) +
    (ticket == null ? 0 : ticket!.hashCode);

  @override
  String toString() => 'ApiResponseOfGetTicketResponseData[found=$found, error=$error, ticket=$ticket]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.found != null) {
      json[r'found'] = this.found;
    } else {
      json[r'found'] = null;
    }
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
    if (this.ticket != null) {
      json[r'ticket'] = this.ticket;
    } else {
      json[r'ticket'] = null;
    }
    return json;
  }

  /// Returns a new [ApiResponseOfGetTicketResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfGetTicketResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfGetTicketResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfGetTicketResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfGetTicketResponseData(
        found: mapValueOfType<bool>(json, r'found'),
        error: mapValueOfType<String>(json, r'error'),
        ticket: GetTicketResponseTicket.fromJson(json[r'ticket']),
      );
    }
    return null;
  }

  static List<ApiResponseOfGetTicketResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfGetTicketResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfGetTicketResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfGetTicketResponseData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfGetTicketResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfGetTicketResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfGetTicketResponseData-objects as value to a dart map
  static Map<String, List<ApiResponseOfGetTicketResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfGetTicketResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfGetTicketResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

