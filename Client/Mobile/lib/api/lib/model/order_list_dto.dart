//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OrderListDto {
  /// Returns a new [OrderListDto] instance.
  OrderListDto({
    this.id,
    this.totalAmount,
    this.status,
    this.createdAt,
    this.itemCount,
    this.primaryImageUrl,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  num? totalAmount;

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
  DateTime? createdAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? itemCount;

  String? primaryImageUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OrderListDto &&
    other.id == id &&
    other.totalAmount == totalAmount &&
    other.status == status &&
    other.createdAt == createdAt &&
    other.itemCount == itemCount &&
    other.primaryImageUrl == primaryImageUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (totalAmount == null ? 0 : totalAmount!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (itemCount == null ? 0 : itemCount!.hashCode) +
    (primaryImageUrl == null ? 0 : primaryImageUrl!.hashCode);

  @override
  String toString() => 'OrderListDto[id=$id, totalAmount=$totalAmount, status=$status, createdAt=$createdAt, itemCount=$itemCount, primaryImageUrl=$primaryImageUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.totalAmount != null) {
      json[r'totalAmount'] = this.totalAmount;
    } else {
      json[r'totalAmount'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    if (this.itemCount != null) {
      json[r'itemCount'] = this.itemCount;
    } else {
      json[r'itemCount'] = null;
    }
    if (this.primaryImageUrl != null) {
      json[r'primaryImageUrl'] = this.primaryImageUrl;
    } else {
      json[r'primaryImageUrl'] = null;
    }
    return json;
  }

  /// Returns a new [OrderListDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OrderListDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OrderListDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OrderListDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OrderListDto(
        id: mapValueOfType<String>(json, r'id'),
        totalAmount: json[r'totalAmount'] == null
            ? null
            : num.parse('${json[r'totalAmount']}'),
        status: mapValueOfType<String>(json, r'status'),
        createdAt: mapDateTime(json, r'createdAt', r''),
        itemCount: mapValueOfType<int>(json, r'itemCount'),
        primaryImageUrl: mapValueOfType<String>(json, r'primaryImageUrl'),
      );
    }
    return null;
  }

  static List<OrderListDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OrderListDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OrderListDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OrderListDto> mapFromJson(dynamic json) {
    final map = <String, OrderListDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OrderListDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OrderListDto-objects as value to a dart map
  static Map<String, List<OrderListDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OrderListDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OrderListDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

