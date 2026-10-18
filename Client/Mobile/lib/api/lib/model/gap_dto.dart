//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GapDto {
  /// Returns a new [GapDto] instance.
  GapDto({
    this.categoryName,
    this.demand,
    this.supply,
    this.gapScore,
    this.recommendations,
    this.createdAt,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? categoryName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? demand;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? supply;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? gapScore;

  String? recommendations;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GapDto &&
    other.categoryName == categoryName &&
    other.demand == demand &&
    other.supply == supply &&
    other.gapScore == gapScore &&
    other.recommendations == recommendations &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (categoryName == null ? 0 : categoryName!.hashCode) +
    (demand == null ? 0 : demand!.hashCode) +
    (supply == null ? 0 : supply!.hashCode) +
    (gapScore == null ? 0 : gapScore!.hashCode) +
    (recommendations == null ? 0 : recommendations!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'GapDto[categoryName=$categoryName, demand=$demand, supply=$supply, gapScore=$gapScore, recommendations=$recommendations, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.categoryName != null) {
      json[r'categoryName'] = this.categoryName;
    } else {
      json[r'categoryName'] = null;
    }
    if (this.demand != null) {
      json[r'demand'] = this.demand;
    } else {
      json[r'demand'] = null;
    }
    if (this.supply != null) {
      json[r'supply'] = this.supply;
    } else {
      json[r'supply'] = null;
    }
    if (this.gapScore != null) {
      json[r'gapScore'] = this.gapScore;
    } else {
      json[r'gapScore'] = null;
    }
    if (this.recommendations != null) {
      json[r'recommendations'] = this.recommendations;
    } else {
      json[r'recommendations'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [GapDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GapDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GapDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GapDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GapDto(
        categoryName: mapValueOfType<String>(json, r'categoryName'),
        demand: mapValueOfType<int>(json, r'demand'),
        supply: mapValueOfType<int>(json, r'supply'),
        gapScore: mapValueOfType<double>(json, r'gapScore'),
        recommendations: mapValueOfType<String>(json, r'recommendations'),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<GapDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GapDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GapDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GapDto> mapFromJson(dynamic json) {
    final map = <String, GapDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GapDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GapDto-objects as value to a dart map
  static Map<String, List<GapDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GapDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GapDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

