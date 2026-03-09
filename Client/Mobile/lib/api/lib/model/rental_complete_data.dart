//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RentalCompleteData {
  /// Returns a new [RentalCompleteData] instance.
  RentalCompleteData({
    this.rentalId,
    this.status,
    this.lateFee,
    this.depositStatus,
  });

  String? rentalId;

  String? status;

  num? lateFee;

  String? depositStatus;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RentalCompleteData &&
    other.rentalId == rentalId &&
    other.status == status &&
    other.lateFee == lateFee &&
    other.depositStatus == depositStatus;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (rentalId == null ? 0 : rentalId!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (lateFee == null ? 0 : lateFee!.hashCode) +
    (depositStatus == null ? 0 : depositStatus!.hashCode);

  @override
  String toString() => 'RentalCompleteData[rentalId=$rentalId, status=$status, lateFee=$lateFee, depositStatus=$depositStatus]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.rentalId != null) {
      json[r'rentalId'] = this.rentalId;
    } else {
      json[r'rentalId'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.lateFee != null) {
      json[r'lateFee'] = this.lateFee;
    } else {
      json[r'lateFee'] = null;
    }
    if (this.depositStatus != null) {
      json[r'depositStatus'] = this.depositStatus;
    } else {
      json[r'depositStatus'] = null;
    }
    return json;
  }

  /// Returns a new [RentalCompleteData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RentalCompleteData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RentalCompleteData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RentalCompleteData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RentalCompleteData(
        rentalId: mapValueOfType<String>(json, r'rentalId'),
        status: mapValueOfType<String>(json, r'status'),
        lateFee: json[r'lateFee'] == null
            ? null
            : num.parse('${json[r'lateFee']}'),
        depositStatus: mapValueOfType<String>(json, r'depositStatus'),
      );
    }
    return null;
  }

  static List<RentalCompleteData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RentalCompleteData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RentalCompleteData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RentalCompleteData> mapFromJson(dynamic json) {
    final map = <String, RentalCompleteData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RentalCompleteData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RentalCompleteData-objects as value to a dart map
  static Map<String, List<RentalCompleteData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RentalCompleteData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RentalCompleteData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

