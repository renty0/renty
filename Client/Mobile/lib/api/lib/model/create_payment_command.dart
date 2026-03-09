//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreatePaymentCommand {
  /// Returns a new [CreatePaymentCommand] instance.
  CreatePaymentCommand({
    this.orderId,
    this.method,
    this.transactionRef,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? orderId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? method;

  String? transactionRef;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreatePaymentCommand &&
    other.orderId == orderId &&
    other.method == method &&
    other.transactionRef == transactionRef;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (orderId == null ? 0 : orderId!.hashCode) +
    (method == null ? 0 : method!.hashCode) +
    (transactionRef == null ? 0 : transactionRef!.hashCode);

  @override
  String toString() => 'CreatePaymentCommand[orderId=$orderId, method=$method, transactionRef=$transactionRef]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.orderId != null) {
      json[r'orderId'] = this.orderId;
    } else {
      json[r'orderId'] = null;
    }
    if (this.method != null) {
      json[r'method'] = this.method;
    } else {
      json[r'method'] = null;
    }
    if (this.transactionRef != null) {
      json[r'transactionRef'] = this.transactionRef;
    } else {
      json[r'transactionRef'] = null;
    }
    return json;
  }

  /// Returns a new [CreatePaymentCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreatePaymentCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreatePaymentCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreatePaymentCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreatePaymentCommand(
        orderId: mapValueOfType<String>(json, r'orderId'),
        method: mapValueOfType<String>(json, r'method'),
        transactionRef: mapValueOfType<String>(json, r'transactionRef'),
      );
    }
    return null;
  }

  static List<CreatePaymentCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreatePaymentCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreatePaymentCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreatePaymentCommand> mapFromJson(dynamic json) {
    final map = <String, CreatePaymentCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreatePaymentCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreatePaymentCommand-objects as value to a dart map
  static Map<String, List<CreatePaymentCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreatePaymentCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreatePaymentCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

