//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationDto {
  /// Returns a new [NotificationDto] instance.
  NotificationDto({
    this.id,
    this.title,
    this.message,
    this.titleAr,
    this.messageAr,
    this.type,
    this.actionUrl,
    this.isRead,
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
  String? title;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? message;

  String? titleAr;

  String? messageAr;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  String? actionUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isRead;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationDto &&
    other.id == id &&
    other.title == title &&
    other.message == message &&
    other.titleAr == titleAr &&
    other.messageAr == messageAr &&
    other.type == type &&
    other.actionUrl == actionUrl &&
    other.isRead == isRead &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (title == null ? 0 : title!.hashCode) +
    (message == null ? 0 : message!.hashCode) +
    (titleAr == null ? 0 : titleAr!.hashCode) +
    (messageAr == null ? 0 : messageAr!.hashCode) +
    (type == null ? 0 : type!.hashCode) +
    (actionUrl == null ? 0 : actionUrl!.hashCode) +
    (isRead == null ? 0 : isRead!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'NotificationDto[id=$id, title=$title, message=$message, titleAr=$titleAr, messageAr=$messageAr, type=$type, actionUrl=$actionUrl, isRead=$isRead, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    if (this.titleAr != null) {
      json[r'titleAr'] = this.titleAr;
    } else {
      json[r'titleAr'] = null;
    }
    if (this.messageAr != null) {
      json[r'messageAr'] = this.messageAr;
    } else {
      json[r'messageAr'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.actionUrl != null) {
      json[r'actionUrl'] = this.actionUrl;
    } else {
      json[r'actionUrl'] = null;
    }
    if (this.isRead != null) {
      json[r'isRead'] = this.isRead;
    } else {
      json[r'isRead'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [NotificationDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "NotificationDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "NotificationDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return NotificationDto(
        id: mapValueOfType<String>(json, r'id'),
        title: mapValueOfType<String>(json, r'title'),
        message: mapValueOfType<String>(json, r'message'),
        titleAr: mapValueOfType<String>(json, r'titleAr'),
        messageAr: mapValueOfType<String>(json, r'messageAr'),
        type: mapValueOfType<String>(json, r'type'),
        actionUrl: mapValueOfType<String>(json, r'actionUrl'),
        isRead: mapValueOfType<bool>(json, r'isRead'),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<NotificationDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationDto> mapFromJson(dynamic json) {
    final map = <String, NotificationDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationDto-objects as value to a dart map
  static Map<String, List<NotificationDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

