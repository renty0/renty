//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RequestWithdrawalCommand {
  /// Returns a new [RequestWithdrawalCommand] instance.
  RequestWithdrawalCommand({
    this.amount,
    this.mobileWalletNumber,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? amount;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mobileWalletNumber;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RequestWithdrawalCommand &&
    other.amount == amount &&
    other.mobileWalletNumber == mobileWalletNumber;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (amount == null ? 0 : amount!.hashCode) +
    (mobileWalletNumber == null ? 0 : mobileWalletNumber!.hashCode);

  @override
  String toString() => 'RequestWithdrawalCommand[amount=$amount, mobileWalletNumber=$mobileWalletNumber]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.amount != null) {
      json[r'amount'] = this.amount;
    } else {
      json[r'amount'] = null;
    }
    if (this.mobileWalletNumber != null) {
      json[r'mobileWalletNumber'] = this.mobileWalletNumber;
    } else {
      json[r'mobileWalletNumber'] = null;
    }
    return json;
  }

  /// Returns a new [RequestWithdrawalCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RequestWithdrawalCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RequestWithdrawalCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RequestWithdrawalCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RequestWithdrawalCommand(
        amount: num.parse('${json[r'amount']}'),
        mobileWalletNumber: mapValueOfType<String>(json, r'mobileWalletNumber'),
      );
    }
    return null;
  }

  static List<RequestWithdrawalCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RequestWithdrawalCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RequestWithdrawalCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RequestWithdrawalCommand> mapFromJson(dynamic json) {
    final map = <String, RequestWithdrawalCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RequestWithdrawalCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RequestWithdrawalCommand-objects as value to a dart map
  static Map<String, List<RequestWithdrawalCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RequestWithdrawalCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RequestWithdrawalCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

