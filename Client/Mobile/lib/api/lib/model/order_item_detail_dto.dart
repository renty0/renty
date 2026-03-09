//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OrderItemDetailDto {
  /// Returns a new [OrderItemDetailDto] instance.
  OrderItemDetailDto({
    this.itemId,
    this.title,
    this.quantity,
    this.priceAtTime,
    this.primaryImage,
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
  String? title;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? quantity;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? priceAtTime;

  String? primaryImage;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OrderItemDetailDto &&
    other.itemId == itemId &&
    other.title == title &&
    other.quantity == quantity &&
    other.priceAtTime == priceAtTime &&
    other.primaryImage == primaryImage;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (itemId == null ? 0 : itemId!.hashCode) +
    (title == null ? 0 : title!.hashCode) +
    (quantity == null ? 0 : quantity!.hashCode) +
    (priceAtTime == null ? 0 : priceAtTime!.hashCode) +
    (primaryImage == null ? 0 : primaryImage!.hashCode);

  @override
  String toString() => 'OrderItemDetailDto[itemId=$itemId, title=$title, quantity=$quantity, priceAtTime=$priceAtTime, primaryImage=$primaryImage]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.itemId != null) {
      json[r'itemId'] = this.itemId;
    } else {
      json[r'itemId'] = null;
    }
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
    if (this.quantity != null) {
      json[r'quantity'] = this.quantity;
    } else {
      json[r'quantity'] = null;
    }
    if (this.priceAtTime != null) {
      json[r'priceAtTime'] = this.priceAtTime;
    } else {
      json[r'priceAtTime'] = null;
    }
    if (this.primaryImage != null) {
      json[r'primaryImage'] = this.primaryImage;
    } else {
      json[r'primaryImage'] = null;
    }
    return json;
  }

  /// Returns a new [OrderItemDetailDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OrderItemDetailDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OrderItemDetailDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OrderItemDetailDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OrderItemDetailDto(
        itemId: mapValueOfType<String>(json, r'itemId'),
        title: mapValueOfType<String>(json, r'title'),
        quantity: mapValueOfType<int>(json, r'quantity'),
        priceAtTime: num.parse('${json[r'priceAtTime']}'),
        primaryImage: mapValueOfType<String>(json, r'primaryImage'),
      );
    }
    return null;
  }

  static List<OrderItemDetailDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OrderItemDetailDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OrderItemDetailDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OrderItemDetailDto> mapFromJson(dynamic json) {
    final map = <String, OrderItemDetailDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OrderItemDetailDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OrderItemDetailDto-objects as value to a dart map
  static Map<String, List<OrderItemDetailDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OrderItemDetailDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OrderItemDetailDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

