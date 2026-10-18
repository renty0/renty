//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FraudLogDto {
  /// Returns a new [FraudLogDto] instance.
  FraudLogDto({
    this.id,
    this.user,
    this.riskScore,
    this.decision,
    this.reason,
    this.fraudIndicators,
    this.createdAt,
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
  FraudUserDto? user;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? riskScore;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? decision;

  String? reason;

  String? fraudIndicators;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FraudLogDto &&
    other.id == id &&
    other.user == user &&
    other.riskScore == riskScore &&
    other.decision == decision &&
    other.reason == reason &&
    other.fraudIndicators == fraudIndicators &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (user == null ? 0 : user!.hashCode) +
    (riskScore == null ? 0 : riskScore!.hashCode) +
    (decision == null ? 0 : decision!.hashCode) +
    (reason == null ? 0 : reason!.hashCode) +
    (fraudIndicators == null ? 0 : fraudIndicators!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'FraudLogDto[id=$id, user=$user, riskScore=$riskScore, decision=$decision, reason=$reason, fraudIndicators=$fraudIndicators, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.user != null) {
      json[r'user'] = this.user;
    } else {
      json[r'user'] = null;
    }
    if (this.riskScore != null) {
      json[r'riskScore'] = this.riskScore;
    } else {
      json[r'riskScore'] = null;
    }
    if (this.decision != null) {
      json[r'decision'] = this.decision;
    } else {
      json[r'decision'] = null;
    }
    if (this.reason != null) {
      json[r'reason'] = this.reason;
    } else {
      json[r'reason'] = null;
    }
    if (this.fraudIndicators != null) {
      json[r'fraudIndicators'] = this.fraudIndicators;
    } else {
      json[r'fraudIndicators'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [FraudLogDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FraudLogDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FraudLogDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FraudLogDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FraudLogDto(
        id: mapValueOfType<String>(json, r'id'),
        user: FraudUserDto.fromJson(json[r'user']),
        riskScore: mapValueOfType<double>(json, r'riskScore'),
        decision: mapValueOfType<String>(json, r'decision'),
        reason: mapValueOfType<String>(json, r'reason'),
        fraudIndicators: mapValueOfType<String>(json, r'fraudIndicators'),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<FraudLogDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FraudLogDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FraudLogDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FraudLogDto> mapFromJson(dynamic json) {
    final map = <String, FraudLogDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FraudLogDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FraudLogDto-objects as value to a dart map
  static Map<String, List<FraudLogDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FraudLogDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FraudLogDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

