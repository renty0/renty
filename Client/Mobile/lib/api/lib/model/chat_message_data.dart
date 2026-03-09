//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChatMessageData {
  /// Returns a new [ChatMessageData] instance.
  ChatMessageData({
    this.messageId,
    this.message,
    this.createdAt,
  });

  String? messageId;

  String? message;

  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChatMessageData &&
    other.messageId == messageId &&
    other.message == message &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (messageId == null ? 0 : messageId!.hashCode) +
    (message == null ? 0 : message!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'ChatMessageData[messageId=$messageId, message=$message, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.messageId != null) {
      json[r'messageId'] = this.messageId;
    } else {
      json[r'messageId'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [ChatMessageData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChatMessageData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ChatMessageData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ChatMessageData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ChatMessageData(
        messageId: mapValueOfType<String>(json, r'messageId'),
        message: mapValueOfType<String>(json, r'message'),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<ChatMessageData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChatMessageData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChatMessageData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChatMessageData> mapFromJson(dynamic json) {
    final map = <String, ChatMessageData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChatMessageData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChatMessageData-objects as value to a dart map
  static Map<String, List<ChatMessageData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChatMessageData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChatMessageData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

