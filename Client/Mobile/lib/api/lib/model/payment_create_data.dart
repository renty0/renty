//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PaymentCreateData {
  /// Returns a new [PaymentCreateData] instance.
  PaymentCreateData({
    this.paymentId,
    this.status,
    this.transactionRef,
  });

  String? paymentId;

  String? status;

  String? transactionRef;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentCreateData &&
    other.paymentId == paymentId &&
    other.status == status &&
    other.transactionRef == transactionRef;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (paymentId == null ? 0 : paymentId!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (transactionRef == null ? 0 : transactionRef!.hashCode);

  @override
  String toString() => 'PaymentCreateData[paymentId=$paymentId, status=$status, transactionRef=$transactionRef]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.paymentId != null) {
      json[r'paymentId'] = this.paymentId;
    } else {
      json[r'paymentId'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.transactionRef != null) {
      json[r'transactionRef'] = this.transactionRef;
    } else {
      json[r'transactionRef'] = null;
    }
    return json;
  }

  /// Returns a new [PaymentCreateData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentCreateData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PaymentCreateData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PaymentCreateData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PaymentCreateData(
        paymentId: mapValueOfType<String>(json, r'paymentId'),
        status: mapValueOfType<String>(json, r'status'),
        transactionRef: mapValueOfType<String>(json, r'transactionRef'),
      );
    }
    return null;
  }

  static List<PaymentCreateData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentCreateData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentCreateData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentCreateData> mapFromJson(dynamic json) {
    final map = <String, PaymentCreateData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentCreateData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentCreateData-objects as value to a dart map
  static Map<String, List<PaymentCreateData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentCreateData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentCreateData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

