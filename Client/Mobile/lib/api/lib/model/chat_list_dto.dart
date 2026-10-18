//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChatListDto {
  /// Returns a new [ChatListDto] instance.
  ChatListDto({
    this.id,
    this.otherUserFirstName,
    this.otherUserLastName,
    this.otherUserProfileImage,
    this.lastMessage,
    this.lastMessageType,
    this.unreadCount,
    this.lastMessageAt,
    this.itemId,
    this.itemTitle,
    this.itemImage,
    this.otherUserLastLoginAt,
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
  String? otherUserFirstName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? otherUserLastName;

  String? otherUserProfileImage;

  String? lastMessage;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  MessageType? lastMessageType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? unreadCount;

  DateTime? lastMessageAt;

  String? itemId;

  String? itemTitle;

  String? itemImage;

  DateTime? otherUserLastLoginAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChatListDto &&
    other.id == id &&
    other.otherUserFirstName == otherUserFirstName &&
    other.otherUserLastName == otherUserLastName &&
    other.otherUserProfileImage == otherUserProfileImage &&
    other.lastMessage == lastMessage &&
    other.lastMessageType == lastMessageType &&
    other.unreadCount == unreadCount &&
    other.lastMessageAt == lastMessageAt &&
    other.itemId == itemId &&
    other.itemTitle == itemTitle &&
    other.itemImage == itemImage &&
    other.otherUserLastLoginAt == otherUserLastLoginAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (otherUserFirstName == null ? 0 : otherUserFirstName!.hashCode) +
    (otherUserLastName == null ? 0 : otherUserLastName!.hashCode) +
    (otherUserProfileImage == null ? 0 : otherUserProfileImage!.hashCode) +
    (lastMessage == null ? 0 : lastMessage!.hashCode) +
    (lastMessageType == null ? 0 : lastMessageType!.hashCode) +
    (unreadCount == null ? 0 : unreadCount!.hashCode) +
    (lastMessageAt == null ? 0 : lastMessageAt!.hashCode) +
    (itemId == null ? 0 : itemId!.hashCode) +
    (itemTitle == null ? 0 : itemTitle!.hashCode) +
    (itemImage == null ? 0 : itemImage!.hashCode) +
    (otherUserLastLoginAt == null ? 0 : otherUserLastLoginAt!.hashCode);

  @override
  String toString() => 'ChatListDto[id=$id, otherUserFirstName=$otherUserFirstName, otherUserLastName=$otherUserLastName, otherUserProfileImage=$otherUserProfileImage, lastMessage=$lastMessage, lastMessageType=$lastMessageType, unreadCount=$unreadCount, lastMessageAt=$lastMessageAt, itemId=$itemId, itemTitle=$itemTitle, itemImage=$itemImage, otherUserLastLoginAt=$otherUserLastLoginAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.otherUserFirstName != null) {
      json[r'otherUserFirstName'] = this.otherUserFirstName;
    } else {
      json[r'otherUserFirstName'] = null;
    }
    if (this.otherUserLastName != null) {
      json[r'otherUserLastName'] = this.otherUserLastName;
    } else {
      json[r'otherUserLastName'] = null;
    }
    if (this.otherUserProfileImage != null) {
      json[r'otherUserProfileImage'] = this.otherUserProfileImage;
    } else {
      json[r'otherUserProfileImage'] = null;
    }
    if (this.lastMessage != null) {
      json[r'lastMessage'] = this.lastMessage;
    } else {
      json[r'lastMessage'] = null;
    }
    if (this.lastMessageType != null) {
      json[r'lastMessageType'] = this.lastMessageType;
    } else {
      json[r'lastMessageType'] = null;
    }
    if (this.unreadCount != null) {
      json[r'unreadCount'] = this.unreadCount;
    } else {
      json[r'unreadCount'] = null;
    }
    if (this.lastMessageAt != null) {
      json[r'lastMessageAt'] = this.lastMessageAt!.toUtc().toIso8601String();
    } else {
      json[r'lastMessageAt'] = null;
    }
    if (this.itemId != null) {
      json[r'itemId'] = this.itemId;
    } else {
      json[r'itemId'] = null;
    }
    if (this.itemTitle != null) {
      json[r'itemTitle'] = this.itemTitle;
    } else {
      json[r'itemTitle'] = null;
    }
    if (this.itemImage != null) {
      json[r'itemImage'] = this.itemImage;
    } else {
      json[r'itemImage'] = null;
    }
    if (this.otherUserLastLoginAt != null) {
      json[r'otherUserLastLoginAt'] = this.otherUserLastLoginAt!.toUtc().toIso8601String();
    } else {
      json[r'otherUserLastLoginAt'] = null;
    }
    return json;
  }

  /// Returns a new [ChatListDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChatListDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ChatListDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ChatListDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ChatListDto(
        id: mapValueOfType<String>(json, r'id'),
        otherUserFirstName: mapValueOfType<String>(json, r'otherUserFirstName'),
        otherUserLastName: mapValueOfType<String>(json, r'otherUserLastName'),
        otherUserProfileImage: mapValueOfType<String>(json, r'otherUserProfileImage'),
        lastMessage: mapValueOfType<String>(json, r'lastMessage'),
        lastMessageType: MessageType.fromJson(json[r'lastMessageType']),
        unreadCount: mapValueOfType<int>(json, r'unreadCount'),
        lastMessageAt: mapDateTime(json, r'lastMessageAt', r''),
        itemId: mapValueOfType<String>(json, r'itemId'),
        itemTitle: mapValueOfType<String>(json, r'itemTitle'),
        itemImage: mapValueOfType<String>(json, r'itemImage'),
        otherUserLastLoginAt: mapDateTime(json, r'otherUserLastLoginAt', r''),
      );
    }
    return null;
  }

  static List<ChatListDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChatListDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChatListDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChatListDto> mapFromJson(dynamic json) {
    final map = <String, ChatListDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChatListDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChatListDto-objects as value to a dart map
  static Map<String, List<ChatListDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChatListDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChatListDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

