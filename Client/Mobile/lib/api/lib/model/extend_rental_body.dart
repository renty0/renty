//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExtendRentalBody {
  /// Returns a new [ExtendRentalBody] instance.
  ExtendRentalBody({
    this.extraDays,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? extraDays;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExtendRentalBody &&
    other.extraDays == extraDays;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (extraDays == null ? 0 : extraDays!.hashCode);

  @override
  String toString() => 'ExtendRentalBody[extraDays=$extraDays]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.extraDays != null) {
      json[r'extraDays'] = this.extraDays;
    } else {
      json[r'extraDays'] = null;
    }
    return json;
  }

  /// Returns a new [ExtendRentalBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExtendRentalBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExtendRentalBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExtendRentalBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExtendRentalBody(
        extraDays: mapValueOfType<int>(json, r'extraDays'),
      );
    }
    return null;
  }

  static List<ExtendRentalBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExtendRentalBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExtendRentalBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExtendRentalBody> mapFromJson(dynamic json) {
    final map = <String, ExtendRentalBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExtendRentalBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExtendRentalBody-objects as value to a dart map
  static Map<String, List<ExtendRentalBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExtendRentalBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExtendRentalBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

