//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfBrandDtoData {
  /// Returns a new [ApiResponseOfBrandDtoData] instance.
  ApiResponseOfBrandDtoData({
    this.id,
    this.nameAr,
    this.nameEn,
    this.descAr,
    this.descEn,
    this.logoId,
    this.logoUrl,
    this.itemCount,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nameAr;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nameEn;

  String? descAr;

  String? descEn;

  String? logoId;

  String? logoUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? itemCount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfBrandDtoData &&
    other.id == id &&
    other.nameAr == nameAr &&
    other.nameEn == nameEn &&
    other.descAr == descAr &&
    other.descEn == descEn &&
    other.logoId == logoId &&
    other.logoUrl == logoUrl &&
    other.itemCount == itemCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (nameAr == null ? 0 : nameAr!.hashCode) +
    (nameEn == null ? 0 : nameEn!.hashCode) +
    (descAr == null ? 0 : descAr!.hashCode) +
    (descEn == null ? 0 : descEn!.hashCode) +
    (logoId == null ? 0 : logoId!.hashCode) +
    (logoUrl == null ? 0 : logoUrl!.hashCode) +
    (itemCount == null ? 0 : itemCount!.hashCode);

  @override
  String toString() => 'ApiResponseOfBrandDtoData[id=$id, nameAr=$nameAr, nameEn=$nameEn, descAr=$descAr, descEn=$descEn, logoId=$logoId, logoUrl=$logoUrl, itemCount=$itemCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.nameAr != null) {
      json[r'nameAr'] = this.nameAr;
    } else {
      json[r'nameAr'] = null;
    }
    if (this.nameEn != null) {
      json[r'nameEn'] = this.nameEn;
    } else {
      json[r'nameEn'] = null;
    }
    if (this.descAr != null) {
      json[r'descAr'] = this.descAr;
    } else {
      json[r'descAr'] = null;
    }
    if (this.descEn != null) {
      json[r'descEn'] = this.descEn;
    } else {
      json[r'descEn'] = null;
    }
    if (this.logoId != null) {
      json[r'logoId'] = this.logoId;
    } else {
      json[r'logoId'] = null;
    }
    if (this.logoUrl != null) {
      json[r'logoUrl'] = this.logoUrl;
    } else {
      json[r'logoUrl'] = null;
    }
    if (this.itemCount != null) {
      json[r'itemCount'] = this.itemCount;
    } else {
      json[r'itemCount'] = null;
    }
    return json;
  }

  /// Returns a new [ApiResponseOfBrandDtoData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfBrandDtoData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfBrandDtoData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfBrandDtoData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfBrandDtoData(
        id: mapValueOfType<int>(json, r'id'),
        nameAr: mapValueOfType<String>(json, r'nameAr'),
        nameEn: mapValueOfType<String>(json, r'nameEn'),
        descAr: mapValueOfType<String>(json, r'descAr'),
        descEn: mapValueOfType<String>(json, r'descEn'),
        logoId: mapValueOfType<String>(json, r'logoId'),
        logoUrl: mapValueOfType<String>(json, r'logoUrl'),
        itemCount: mapValueOfType<int>(json, r'itemCount'),
      );
    }
    return null;
  }

  static List<ApiResponseOfBrandDtoData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfBrandDtoData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfBrandDtoData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfBrandDtoData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfBrandDtoData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfBrandDtoData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfBrandDtoData-objects as value to a dart map
  static Map<String, List<ApiResponseOfBrandDtoData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfBrandDtoData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfBrandDtoData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

