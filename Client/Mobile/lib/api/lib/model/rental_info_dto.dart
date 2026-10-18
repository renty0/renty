//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RentalInfoDto {
  /// Returns a new [RentalInfoDto] instance.
  RentalInfoDto({
    this.rentalId,
    this.startDate,
    this.endDate,
    this.rentalPrice,
    this.depositAmount,
    this.status,
    this.renter,
    this.currentPossession,
    this.hasReturnTransfers,
    this.pendingTransferType,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? rentalId;

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
  num? depositAmount;

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
  PersonInfoDto? renter;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? currentPossession;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? hasReturnTransfers;

  String? pendingTransferType;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RentalInfoDto &&
    other.rentalId == rentalId &&
    other.startDate == startDate &&
    other.endDate == endDate &&
    other.rentalPrice == rentalPrice &&
    other.depositAmount == depositAmount &&
    other.status == status &&
    other.renter == renter &&
    other.currentPossession == currentPossession &&
    other.hasReturnTransfers == hasReturnTransfers &&
    other.pendingTransferType == pendingTransferType;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (rentalId == null ? 0 : rentalId!.hashCode) +
    (startDate == null ? 0 : startDate!.hashCode) +
    (endDate == null ? 0 : endDate!.hashCode) +
    (rentalPrice == null ? 0 : rentalPrice!.hashCode) +
    (depositAmount == null ? 0 : depositAmount!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (renter == null ? 0 : renter!.hashCode) +
    (currentPossession == null ? 0 : currentPossession!.hashCode) +
    (hasReturnTransfers == null ? 0 : hasReturnTransfers!.hashCode) +
    (pendingTransferType == null ? 0 : pendingTransferType!.hashCode);

  @override
  String toString() => 'RentalInfoDto[rentalId=$rentalId, startDate=$startDate, endDate=$endDate, rentalPrice=$rentalPrice, depositAmount=$depositAmount, status=$status, renter=$renter, currentPossession=$currentPossession, hasReturnTransfers=$hasReturnTransfers, pendingTransferType=$pendingTransferType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.rentalId != null) {
      json[r'rentalId'] = this.rentalId;
    } else {
      json[r'rentalId'] = null;
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
    if (this.depositAmount != null) {
      json[r'depositAmount'] = this.depositAmount;
    } else {
      json[r'depositAmount'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.renter != null) {
      json[r'renter'] = this.renter;
    } else {
      json[r'renter'] = null;
    }
    if (this.currentPossession != null) {
      json[r'currentPossession'] = this.currentPossession;
    } else {
      json[r'currentPossession'] = null;
    }
    if (this.hasReturnTransfers != null) {
      json[r'hasReturnTransfers'] = this.hasReturnTransfers;
    } else {
      json[r'hasReturnTransfers'] = null;
    }
    if (this.pendingTransferType != null) {
      json[r'pendingTransferType'] = this.pendingTransferType;
    } else {
      json[r'pendingTransferType'] = null;
    }
    return json;
  }

  /// Returns a new [RentalInfoDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RentalInfoDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RentalInfoDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RentalInfoDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RentalInfoDto(
        rentalId: mapValueOfType<String>(json, r'rentalId'),
        startDate: mapDateTime(json, r'startDate', r''),
        endDate: mapDateTime(json, r'endDate', r''),
        rentalPrice: num.parse('${json[r'rentalPrice']}'),
        depositAmount: num.parse('${json[r'depositAmount']}'),
        status: mapValueOfType<String>(json, r'status'),
        renter: PersonInfoDto.fromJson(json[r'renter']),
        currentPossession: mapValueOfType<String>(json, r'currentPossession'),
        hasReturnTransfers: mapValueOfType<bool>(json, r'hasReturnTransfers'),
        pendingTransferType: mapValueOfType<String>(json, r'pendingTransferType'),
      );
    }
    return null;
  }

  static List<RentalInfoDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RentalInfoDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RentalInfoDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RentalInfoDto> mapFromJson(dynamic json) {
    final map = <String, RentalInfoDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RentalInfoDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RentalInfoDto-objects as value to a dart map
  static Map<String, List<RentalInfoDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RentalInfoDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RentalInfoDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

