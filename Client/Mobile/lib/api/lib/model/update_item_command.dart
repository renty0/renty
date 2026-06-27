//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateItemCommand {
  /// Returns a new [UpdateItemCommand] instance.
  UpdateItemCommand({
    this.itemId,
    this.titleAr,
    this.titleEn,
    this.descAr,
    this.descEn,
    this.type,
    this.condition,
    this.defaultDeposit,
    this.location,
    this.city,
    this.lat,
    this.lng,
    this.categoryId,
    this.subcategoryId,
    this.brandId,
    this.isForSale,
    this.salePrice,
    this.pricing = const [],
    this.images = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? itemId;

  String? titleAr;

  String? titleEn;

  String? descAr;

  String? descEn;

  String? type;

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

  int? categoryId;

  int? subcategoryId;

  int? brandId;

  bool? isForSale;

  num? salePrice;

  List<CreateItemPricingCommand>? pricing;

  List<CreateItemImageCommand>? images;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateItemCommand &&
    other.itemId == itemId &&
    other.titleAr == titleAr &&
    other.titleEn == titleEn &&
    other.descAr == descAr &&
    other.descEn == descEn &&
    other.type == type &&
    other.condition == condition &&
    other.defaultDeposit == defaultDeposit &&
    other.location == location &&
    other.city == city &&
    other.lat == lat &&
    other.lng == lng &&
    other.categoryId == categoryId &&
    other.subcategoryId == subcategoryId &&
    other.brandId == brandId &&
    other.isForSale == isForSale &&
    other.salePrice == salePrice &&
    _deepEquality.equals(other.pricing, pricing) &&
    _deepEquality.equals(other.images, images);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (itemId == null ? 0 : itemId!.hashCode) +
    (titleAr == null ? 0 : titleAr!.hashCode) +
    (titleEn == null ? 0 : titleEn!.hashCode) +
    (descAr == null ? 0 : descAr!.hashCode) +
    (descEn == null ? 0 : descEn!.hashCode) +
    (type == null ? 0 : type!.hashCode) +
    (condition == null ? 0 : condition!.hashCode) +
    (defaultDeposit == null ? 0 : defaultDeposit!.hashCode) +
    (location == null ? 0 : location!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (lat == null ? 0 : lat!.hashCode) +
    (lng == null ? 0 : lng!.hashCode) +
    (categoryId == null ? 0 : categoryId!.hashCode) +
    (subcategoryId == null ? 0 : subcategoryId!.hashCode) +
    (brandId == null ? 0 : brandId!.hashCode) +
    (isForSale == null ? 0 : isForSale!.hashCode) +
    (salePrice == null ? 0 : salePrice!.hashCode) +
    (pricing == null ? 0 : pricing!.hashCode) +
    (images == null ? 0 : images!.hashCode);

  @override
  String toString() => 'UpdateItemCommand[itemId=$itemId, titleAr=$titleAr, titleEn=$titleEn, descAr=$descAr, descEn=$descEn, type=$type, condition=$condition, defaultDeposit=$defaultDeposit, location=$location, city=$city, lat=$lat, lng=$lng, categoryId=$categoryId, subcategoryId=$subcategoryId, brandId=$brandId, isForSale=$isForSale, salePrice=$salePrice, pricing=$pricing, images=$images]';

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
    if (this.categoryId != null) {
      json[r'categoryId'] = this.categoryId;
    } else {
      json[r'categoryId'] = null;
    }
    if (this.subcategoryId != null) {
      json[r'subcategoryId'] = this.subcategoryId;
    } else {
      json[r'subcategoryId'] = null;
    }
    if (this.brandId != null) {
      json[r'brandId'] = this.brandId;
    } else {
      json[r'brandId'] = null;
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
    if (this.pricing != null) {
      json[r'pricing'] = this.pricing;
    } else {
      json[r'pricing'] = null;
    }
    if (this.images != null) {
      json[r'images'] = this.images;
    } else {
      json[r'images'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateItemCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateItemCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateItemCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateItemCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateItemCommand(
        itemId: mapValueOfType<String>(json, r'itemId'),
        titleAr: mapValueOfType<String>(json, r'titleAr'),
        titleEn: mapValueOfType<String>(json, r'titleEn'),
        descAr: mapValueOfType<String>(json, r'descAr'),
        descEn: mapValueOfType<String>(json, r'descEn'),
        type: mapValueOfType<String>(json, r'type'),
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
        categoryId: mapValueOfType<int>(json, r'categoryId'),
        subcategoryId: mapValueOfType<int>(json, r'subcategoryId'),
        brandId: mapValueOfType<int>(json, r'brandId'),
        isForSale: mapValueOfType<bool>(json, r'isForSale'),
        salePrice: json[r'salePrice'] == null
            ? null
            : num.parse('${json[r'salePrice']}'),
        pricing: CreateItemPricingCommand.listFromJson(json[r'pricing']),
        images: CreateItemImageCommand.listFromJson(json[r'images']),
      );
    }
    return null;
  }

  static List<UpdateItemCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateItemCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateItemCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateItemCommand> mapFromJson(dynamic json) {
    final map = <String, UpdateItemCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateItemCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateItemCommand-objects as value to a dart map
  static Map<String, List<UpdateItemCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateItemCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateItemCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

