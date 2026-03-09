//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ItemCategoryRef {
  /// Returns a new [ItemCategoryRef] instance.
  ItemCategoryRef({
    this.id,
    this.nameAr,
    this.nameEn,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? id;

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

  @override
  bool operator ==(Object other) => identical(this, other) || other is ItemCategoryRef &&
    other.id == id &&
    other.nameAr == nameAr &&
    other.nameEn == nameEn;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (nameAr == null ? 0 : nameAr!.hashCode) +
    (nameEn == null ? 0 : nameEn!.hashCode);

  @override
  String toString() => 'ItemCategoryRef[id=$id, nameAr=$nameAr, nameEn=$nameEn]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
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
    return json;
  }

  /// Returns a new [ItemCategoryRef] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ItemCategoryRef? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ItemCategoryRef[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ItemCategoryRef[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ItemCategoryRef(
        id: mapValueOfType<int>(json, r'id'),
        nameAr: mapValueOfType<String>(json, r'nameAr'),
        nameEn: mapValueOfType<String>(json, r'nameEn'),
      );
    }
    return null;
  }

  static List<ItemCategoryRef> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ItemCategoryRef>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ItemCategoryRef.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ItemCategoryRef> mapFromJson(dynamic json) {
    final map = <String, ItemCategoryRef>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ItemCategoryRef.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ItemCategoryRef-objects as value to a dart map
  static Map<String, List<ItemCategoryRef>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ItemCategoryRef>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ItemCategoryRef.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

