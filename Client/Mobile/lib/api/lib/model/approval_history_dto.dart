//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApprovalHistoryDto {
  /// Returns a new [ApprovalHistoryDto] instance.
  ApprovalHistoryDto({
    this.type,
    this.target,
    this.decision,
    this.processedBy,
    this.processedAt,
    this.reason,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? target;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? decision;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? processedBy;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? processedAt;

  String? reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApprovalHistoryDto &&
    other.type == type &&
    other.target == target &&
    other.decision == decision &&
    other.processedBy == processedBy &&
    other.processedAt == processedAt &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (type == null ? 0 : type!.hashCode) +
    (target == null ? 0 : target!.hashCode) +
    (decision == null ? 0 : decision!.hashCode) +
    (processedBy == null ? 0 : processedBy!.hashCode) +
    (processedAt == null ? 0 : processedAt!.hashCode) +
    (reason == null ? 0 : reason!.hashCode);

  @override
  String toString() => 'ApprovalHistoryDto[type=$type, target=$target, decision=$decision, processedBy=$processedBy, processedAt=$processedAt, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.target != null) {
      json[r'target'] = this.target;
    } else {
      json[r'target'] = null;
    }
    if (this.decision != null) {
      json[r'decision'] = this.decision;
    } else {
      json[r'decision'] = null;
    }
    if (this.processedBy != null) {
      json[r'processedBy'] = this.processedBy;
    } else {
      json[r'processedBy'] = null;
    }
    if (this.processedAt != null) {
      json[r'processedAt'] = this.processedAt!.toUtc().toIso8601String();
    } else {
      json[r'processedAt'] = null;
    }
    if (this.reason != null) {
      json[r'reason'] = this.reason;
    } else {
      json[r'reason'] = null;
    }
    return json;
  }

  /// Returns a new [ApprovalHistoryDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApprovalHistoryDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApprovalHistoryDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApprovalHistoryDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApprovalHistoryDto(
        type: mapValueOfType<String>(json, r'type'),
        target: mapValueOfType<String>(json, r'target'),
        decision: mapValueOfType<String>(json, r'decision'),
        processedBy: mapValueOfType<String>(json, r'processedBy'),
        processedAt: mapDateTime(json, r'processedAt', r''),
        reason: mapValueOfType<String>(json, r'reason'),
      );
    }
    return null;
  }

  static List<ApprovalHistoryDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApprovalHistoryDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApprovalHistoryDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApprovalHistoryDto> mapFromJson(dynamic json) {
    final map = <String, ApprovalHistoryDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApprovalHistoryDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApprovalHistoryDto-objects as value to a dart map
  static Map<String, List<ApprovalHistoryDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApprovalHistoryDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApprovalHistoryDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

