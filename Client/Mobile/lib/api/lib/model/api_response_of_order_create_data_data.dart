//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfOrderCreateDataData {
  /// Returns a new [ApiResponseOfOrderCreateDataData] instance.
  ApiResponseOfOrderCreateDataData({
    this.orderId,
    this.totalAmount,
    this.status,
  });

  String? orderId;

  num? totalAmount;

  String? status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfOrderCreateDataData &&
    other.orderId == orderId &&
    other.totalAmount == totalAmount &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (orderId == null ? 0 : orderId!.hashCode) +
    (totalAmount == null ? 0 : totalAmount!.hashCode) +
    (status == null ? 0 : status!.hashCode);

  @override
  String toString() => 'ApiResponseOfOrderCreateDataData[orderId=$orderId, totalAmount=$totalAmount, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.orderId != null) {
      json[r'orderId'] = this.orderId;
    } else {
      json[r'orderId'] = null;
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
    return json;
  }

  /// Returns a new [ApiResponseOfOrderCreateDataData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfOrderCreateDataData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfOrderCreateDataData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfOrderCreateDataData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfOrderCreateDataData(
        orderId: mapValueOfType<String>(json, r'orderId'),
        totalAmount: json[r'totalAmount'] == null
            ? null
            : num.parse('${json[r'totalAmount']}'),
        status: mapValueOfType<String>(json, r'status'),
      );
    }
    return null;
  }

  static List<ApiResponseOfOrderCreateDataData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfOrderCreateDataData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfOrderCreateDataData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfOrderCreateDataData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfOrderCreateDataData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfOrderCreateDataData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfOrderCreateDataData-objects as value to a dart map
  static Map<String, List<ApiResponseOfOrderCreateDataData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfOrderCreateDataData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfOrderCreateDataData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

