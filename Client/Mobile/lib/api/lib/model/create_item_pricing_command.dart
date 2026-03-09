//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateItemPricingCommand {
  /// Returns a new [CreateItemPricingCommand] instance.
  CreateItemPricingCommand({
    this.price,
    this.pricingType,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? price;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? pricingType;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateItemPricingCommand &&
    other.price == price &&
    other.pricingType == pricingType;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (price == null ? 0 : price!.hashCode) +
    (pricingType == null ? 0 : pricingType!.hashCode);

  @override
  String toString() => 'CreateItemPricingCommand[price=$price, pricingType=$pricingType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.price != null) {
      json[r'price'] = this.price;
    } else {
      json[r'price'] = null;
    }
    if (this.pricingType != null) {
      json[r'pricingType'] = this.pricingType;
    } else {
      json[r'pricingType'] = null;
    }
    return json;
  }

  /// Returns a new [CreateItemPricingCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateItemPricingCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateItemPricingCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateItemPricingCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateItemPricingCommand(
        price: num.parse('${json[r'price']}'),
        pricingType: mapValueOfType<String>(json, r'pricingType'),
      );
    }
    return null;
  }

  static List<CreateItemPricingCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateItemPricingCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateItemPricingCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateItemPricingCommand> mapFromJson(dynamic json) {
    final map = <String, CreateItemPricingCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateItemPricingCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateItemPricingCommand-objects as value to a dart map
  static Map<String, List<CreateItemPricingCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateItemPricingCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateItemPricingCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

