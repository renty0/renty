//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetKpisResponse {
  /// Returns a new [GetKpisResponse] instance.
  GetKpisResponse({
    this.snapshots = const [],
  });

  List<KpiSnapshotDto> snapshots;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetKpisResponse &&
    _deepEquality.equals(other.snapshots, snapshots);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (snapshots.hashCode);

  @override
  String toString() => 'GetKpisResponse[snapshots=$snapshots]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'snapshots'] = this.snapshots;
    return json;
  }

  /// Returns a new [GetKpisResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetKpisResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetKpisResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetKpisResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetKpisResponse(
        snapshots: KpiSnapshotDto.listFromJson(json[r'snapshots']),
      );
    }
    return null;
  }

  static List<GetKpisResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetKpisResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetKpisResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetKpisResponse> mapFromJson(dynamic json) {
    final map = <String, GetKpisResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetKpisResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetKpisResponse-objects as value to a dart map
  static Map<String, List<GetKpisResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetKpisResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetKpisResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

