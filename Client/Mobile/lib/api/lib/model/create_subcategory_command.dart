//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateSubcategoryCommand {
  /// Returns a new [CreateSubcategoryCommand] instance.
  CreateSubcategoryCommand({
    this.nameAr,
    this.nameEn,
    this.descAr,
    this.descEn,
    this.categoryId,
    this.logoId,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nameAr;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nameEn;

  String? descAr;

  String? descEn;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? categoryId;

  String? logoId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateSubcategoryCommand &&
    other.nameAr == nameAr &&
    other.nameEn == nameEn &&
    other.descAr == descAr &&
    other.descEn == descEn &&
    other.categoryId == categoryId &&
    other.logoId == logoId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (nameAr == null ? 0 : nameAr!.hashCode) +
    (nameEn == null ? 0 : nameEn!.hashCode) +
    (descAr == null ? 0 : descAr!.hashCode) +
    (descEn == null ? 0 : descEn!.hashCode) +
    (categoryId == null ? 0 : categoryId!.hashCode) +
    (logoId == null ? 0 : logoId!.hashCode);

  @override
  String toString() => 'CreateSubcategoryCommand[nameAr=$nameAr, nameEn=$nameEn, descAr=$descAr, descEn=$descEn, categoryId=$categoryId, logoId=$logoId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.nameAr != null) {
      json[r'nameAr'] = this.nameAr;
    } else {
      json[r'nameAr'] = null;
    }
    if (this.nameEn != null) {
      json[r'nameEn'] = this.nameEn;
    } else {
      json[r'nameEn'] = null;
    }
    if (this.descAr != null) {
      json[r'descAr'] = this.descAr;
    } else {
      json[r'descAr'] = null;
    }
    if (this.descEn != null) {
      json[r'descEn'] = this.descEn;
    } else {
      json[r'descEn'] = null;
    }
    if (this.categoryId != null) {
      json[r'categoryId'] = this.categoryId;
    } else {
      json[r'categoryId'] = null;
    }
    if (this.logoId != null) {
      json[r'logoId'] = this.logoId;
    } else {
      json[r'logoId'] = null;
    }
    return json;
  }

  /// Returns a new [CreateSubcategoryCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateSubcategoryCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateSubcategoryCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateSubcategoryCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateSubcategoryCommand(
        nameAr: mapValueOfType<String>(json, r'nameAr'),
        nameEn: mapValueOfType<String>(json, r'nameEn'),
        descAr: mapValueOfType<String>(json, r'descAr'),
        descEn: mapValueOfType<String>(json, r'descEn'),
        categoryId: mapValueOfType<int>(json, r'categoryId'),
        logoId: mapValueOfType<String>(json, r'logoId'),
      );
    }
    return null;
  }

  static List<CreateSubcategoryCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateSubcategoryCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateSubcategoryCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateSubcategoryCommand> mapFromJson(dynamic json) {
    final map = <String, CreateSubcategoryCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateSubcategoryCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateSubcategoryCommand-objects as value to a dart map
  static Map<String, List<CreateSubcategoryCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateSubcategoryCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateSubcategoryCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

