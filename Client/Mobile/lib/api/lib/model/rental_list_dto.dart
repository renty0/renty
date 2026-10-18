//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RentalListDto {
  /// Returns a new [RentalListDto] instance.
  RentalListDto({
    this.id,
    this.itemTitle,
    this.itemImageUrl,
    this.ownerId,
    this.ownerFirstName,
    this.startDate,
    this.endDate,
    this.rentalPrice,
    this.status,
    this.depositStatus,
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
  String? itemTitle;

  String? itemImageUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ownerId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ownerFirstName;

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
  String? status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? depositStatus;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RentalListDto &&
    other.id == id &&
    other.itemTitle == itemTitle &&
    other.itemImageUrl == itemImageUrl &&
    other.ownerId == ownerId &&
    other.ownerFirstName == ownerFirstName &&
    other.startDate == startDate &&
    other.endDate == endDate &&
    other.rentalPrice == rentalPrice &&
    other.status == status &&
    other.depositStatus == depositStatus;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (itemTitle == null ? 0 : itemTitle!.hashCode) +
    (itemImageUrl == null ? 0 : itemImageUrl!.hashCode) +
    (ownerId == null ? 0 : ownerId!.hashCode) +
    (ownerFirstName == null ? 0 : ownerFirstName!.hashCode) +
    (startDate == null ? 0 : startDate!.hashCode) +
    (endDate == null ? 0 : endDate!.hashCode) +
    (rentalPrice == null ? 0 : rentalPrice!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (depositStatus == null ? 0 : depositStatus!.hashCode);

  @override
  String toString() => 'RentalListDto[id=$id, itemTitle=$itemTitle, itemImageUrl=$itemImageUrl, ownerId=$ownerId, ownerFirstName=$ownerFirstName, startDate=$startDate, endDate=$endDate, rentalPrice=$rentalPrice, status=$status, depositStatus=$depositStatus]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.itemTitle != null) {
      json[r'itemTitle'] = this.itemTitle;
    } else {
      json[r'itemTitle'] = null;
    }
    if (this.itemImageUrl != null) {
      json[r'itemImageUrl'] = this.itemImageUrl;
    } else {
      json[r'itemImageUrl'] = null;
    }
    if (this.ownerId != null) {
      json[r'ownerId'] = this.ownerId;
    } else {
      json[r'ownerId'] = null;
    }
    if (this.ownerFirstName != null) {
      json[r'ownerFirstName'] = this.ownerFirstName;
    } else {
      json[r'ownerFirstName'] = null;
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
    if (this.rentalPrice != null) {
      json[r'rentalPrice'] = this.rentalPrice;
    } else {
      json[r'rentalPrice'] = null;
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
    return json;
  }

  /// Returns a new [RentalListDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RentalListDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RentalListDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RentalListDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RentalListDto(
        id: mapValueOfType<String>(json, r'id'),
        itemTitle: mapValueOfType<String>(json, r'itemTitle'),
        itemImageUrl: mapValueOfType<String>(json, r'itemImageUrl'),
        ownerId: mapValueOfType<int>(json, r'ownerId'),
        ownerFirstName: mapValueOfType<String>(json, r'ownerFirstName'),
        startDate: mapDateTime(json, r'startDate', r''),
        endDate: mapDateTime(json, r'endDate', r''),
        rentalPrice: num.parse('${json[r'rentalPrice']}'),
        status: mapValueOfType<String>(json, r'status'),
        depositStatus: mapValueOfType<String>(json, r'depositStatus'),
      );
    }
    return null;
  }

  static List<RentalListDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RentalListDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RentalListDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RentalListDto> mapFromJson(dynamic json) {
    final map = <String, RentalListDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RentalListDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RentalListDto-objects as value to a dart map
  static Map<String, List<RentalListDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RentalListDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RentalListDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

