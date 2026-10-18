//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SupportTicketEventDto {
  /// Returns a new [SupportTicketEventDto] instance.
  SupportTicketEventDto({
    this.id,
    this.eventType,
    this.details,
    this.createdAt,
    this.actorName,
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
  String? eventType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? details;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  String? actorName;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SupportTicketEventDto &&
    other.id == id &&
    other.eventType == eventType &&
    other.details == details &&
    other.createdAt == createdAt &&
    other.actorName == actorName;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (eventType == null ? 0 : eventType!.hashCode) +
    (details == null ? 0 : details!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (actorName == null ? 0 : actorName!.hashCode);

  @override
  String toString() => 'SupportTicketEventDto[id=$id, eventType=$eventType, details=$details, createdAt=$createdAt, actorName=$actorName]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.eventType != null) {
      json[r'eventType'] = this.eventType;
    } else {
      json[r'eventType'] = null;
    }
    if (this.details != null) {
      json[r'details'] = this.details;
    } else {
      json[r'details'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    if (this.actorName != null) {
      json[r'actorName'] = this.actorName;
    } else {
      json[r'actorName'] = null;
    }
    return json;
  }

  /// Returns a new [SupportTicketEventDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SupportTicketEventDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SupportTicketEventDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SupportTicketEventDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SupportTicketEventDto(
        id: mapValueOfType<String>(json, r'id'),
        eventType: mapValueOfType<String>(json, r'eventType'),
        details: mapValueOfType<String>(json, r'details'),
        createdAt: mapDateTime(json, r'createdAt', r''),
        actorName: mapValueOfType<String>(json, r'actorName'),
      );
    }
    return null;
  }

  static List<SupportTicketEventDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SupportTicketEventDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SupportTicketEventDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SupportTicketEventDto> mapFromJson(dynamic json) {
    final map = <String, SupportTicketEventDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SupportTicketEventDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SupportTicketEventDto-objects as value to a dart map
  static Map<String, List<SupportTicketEventDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SupportTicketEventDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SupportTicketEventDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

