//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RentalCreateData {
  /// Returns a new [RentalCreateData] instance.
  RentalCreateData({
    this.rentalId,
    this.orderId,
    this.rentalPrice,
    this.depositAmount,
    this.status,
  });

  String? rentalId;

  String? orderId;

  num? rentalPrice;

  num? depositAmount;

  String? status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RentalCreateData &&
    other.rentalId == rentalId &&
    other.orderId == orderId &&
    other.rentalPrice == rentalPrice &&
    other.depositAmount == depositAmount &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (rentalId == null ? 0 : rentalId!.hashCode) +
    (orderId == null ? 0 : orderId!.hashCode) +
    (rentalPrice == null ? 0 : rentalPrice!.hashCode) +
    (depositAmount == null ? 0 : depositAmount!.hashCode) +
    (status == null ? 0 : status!.hashCode);

  @override
  String toString() => 'RentalCreateData[rentalId=$rentalId, orderId=$orderId, rentalPrice=$rentalPrice, depositAmount=$depositAmount, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.rentalId != null) {
      json[r'rentalId'] = this.rentalId;
    } else {
      json[r'rentalId'] = null;
    }
    if (this.orderId != null) {
      json[r'orderId'] = this.orderId;
    } else {
      json[r'orderId'] = null;
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
    return json;
  }

  /// Returns a new [RentalCreateData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RentalCreateData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RentalCreateData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RentalCreateData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RentalCreateData(
        rentalId: mapValueOfType<String>(json, r'rentalId'),
        orderId: mapValueOfType<String>(json, r'orderId'),
        rentalPrice: json[r'rentalPrice'] == null
            ? null
            : num.parse('${json[r'rentalPrice']}'),
        depositAmount: json[r'depositAmount'] == null
            ? null
            : num.parse('${json[r'depositAmount']}'),
        status: mapValueOfType<String>(json, r'status'),
      );
    }
    return null;
  }

  static List<RentalCreateData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RentalCreateData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RentalCreateData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RentalCreateData> mapFromJson(dynamic json) {
    final map = <String, RentalCreateData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RentalCreateData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RentalCreateData-objects as value to a dart map
  static Map<String, List<RentalCreateData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RentalCreateData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RentalCreateData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

