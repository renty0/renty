//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OrderItemInputDto {
  /// Returns a new [OrderItemInputDto] instance.
  OrderItemInputDto({
    this.itemId,
    this.quantity,
  });

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
  int? quantity;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OrderItemInputDto &&
    other.itemId == itemId &&
    other.quantity == quantity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (itemId == null ? 0 : itemId!.hashCode) +
    (quantity == null ? 0 : quantity!.hashCode);

  @override
  String toString() => 'OrderItemInputDto[itemId=$itemId, quantity=$quantity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.itemId != null) {
      json[r'itemId'] = this.itemId;
    } else {
      json[r'itemId'] = null;
    }
    if (this.quantity != null) {
      json[r'quantity'] = this.quantity;
    } else {
      json[r'quantity'] = null;
    }
    return json;
  }

  /// Returns a new [OrderItemInputDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OrderItemInputDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OrderItemInputDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OrderItemInputDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OrderItemInputDto(
        itemId: mapValueOfType<String>(json, r'itemId'),
        quantity: mapValueOfType<int>(json, r'quantity'),
      );
    }
    return null;
  }

  static List<OrderItemInputDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OrderItemInputDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OrderItemInputDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OrderItemInputDto> mapFromJson(dynamic json) {
    final map = <String, OrderItemInputDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OrderItemInputDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OrderItemInputDto-objects as value to a dart map
  static Map<String, List<OrderItemInputDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OrderItemInputDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OrderItemInputDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

