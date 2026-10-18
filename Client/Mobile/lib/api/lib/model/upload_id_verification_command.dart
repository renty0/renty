//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UploadIdVerificationCommand {
  /// Returns a new [UploadIdVerificationCommand] instance.
  UploadIdVerificationCommand({
    this.frontImageUrl,
    this.backImageUrl,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? frontImageUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? backImageUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UploadIdVerificationCommand &&
    other.frontImageUrl == frontImageUrl &&
    other.backImageUrl == backImageUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (frontImageUrl == null ? 0 : frontImageUrl!.hashCode) +
    (backImageUrl == null ? 0 : backImageUrl!.hashCode);

  @override
  String toString() => 'UploadIdVerificationCommand[frontImageUrl=$frontImageUrl, backImageUrl=$backImageUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.frontImageUrl != null) {
      json[r'frontImageUrl'] = this.frontImageUrl;
    } else {
      json[r'frontImageUrl'] = null;
    }
    if (this.backImageUrl != null) {
      json[r'backImageUrl'] = this.backImageUrl;
    } else {
      json[r'backImageUrl'] = null;
    }
    return json;
  }

  /// Returns a new [UploadIdVerificationCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadIdVerificationCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UploadIdVerificationCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UploadIdVerificationCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UploadIdVerificationCommand(
        frontImageUrl: mapValueOfType<String>(json, r'frontImageUrl'),
        backImageUrl: mapValueOfType<String>(json, r'backImageUrl'),
      );
    }
    return null;
  }

  static List<UploadIdVerificationCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UploadIdVerificationCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadIdVerificationCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadIdVerificationCommand> mapFromJson(dynamic json) {
    final map = <String, UploadIdVerificationCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadIdVerificationCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadIdVerificationCommand-objects as value to a dart map
  static Map<String, List<UploadIdVerificationCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UploadIdVerificationCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadIdVerificationCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

