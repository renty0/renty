//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RentalDetailDto {
  /// Returns a new [RentalDetailDto] instance.
  RentalDetailDto({
    this.id,
    this.itemId,
    this.itemTitle,
    this.itemImage,
    this.ownerFirstName,
    this.ownerCity,
    this.startDate,
    this.endDate,
    this.actualReturnDate,
    this.rentalPrice,
    this.depositAmount,
    this.lateFee,
    this.status,
    this.depositStatus,
    this.notes,
    this.createdAt,
    this.hasReview,
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
  String? itemId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? itemTitle;

  String? itemImage;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ownerFirstName;

  String? ownerCity;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? startDate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? endDate;

  DateTime? actualReturnDate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? rentalPrice;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? depositAmount;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? lateFee;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? depositStatus;

  String? notes;

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
  bool? hasReview;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RentalDetailDto &&
    other.id == id &&
    other.itemId == itemId &&
    other.itemTitle == itemTitle &&
    other.itemImage == itemImage &&
    other.ownerFirstName == ownerFirstName &&
    other.ownerCity == ownerCity &&
    other.startDate == startDate &&
    other.endDate == endDate &&
    other.actualReturnDate == actualReturnDate &&
    other.rentalPrice == rentalPrice &&
    other.depositAmount == depositAmount &&
    other.lateFee == lateFee &&
    other.status == status &&
    other.depositStatus == depositStatus &&
    other.notes == notes &&
    other.createdAt == createdAt &&
    other.hasReview == hasReview;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (itemId == null ? 0 : itemId!.hashCode) +
    (itemTitle == null ? 0 : itemTitle!.hashCode) +
    (itemImage == null ? 0 : itemImage!.hashCode) +
    (ownerFirstName == null ? 0 : ownerFirstName!.hashCode) +
    (ownerCity == null ? 0 : ownerCity!.hashCode) +
    (startDate == null ? 0 : startDate!.hashCode) +
    (endDate == null ? 0 : endDate!.hashCode) +
    (actualReturnDate == null ? 0 : actualReturnDate!.hashCode) +
    (rentalPrice == null ? 0 : rentalPrice!.hashCode) +
    (depositAmount == null ? 0 : depositAmount!.hashCode) +
    (lateFee == null ? 0 : lateFee!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (depositStatus == null ? 0 : depositStatus!.hashCode) +
    (notes == null ? 0 : notes!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (hasReview == null ? 0 : hasReview!.hashCode);

  @override
  String toString() => 'RentalDetailDto[id=$id, itemId=$itemId, itemTitle=$itemTitle, itemImage=$itemImage, ownerFirstName=$ownerFirstName, ownerCity=$ownerCity, startDate=$startDate, endDate=$endDate, actualReturnDate=$actualReturnDate, rentalPrice=$rentalPrice, depositAmount=$depositAmount, lateFee=$lateFee, status=$status, depositStatus=$depositStatus, notes=$notes, createdAt=$createdAt, hasReview=$hasReview]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.itemId != null) {
      json[r'itemId'] = this.itemId;
    } else {
      json[r'itemId'] = null;
    }
    if (this.itemTitle != null) {
      json[r'itemTitle'] = this.itemTitle;
    } else {
      json[r'itemTitle'] = null;
    }
    if (this.itemImage != null) {
      json[r'itemImage'] = this.itemImage;
    } else {
      json[r'itemImage'] = null;
    }
    if (this.ownerFirstName != null) {
      json[r'ownerFirstName'] = this.ownerFirstName;
    } else {
      json[r'ownerFirstName'] = null;
    }
    if (this.ownerCity != null) {
      json[r'ownerCity'] = this.ownerCity;
    } else {
      json[r'ownerCity'] = null;
    }
    if (this.startDate != null) {
      json[r'startDate'] = this.startDate!.toUtc().toIso8601String();
    } else {
      json[r'startDate'] = null;
    }
    if (this.endDate != null) {
      json[r'endDate'] = this.endDate!.toUtc().toIso8601String();
    } else {
      json[r'endDate'] = null;
    }
    if (this.actualReturnDate != null) {
      json[r'actualReturnDate'] = this.actualReturnDate!.toUtc().toIso8601String();
    } else {
      json[r'actualReturnDate'] = null;
    }
    if (this.rentalPrice != null) {
      json[r'rentalPrice'] = this.rentalPrice;
    } else {
      json[r'rentalPrice'] = null;
    }
    if (this.depositAmount != null) {
      json[r'depositAmount'] = this.depositAmount;
    } else {
      json[r'depositAmount'] = null;
    }
    if (this.lateFee != null) {
      json[r'lateFee'] = this.lateFee;
    } else {
      json[r'lateFee'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.depositStatus != null) {
      json[r'depositStatus'] = this.depositStatus;
    } else {
      json[r'depositStatus'] = null;
    }
    if (this.notes != null) {
      json[r'notes'] = this.notes;
    } else {
      json[r'notes'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    if (this.hasReview != null) {
      json[r'hasReview'] = this.hasReview;
    } else {
      json[r'hasReview'] = null;
    }
    return json;
  }

  /// Returns a new [RentalDetailDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RentalDetailDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RentalDetailDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RentalDetailDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RentalDetailDto(
        id: mapValueOfType<String>(json, r'id'),
        itemId: mapValueOfType<String>(json, r'itemId'),
        itemTitle: mapValueOfType<String>(json, r'itemTitle'),
        itemImage: mapValueOfType<String>(json, r'itemImage'),
        ownerFirstName: mapValueOfType<String>(json, r'ownerFirstName'),
        ownerCity: mapValueOfType<String>(json, r'ownerCity'),
        startDate: mapDateTime(json, r'startDate', r''),
        endDate: mapDateTime(json, r'endDate', r''),
        actualReturnDate: mapDateTime(json, r'actualReturnDate', r''),
        rentalPrice: num.parse('${json[r'rentalPrice']}'),
        depositAmount: num.parse('${json[r'depositAmount']}'),
        lateFee: num.parse('${json[r'lateFee']}'),
        status: mapValueOfType<String>(json, r'status'),
        depositStatus: mapValueOfType<String>(json, r'depositStatus'),
        notes: mapValueOfType<String>(json, r'notes'),
        createdAt: mapDateTime(json, r'createdAt', r''),
        hasReview: mapValueOfType<bool>(json, r'hasReview'),
      );
    }
    return null;
  }

  static List<RentalDetailDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RentalDetailDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RentalDetailDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RentalDetailDto> mapFromJson(dynamic json) {
    final map = <String, RentalDetailDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RentalDetailDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RentalDetailDto-objects as value to a dart map
  static Map<String, List<RentalDetailDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RentalDetailDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RentalDetailDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

