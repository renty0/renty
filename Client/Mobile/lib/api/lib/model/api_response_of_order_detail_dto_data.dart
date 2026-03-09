//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfOrderDetailDtoData {
  /// Returns a new [ApiResponseOfOrderDetailDtoData] instance.
  ApiResponseOfOrderDetailDtoData({
    this.id,
    this.totalAmount,
    this.status,
    this.createdAt,
    this.items = const [],
    this.paymentStatus,
    this.deliveryStatus,
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

  List<OrderItemDetailDto> items;

  String? paymentStatus;

  String? deliveryStatus;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfOrderDetailDtoData &&
    other.id == id &&
    other.totalAmount == totalAmount &&
    other.status == status &&
    other.createdAt == createdAt &&
    _deepEquality.equals(other.items, items) &&
    other.paymentStatus == paymentStatus &&
    other.deliveryStatus == deliveryStatus;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (totalAmount == null ? 0 : totalAmount!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (items.hashCode) +
    (paymentStatus == null ? 0 : paymentStatus!.hashCode) +
    (deliveryStatus == null ? 0 : deliveryStatus!.hashCode);

  @override
  String toString() => 'ApiResponseOfOrderDetailDtoData[id=$id, totalAmount=$totalAmount, status=$status, createdAt=$createdAt, items=$items, paymentStatus=$paymentStatus, deliveryStatus=$deliveryStatus]';

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
      json[r'items'] = this.items;
    if (this.paymentStatus != null) {
      json[r'paymentStatus'] = this.paymentStatus;
    } else {
      json[r'paymentStatus'] = null;
    }
    if (this.deliveryStatus != null) {
      json[r'deliveryStatus'] = this.deliveryStatus;
    } else {
      json[r'deliveryStatus'] = null;
    }
    return json;
  }

  /// Returns a new [ApiResponseOfOrderDetailDtoData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfOrderDetailDtoData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfOrderDetailDtoData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfOrderDetailDtoData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfOrderDetailDtoData(
        id: mapValueOfType<String>(json, r'id'),
        totalAmount: json[r'totalAmount'] == null
            ? null
            : num.parse('${json[r'totalAmount']}'),
        status: mapValueOfType<String>(json, r'status'),
        createdAt: mapDateTime(json, r'createdAt', r''),
        items: OrderItemDetailDto.listFromJson(json[r'items']),
        paymentStatus: mapValueOfType<String>(json, r'paymentStatus'),
        deliveryStatus: mapValueOfType<String>(json, r'deliveryStatus'),
      );
    }
    return null;
  }

  static List<ApiResponseOfOrderDetailDtoData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfOrderDetailDtoData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfOrderDetailDtoData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfOrderDetailDtoData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfOrderDetailDtoData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfOrderDetailDtoData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfOrderDetailDtoData-objects as value to a dart map
  static Map<String, List<ApiResponseOfOrderDetailDtoData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfOrderDetailDtoData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfOrderDetailDtoData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

