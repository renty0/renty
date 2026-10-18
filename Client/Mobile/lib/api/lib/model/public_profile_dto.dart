//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PublicProfileDto {
  /// Returns a new [PublicProfileDto] instance.
  PublicProfileDto({
    this.id,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    this.bio,
    this.city,
    this.country,
    this.rating,
    this.totalRatings,
    this.joinedAt,
    this.idVerified,
    this.items = const [],
    this.reviews = const [],
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
  String? firstName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastName;

  String? profilePictureUrl;

  String? bio;

  String? city;

  String? country;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? rating;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? totalRatings;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? joinedAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? idVerified;

  List<ItemListDto> items;

  List<ReviewDto2> reviews;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PublicProfileDto &&
    other.id == id &&
    other.firstName == firstName &&
    other.lastName == lastName &&
    other.profilePictureUrl == profilePictureUrl &&
    other.bio == bio &&
    other.city == city &&
    other.country == country &&
    other.rating == rating &&
    other.totalRatings == totalRatings &&
    other.joinedAt == joinedAt &&
    other.idVerified == idVerified &&
    _deepEquality.equals(other.items, items) &&
    _deepEquality.equals(other.reviews, reviews);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (firstName == null ? 0 : firstName!.hashCode) +
    (lastName == null ? 0 : lastName!.hashCode) +
    (profilePictureUrl == null ? 0 : profilePictureUrl!.hashCode) +
    (bio == null ? 0 : bio!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (country == null ? 0 : country!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (totalRatings == null ? 0 : totalRatings!.hashCode) +
    (joinedAt == null ? 0 : joinedAt!.hashCode) +
    (idVerified == null ? 0 : idVerified!.hashCode) +
    (items.hashCode) +
    (reviews.hashCode);

  @override
  String toString() => 'PublicProfileDto[id=$id, firstName=$firstName, lastName=$lastName, profilePictureUrl=$profilePictureUrl, bio=$bio, city=$city, country=$country, rating=$rating, totalRatings=$totalRatings, joinedAt=$joinedAt, idVerified=$idVerified, items=$items, reviews=$reviews]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.firstName != null) {
      json[r'firstName'] = this.firstName;
    } else {
      json[r'firstName'] = null;
    }
    if (this.lastName != null) {
      json[r'lastName'] = this.lastName;
    } else {
      json[r'lastName'] = null;
    }
    if (this.profilePictureUrl != null) {
      json[r'profilePictureUrl'] = this.profilePictureUrl;
    } else {
      json[r'profilePictureUrl'] = null;
    }
    if (this.bio != null) {
      json[r'bio'] = this.bio;
    } else {
      json[r'bio'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.country != null) {
      json[r'country'] = this.country;
    } else {
      json[r'country'] = null;
    }
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
    if (this.totalRatings != null) {
      json[r'totalRatings'] = this.totalRatings;
    } else {
      json[r'totalRatings'] = null;
    }
    if (this.joinedAt != null) {
      json[r'joinedAt'] = this.joinedAt!.toUtc().toIso8601String();
    } else {
      json[r'joinedAt'] = null;
    }
    if (this.idVerified != null) {
      json[r'idVerified'] = this.idVerified;
    } else {
      json[r'idVerified'] = null;
    }
      json[r'items'] = this.items;
      json[r'reviews'] = this.reviews;
    return json;
  }

  /// Returns a new [PublicProfileDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PublicProfileDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PublicProfileDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PublicProfileDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PublicProfileDto(
        id: mapValueOfType<int>(json, r'id'),
        firstName: mapValueOfType<String>(json, r'firstName'),
        lastName: mapValueOfType<String>(json, r'lastName'),
        profilePictureUrl: mapValueOfType<String>(json, r'profilePictureUrl'),
        bio: mapValueOfType<String>(json, r'bio'),
        city: mapValueOfType<String>(json, r'city'),
        country: mapValueOfType<String>(json, r'country'),
        rating: mapValueOfType<double>(json, r'rating'),
        totalRatings: mapValueOfType<int>(json, r'totalRatings'),
        joinedAt: mapDateTime(json, r'joinedAt', r''),
        idVerified: mapValueOfType<bool>(json, r'idVerified'),
        items: ItemListDto.listFromJson(json[r'items']),
        reviews: ReviewDto2.listFromJson(json[r'reviews']),
      );
    }
    return null;
  }

  static List<PublicProfileDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PublicProfileDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PublicProfileDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PublicProfileDto> mapFromJson(dynamic json) {
    final map = <String, PublicProfileDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PublicProfileDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PublicProfileDto-objects as value to a dart map
  static Map<String, List<PublicProfileDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PublicProfileDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PublicProfileDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

