//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ItemVerificationDetailsDto {
  /// Returns a new [ItemVerificationDetailsDto] instance.
  ItemVerificationDetailsDto({
    this.itemId,
    this.titleAr,
    this.titleEn,
    this.imageUrl,
    this.condition,
    this.city,
    this.owner,
    this.activeRental,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? itemId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? titleAr;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? titleEn;

  String? imageUrl;

  String? condition;

  String? city;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  PersonInfoDto? owner;

  ItemVerificationDetailsDtoActiveRental? activeRental;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ItemVerificationDetailsDto &&
    other.itemId == itemId &&
    other.titleAr == titleAr &&
    other.titleEn == titleEn &&
    other.imageUrl == imageUrl &&
    other.condition == condition &&
    other.city == city &&
    other.owner == owner &&
    other.activeRental == activeRental;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (itemId == null ? 0 : itemId!.hashCode) +
    (titleAr == null ? 0 : titleAr!.hashCode) +
    (titleEn == null ? 0 : titleEn!.hashCode) +
    (imageUrl == null ? 0 : imageUrl!.hashCode) +
    (condition == null ? 0 : condition!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (owner == null ? 0 : owner!.hashCode) +
    (activeRental == null ? 0 : activeRental!.hashCode);

  @override
  String toString() => 'ItemVerificationDetailsDto[itemId=$itemId, titleAr=$titleAr, titleEn=$titleEn, imageUrl=$imageUrl, condition=$condition, city=$city, owner=$owner, activeRental=$activeRental]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.itemId != null) {
      json[r'itemId'] = this.itemId;
    } else {
      json[r'itemId'] = null;
    }
    if (this.titleAr != null) {
      json[r'titleAr'] = this.titleAr;
    } else {
      json[r'titleAr'] = null;
    }
    if (this.titleEn != null) {
      json[r'titleEn'] = this.titleEn;
    } else {
      json[r'titleEn'] = null;
    }
    if (this.imageUrl != null) {
      json[r'imageUrl'] = this.imageUrl;
    } else {
      json[r'imageUrl'] = null;
    }
    if (this.condition != null) {
      json[r'condition'] = this.condition;
    } else {
      json[r'condition'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.owner != null) {
      json[r'owner'] = this.owner;
    } else {
      json[r'owner'] = null;
    }
    if (this.activeRental != null) {
      json[r'activeRental'] = this.activeRental;
    } else {
      json[r'activeRental'] = null;
    }
    return json;
  }

  /// Returns a new [ItemVerificationDetailsDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ItemVerificationDetailsDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ItemVerificationDetailsDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ItemVerificationDetailsDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ItemVerificationDetailsDto(
        itemId: mapValueOfType<String>(json, r'itemId'),
        titleAr: mapValueOfType<String>(json, r'titleAr'),
        titleEn: mapValueOfType<String>(json, r'titleEn'),
        imageUrl: mapValueOfType<String>(json, r'imageUrl'),
        condition: mapValueOfType<String>(json, r'condition'),
        city: mapValueOfType<String>(json, r'city'),
        owner: PersonInfoDto.fromJson(json[r'owner']),
        activeRental: ItemVerificationDetailsDtoActiveRental.fromJson(json[r'activeRental']),
      );
    }
    return null;
  }

  static List<ItemVerificationDetailsDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ItemVerificationDetailsDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ItemVerificationDetailsDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ItemVerificationDetailsDto> mapFromJson(dynamic json) {
    final map = <String, ItemVerificationDetailsDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ItemVerificationDetailsDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ItemVerificationDetailsDto-objects as value to a dart map
  static Map<String, List<ItemVerificationDetailsDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ItemVerificationDetailsDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ItemVerificationDetailsDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

