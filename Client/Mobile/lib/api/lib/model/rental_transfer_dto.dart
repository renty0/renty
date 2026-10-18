//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RentalTransferDto {
  /// Returns a new [RentalTransferDto] instance.
  RentalTransferDto({
    this.id,
    this.phase,
    this.sequence,
    this.fromActorType,
    this.fromActorId,
    this.toActorType,
    this.toActorId,
    this.status,
    this.verificationCode,
    this.completedAt,
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
  String? phase;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? sequence;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? fromActorType;

  int? fromActorId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? toActorType;

  int? toActorId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  String? verificationCode;

  DateTime? completedAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RentalTransferDto &&
    other.id == id &&
    other.phase == phase &&
    other.sequence == sequence &&
    other.fromActorType == fromActorType &&
    other.fromActorId == fromActorId &&
    other.toActorType == toActorType &&
    other.toActorId == toActorId &&
    other.status == status &&
    other.verificationCode == verificationCode &&
    other.completedAt == completedAt &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (phase == null ? 0 : phase!.hashCode) +
    (sequence == null ? 0 : sequence!.hashCode) +
    (fromActorType == null ? 0 : fromActorType!.hashCode) +
    (fromActorId == null ? 0 : fromActorId!.hashCode) +
    (toActorType == null ? 0 : toActorType!.hashCode) +
    (toActorId == null ? 0 : toActorId!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (verificationCode == null ? 0 : verificationCode!.hashCode) +
    (completedAt == null ? 0 : completedAt!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'RentalTransferDto[id=$id, phase=$phase, sequence=$sequence, fromActorType=$fromActorType, fromActorId=$fromActorId, toActorType=$toActorType, toActorId=$toActorId, status=$status, verificationCode=$verificationCode, completedAt=$completedAt, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.phase != null) {
      json[r'phase'] = this.phase;
    } else {
      json[r'phase'] = null;
    }
    if (this.sequence != null) {
      json[r'sequence'] = this.sequence;
    } else {
      json[r'sequence'] = null;
    }
    if (this.fromActorType != null) {
      json[r'fromActorType'] = this.fromActorType;
    } else {
      json[r'fromActorType'] = null;
    }
    if (this.fromActorId != null) {
      json[r'fromActorId'] = this.fromActorId;
    } else {
      json[r'fromActorId'] = null;
    }
    if (this.toActorType != null) {
      json[r'toActorType'] = this.toActorType;
    } else {
      json[r'toActorType'] = null;
    }
    if (this.toActorId != null) {
      json[r'toActorId'] = this.toActorId;
    } else {
      json[r'toActorId'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.verificationCode != null) {
      json[r'verificationCode'] = this.verificationCode;
    } else {
      json[r'verificationCode'] = null;
    }
    if (this.completedAt != null) {
      json[r'completedAt'] = this.completedAt!.toUtc().toIso8601String();
    } else {
      json[r'completedAt'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [RentalTransferDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RentalTransferDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RentalTransferDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RentalTransferDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RentalTransferDto(
        id: mapValueOfType<String>(json, r'id'),
        phase: mapValueOfType<String>(json, r'phase'),
        sequence: mapValueOfType<int>(json, r'sequence'),
        fromActorType: mapValueOfType<String>(json, r'fromActorType'),
        fromActorId: mapValueOfType<int>(json, r'fromActorId'),
        toActorType: mapValueOfType<String>(json, r'toActorType'),
        toActorId: mapValueOfType<int>(json, r'toActorId'),
        status: mapValueOfType<String>(json, r'status'),
        verificationCode: mapValueOfType<String>(json, r'verificationCode'),
        completedAt: mapDateTime(json, r'completedAt', r''),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<RentalTransferDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RentalTransferDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RentalTransferDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RentalTransferDto> mapFromJson(dynamic json) {
    final map = <String, RentalTransferDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RentalTransferDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RentalTransferDto-objects as value to a dart map
  static Map<String, List<RentalTransferDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RentalTransferDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RentalTransferDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

