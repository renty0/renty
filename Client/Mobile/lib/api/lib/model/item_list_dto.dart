//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ItemListDto {
  /// Returns a new [ItemListDto] instance.
  ItemListDto({
    this.id,
    this.titleAr,
    this.titleEn,
    this.dailyPrice,
    this.city,
    this.primaryImage,
    this.avgRating,
    this.reviewCount,
    this.type,
    this.condition,
    this.category,
    this.subcategory,
    this.brand,
    this.status,
    this.ownerId,
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
  String? titleAr;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? titleEn;

  num? dailyPrice;

  String? city;

  String? primaryImage;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? avgRating;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? reviewCount;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  String? condition;

  ItemListDtoCategory? category;

  ItemListDtoSubcategory? subcategory;

  ItemListDtoBrand? brand;

  String? status;

  String? ownerId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ItemListDto &&
    other.id == id &&
    other.titleAr == titleAr &&
    other.titleEn == titleEn &&
    other.dailyPrice == dailyPrice &&
    other.city == city &&
    other.primaryImage == primaryImage &&
    other.avgRating == avgRating &&
    other.reviewCount == reviewCount &&
    other.type == type &&
    other.condition == condition &&
    other.category == category &&
    other.subcategory == subcategory &&
    other.brand == brand &&
    other.status == status &&
    other.ownerId == ownerId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (titleAr == null ? 0 : titleAr!.hashCode) +
    (titleEn == null ? 0 : titleEn!.hashCode) +
    (dailyPrice == null ? 0 : dailyPrice!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (primaryImage == null ? 0 : primaryImage!.hashCode) +
    (avgRating == null ? 0 : avgRating!.hashCode) +
    (reviewCount == null ? 0 : reviewCount!.hashCode) +
    (type == null ? 0 : type!.hashCode) +
    (condition == null ? 0 : condition!.hashCode) +
    (category == null ? 0 : category!.hashCode) +
    (subcategory == null ? 0 : subcategory!.hashCode) +
    (brand == null ? 0 : brand!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (ownerId == null ? 0 : ownerId!.hashCode);

  @override
  String toString() => 'ItemListDto[id=$id, titleAr=$titleAr, titleEn=$titleEn, dailyPrice=$dailyPrice, city=$city, primaryImage=$primaryImage, avgRating=$avgRating, reviewCount=$reviewCount, type=$type, condition=$condition, category=$category, subcategory=$subcategory, brand=$brand, status=$status, ownerId=$ownerId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
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
    if (this.dailyPrice != null) {
      json[r'dailyPrice'] = this.dailyPrice;
    } else {
      json[r'dailyPrice'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.primaryImage != null) {
      json[r'primaryImage'] = this.primaryImage;
    } else {
      json[r'primaryImage'] = null;
    }
    if (this.avgRating != null) {
      json[r'avgRating'] = this.avgRating;
    } else {
      json[r'avgRating'] = null;
    }
    if (this.reviewCount != null) {
      json[r'reviewCount'] = this.reviewCount;
    } else {
      json[r'reviewCount'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.condition != null) {
      json[r'condition'] = this.condition;
    } else {
      json[r'condition'] = null;
    }
    if (this.category != null) {
      json[r'category'] = this.category;
    } else {
      json[r'category'] = null;
    }
    if (this.subcategory != null) {
      json[r'subcategory'] = this.subcategory;
    } else {
      json[r'subcategory'] = null;
    }
    if (this.brand != null) {
      json[r'brand'] = this.brand;
    } else {
      json[r'brand'] = null;
    }
    return json;
  }

  /// Returns a new [ItemListDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ItemListDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ItemListDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ItemListDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ItemListDto(
        id: mapValueOfType<String>(json, r'id'),
        titleAr: mapValueOfType<String>(json, r'titleAr'),
        titleEn: mapValueOfType<String>(json, r'titleEn'),
        dailyPrice: json[r'dailyPrice'] == null
            ? null
            : num.parse('${json[r'dailyPrice']}'),
        city: mapValueOfType<String>(json, r'city'),
        primaryImage: _sanitizeImageUrl(mapValueOfType<String>(json, r'primaryImage')),
        avgRating: mapValueOfType<double>(json, r'avgRating'),
        reviewCount: mapValueOfType<int>(json, r'reviewCount'),
        type: mapValueOfType<String>(json, r'type'),
        condition: mapValueOfType<String>(json, r'condition'),
        category: ItemListDtoCategory.fromJson(json[r'category']),
        subcategory: ItemListDtoSubcategory.fromJson(json[r'subcategory']),
        brand: ItemListDtoBrand.fromJson(json[r'brand']),
        status: mapValueOfType<String>(json, r'status'),
        ownerId: mapValueOfType<String>(json, r'ownerId'),
      );
    }
    return null;
  }

  static List<ItemListDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ItemListDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ItemListDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ItemListDto> mapFromJson(dynamic json) {
    final map = <String, ItemListDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ItemListDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ItemListDto-objects as value to a dart map
  static Map<String, List<ItemListDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ItemListDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ItemListDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

