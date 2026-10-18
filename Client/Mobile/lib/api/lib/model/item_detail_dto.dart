//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ItemDetailDto {
  /// Returns a new [ItemDetailDto] instance.
  ItemDetailDto({
    this.id,
    this.titleAr,
    this.titleEn,
    this.descAr,
    this.descEn,
    this.type,
    this.status,
    this.adminNote,
    this.condition,
    this.defaultDeposit,
    this.location,
    this.city,
    this.lat,
    this.lng,
    this.isForSale,
    this.salePrice,
    this.createdAt,
    this.owner,
    this.pricing = const [],
    this.images = const [],
    this.avgRating,
    this.reviewCount,
    this.category,
    this.subcategory,
    this.brand,
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

  String? descAr;

  String? descEn;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  String? adminNote;

  String? condition;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? defaultDeposit;

  String? location;

  String? city;

  num? lat;

  num? lng;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isForSale;

  num? salePrice;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  OwnerDto? owner;

  List<ItemPricingDto> pricing;

  List<ItemImageDto> images;

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

  ItemListDtoCategory? category;

  ItemListDtoSubcategory? subcategory;

  ItemListDtoBrand? brand;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ItemDetailDto &&
    other.id == id &&
    other.titleAr == titleAr &&
    other.titleEn == titleEn &&
    other.descAr == descAr &&
    other.descEn == descEn &&
    other.type == type &&
    other.status == status &&
    other.adminNote == adminNote &&
    other.condition == condition &&
    other.defaultDeposit == defaultDeposit &&
    other.location == location &&
    other.city == city &&
    other.lat == lat &&
    other.lng == lng &&
    other.isForSale == isForSale &&
    other.salePrice == salePrice &&
    other.createdAt == createdAt &&
    other.owner == owner &&
    _deepEquality.equals(other.pricing, pricing) &&
    _deepEquality.equals(other.images, images) &&
    other.avgRating == avgRating &&
    other.reviewCount == reviewCount &&
    other.category == category &&
    other.subcategory == subcategory &&
    other.brand == brand;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (titleAr == null ? 0 : titleAr!.hashCode) +
    (titleEn == null ? 0 : titleEn!.hashCode) +
    (descAr == null ? 0 : descAr!.hashCode) +
    (descEn == null ? 0 : descEn!.hashCode) +
    (type == null ? 0 : type!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (adminNote == null ? 0 : adminNote!.hashCode) +
    (condition == null ? 0 : condition!.hashCode) +
    (defaultDeposit == null ? 0 : defaultDeposit!.hashCode) +
    (location == null ? 0 : location!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (lat == null ? 0 : lat!.hashCode) +
    (lng == null ? 0 : lng!.hashCode) +
    (isForSale == null ? 0 : isForSale!.hashCode) +
    (salePrice == null ? 0 : salePrice!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (owner == null ? 0 : owner!.hashCode) +
    (pricing.hashCode) +
    (images.hashCode) +
    (avgRating == null ? 0 : avgRating!.hashCode) +
    (reviewCount == null ? 0 : reviewCount!.hashCode) +
    (category == null ? 0 : category!.hashCode) +
    (subcategory == null ? 0 : subcategory!.hashCode) +
    (brand == null ? 0 : brand!.hashCode);

  @override
  String toString() => 'ItemDetailDto[id=$id, titleAr=$titleAr, titleEn=$titleEn, descAr=$descAr, descEn=$descEn, type=$type, status=$status, adminNote=$adminNote, condition=$condition, defaultDeposit=$defaultDeposit, location=$location, city=$city, lat=$lat, lng=$lng, isForSale=$isForSale, salePrice=$salePrice, createdAt=$createdAt, owner=$owner, pricing=$pricing, images=$images, avgRating=$avgRating, reviewCount=$reviewCount, category=$category, subcategory=$subcategory, brand=$brand]';

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
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.adminNote != null) {
      json[r'adminNote'] = this.adminNote;
    } else {
      json[r'adminNote'] = null;
    }
    if (this.condition != null) {
      json[r'condition'] = this.condition;
    } else {
      json[r'condition'] = null;
    }
    if (this.defaultDeposit != null) {
      json[r'defaultDeposit'] = this.defaultDeposit;
    } else {
      json[r'defaultDeposit'] = null;
    }
    if (this.location != null) {
      json[r'location'] = this.location;
    } else {
      json[r'location'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.lat != null) {
      json[r'lat'] = this.lat;
    } else {
      json[r'lat'] = null;
    }
    if (this.lng != null) {
      json[r'lng'] = this.lng;
    } else {
      json[r'lng'] = null;
    }
    if (this.isForSale != null) {
      json[r'isForSale'] = this.isForSale;
    } else {
      json[r'isForSale'] = null;
    }
    if (this.salePrice != null) {
      json[r'salePrice'] = this.salePrice;
    } else {
      json[r'salePrice'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    if (this.owner != null) {
      json[r'owner'] = this.owner;
    } else {
      json[r'owner'] = null;
    }
      json[r'pricing'] = this.pricing;
      json[r'images'] = this.images;
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

  /// Returns a new [ItemDetailDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ItemDetailDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ItemDetailDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ItemDetailDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ItemDetailDto(
        id: mapValueOfType<String>(json, r'id'),
        titleAr: mapValueOfType<String>(json, r'titleAr'),
        titleEn: mapValueOfType<String>(json, r'titleEn'),
        descAr: mapValueOfType<String>(json, r'descAr'),
        descEn: mapValueOfType<String>(json, r'descEn'),
        type: mapValueOfType<String>(json, r'type'),
        status: mapValueOfType<String>(json, r'status'),
        adminNote: mapValueOfType<String>(json, r'adminNote'),
        condition: mapValueOfType<String>(json, r'condition'),
        defaultDeposit: num.parse('${json[r'defaultDeposit']}'),
        location: mapValueOfType<String>(json, r'location'),
        city: mapValueOfType<String>(json, r'city'),
        lat: json[r'lat'] == null
            ? null
            : num.parse('${json[r'lat']}'),
        lng: json[r'lng'] == null
            ? null
            : num.parse('${json[r'lng']}'),
        isForSale: mapValueOfType<bool>(json, r'isForSale'),
        salePrice: json[r'salePrice'] == null
            ? null
            : num.parse('${json[r'salePrice']}'),
        createdAt: mapDateTime(json, r'createdAt', r''),
        owner: OwnerDto.fromJson(json[r'owner']),
        pricing: ItemPricingDto.listFromJson(json[r'pricing']),
        images: ItemImageDto.listFromJson(json[r'images']),
        avgRating: mapValueOfType<double>(json, r'avgRating'),
        reviewCount: mapValueOfType<int>(json, r'reviewCount'),
        category: ItemListDtoCategory.fromJson(json[r'category']),
        subcategory: ItemListDtoSubcategory.fromJson(json[r'subcategory']),
        brand: ItemListDtoBrand.fromJson(json[r'brand']),
      );
    }
    return null;
  }

  static List<ItemDetailDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ItemDetailDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ItemDetailDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ItemDetailDto> mapFromJson(dynamic json) {
    final map = <String, ItemDetailDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ItemDetailDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ItemDetailDto-objects as value to a dart map
  static Map<String, List<ItemDetailDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ItemDetailDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ItemDetailDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

