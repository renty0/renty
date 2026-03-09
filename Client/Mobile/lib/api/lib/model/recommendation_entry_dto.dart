//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RecommendationEntryDto {
  /// Returns a new [RecommendationEntryDto] instance.
  RecommendationEntryDto({
    this.id,
    this.item,
    this.score,
    this.reason,
    this.algorithm,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  RecommendationItemDto? item;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? score;

  String? reason;

  String? algorithm;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RecommendationEntryDto &&
    other.id == id &&
    other.item == item &&
    other.score == score &&
    other.reason == reason &&
    other.algorithm == algorithm;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (item == null ? 0 : item!.hashCode) +
    (score == null ? 0 : score!.hashCode) +
    (reason == null ? 0 : reason!.hashCode) +
    (algorithm == null ? 0 : algorithm!.hashCode);

  @override
  String toString() => 'RecommendationEntryDto[id=$id, item=$item, score=$score, reason=$reason, algorithm=$algorithm]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.item != null) {
      json[r'item'] = this.item;
    } else {
      json[r'item'] = null;
    }
    if (this.score != null) {
      json[r'score'] = this.score;
    } else {
      json[r'score'] = null;
    }
    if (this.reason != null) {
      json[r'reason'] = this.reason;
    } else {
      json[r'reason'] = null;
    }
    if (this.algorithm != null) {
      json[r'algorithm'] = this.algorithm;
    } else {
      json[r'algorithm'] = null;
    }
    return json;
  }

  /// Returns a new [RecommendationEntryDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RecommendationEntryDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RecommendationEntryDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RecommendationEntryDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RecommendationEntryDto(
        id: mapValueOfType<String>(json, r'id'),
        item: RecommendationItemDto.fromJson(json[r'item']),
        score: mapValueOfType<double>(json, r'score'),
        reason: mapValueOfType<String>(json, r'reason'),
        algorithm: mapValueOfType<String>(json, r'algorithm'),
      );
    }
    return null;
  }

  static List<RecommendationEntryDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RecommendationEntryDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RecommendationEntryDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RecommendationEntryDto> mapFromJson(dynamic json) {
    final map = <String, RecommendationEntryDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RecommendationEntryDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RecommendationEntryDto-objects as value to a dart map
  static Map<String, List<RecommendationEntryDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RecommendationEntryDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RecommendationEntryDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

