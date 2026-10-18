//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FavoriteItemDto {
  /// Returns a new [FavoriteItemDto] instance.
  FavoriteItemDto({
    this.id,
    this.title,
    this.dailyPrice,
    this.primaryImage,
    this.city,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? title;

  num? dailyPrice;

  String? primaryImage;

  String? city;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FavoriteItemDto &&
    other.id == id &&
    other.title == title &&
    other.dailyPrice == dailyPrice &&
    other.primaryImage == primaryImage &&
    other.city == city;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (title == null ? 0 : title!.hashCode) +
    (dailyPrice == null ? 0 : dailyPrice!.hashCode) +
    (primaryImage == null ? 0 : primaryImage!.hashCode) +
    (city == null ? 0 : city!.hashCode);

  @override
  String toString() => 'FavoriteItemDto[id=$id, title=$title, dailyPrice=$dailyPrice, primaryImage=$primaryImage, city=$city]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
    if (this.dailyPrice != null) {
      json[r'dailyPrice'] = this.dailyPrice;
    } else {
      json[r'dailyPrice'] = null;
    }
    if (this.primaryImage != null) {
      json[r'primaryImage'] = this.primaryImage;
    } else {
      json[r'primaryImage'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    return json;
  }

  /// Returns a new [FavoriteItemDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FavoriteItemDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FavoriteItemDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FavoriteItemDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FavoriteItemDto(
        id: mapValueOfType<String>(json, r'id'),
        title: mapValueOfType<String>(json, r'title'),
        dailyPrice: json[r'dailyPrice'] == null
            ? null
            : num.parse('${json[r'dailyPrice']}'),
        primaryImage: mapValueOfType<String>(json, r'primaryImage'),
        city: mapValueOfType<String>(json, r'city'),
      );
    }
    return null;
  }

  static List<FavoriteItemDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FavoriteItemDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FavoriteItemDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FavoriteItemDto> mapFromJson(dynamic json) {
    final map = <String, FavoriteItemDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FavoriteItemDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FavoriteItemDto-objects as value to a dart map
  static Map<String, List<FavoriteItemDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FavoriteItemDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FavoriteItemDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

