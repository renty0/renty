//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VerificationCreateData {
  /// Returns a new [VerificationCreateData] instance.
  VerificationCreateData({
    this.verificationId,
    this.status,
  });

  String? verificationId;

  String? status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VerificationCreateData &&
    other.verificationId == verificationId &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (verificationId == null ? 0 : verificationId!.hashCode) +
    (status == null ? 0 : status!.hashCode);

  @override
  String toString() => 'VerificationCreateData[verificationId=$verificationId, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.verificationId != null) {
      json[r'verificationId'] = this.verificationId;
    } else {
      json[r'verificationId'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    return json;
  }

  /// Returns a new [VerificationCreateData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VerificationCreateData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "VerificationCreateData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "VerificationCreateData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VerificationCreateData(
        verificationId: mapValueOfType<String>(json, r'verificationId'),
        status: mapValueOfType<String>(json, r'status'),
      );
    }
    return null;
  }

  static List<VerificationCreateData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VerificationCreateData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VerificationCreateData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VerificationCreateData> mapFromJson(dynamic json) {
    final map = <String, VerificationCreateData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VerificationCreateData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VerificationCreateData-objects as value to a dart map
  static Map<String, List<VerificationCreateData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VerificationCreateData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VerificationCreateData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

