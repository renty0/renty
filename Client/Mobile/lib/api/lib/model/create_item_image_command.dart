//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateItemImageCommand {
  /// Returns a new [CreateItemImageCommand] instance.
  CreateItemImageCommand({
    this.imageId,
    this.isPrimary,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? imageId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isPrimary;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateItemImageCommand &&
    other.imageId == imageId &&
    other.isPrimary == isPrimary;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (imageId == null ? 0 : imageId!.hashCode) +
    (isPrimary == null ? 0 : isPrimary!.hashCode);

  @override
  String toString() => 'CreateItemImageCommand[imageId=$imageId, isPrimary=$isPrimary]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.imageId != null) {
      json[r'imageId'] = this.imageId;
    } else {
      json[r'imageId'] = null;
    }
    if (this.isPrimary != null) {
      json[r'isPrimary'] = this.isPrimary;
    } else {
      json[r'isPrimary'] = null;
    }
    return json;
  }

  /// Returns a new [CreateItemImageCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateItemImageCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateItemImageCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateItemImageCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateItemImageCommand(
        imageId: mapValueOfType<String>(json, r'imageId'),
        isPrimary: mapValueOfType<bool>(json, r'isPrimary'),
      );
    }
    return null;
  }

  static List<CreateItemImageCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateItemImageCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateItemImageCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateItemImageCommand> mapFromJson(dynamic json) {
    final map = <String, CreateItemImageCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateItemImageCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateItemImageCommand-objects as value to a dart map
  static Map<String, List<CreateItemImageCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateItemImageCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateItemImageCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

