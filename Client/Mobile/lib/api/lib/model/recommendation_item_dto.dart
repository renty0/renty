//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RecommendationItemDto {
  /// Returns a new [RecommendationItemDto] instance.
  RecommendationItemDto({
    this.id,
    this.title,
    this.price,
    this.image,
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

  num? price;

  String? image;

  String? city;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RecommendationItemDto &&
    other.id == id &&
    other.title == title &&
    other.price == price &&
    other.image == image &&
    other.city == city;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (title == null ? 0 : title!.hashCode) +
    (price == null ? 0 : price!.hashCode) +
    (image == null ? 0 : image!.hashCode) +
    (city == null ? 0 : city!.hashCode);

  @override
  String toString() => 'RecommendationItemDto[id=$id, title=$title, price=$price, image=$image, city=$city]';

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
    if (this.price != null) {
      json[r'price'] = this.price;
    } else {
      json[r'price'] = null;
    }
    if (this.image != null) {
      json[r'image'] = this.image;
    } else {
      json[r'image'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    return json;
  }

  /// Returns a new [RecommendationItemDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RecommendationItemDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RecommendationItemDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RecommendationItemDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RecommendationItemDto(
        id: mapValueOfType<String>(json, r'id'),
        title: mapValueOfType<String>(json, r'title'),
        price: json[r'price'] == null
            ? null
            : num.parse('${json[r'price']}'),
        image: mapValueOfType<String>(json, r'image'),
        city: mapValueOfType<String>(json, r'city'),
      );
    }
    return null;
  }

  static List<RecommendationItemDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RecommendationItemDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RecommendationItemDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RecommendationItemDto> mapFromJson(dynamic json) {
    final map = <String, RecommendationItemDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RecommendationItemDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RecommendationItemDto-objects as value to a dart map
  static Map<String, List<RecommendationItemDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RecommendationItemDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RecommendationItemDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

