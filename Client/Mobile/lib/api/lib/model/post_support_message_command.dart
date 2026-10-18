//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PostSupportMessageCommand {
  /// Returns a new [PostSupportMessageCommand] instance.
  PostSupportMessageCommand({
    this.ticketId,
    this.message,
    this.mediaUrl,
    this.messageType,
    this.isSupportAgent,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ticketId;

  String? message;

  String? mediaUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  MessageType? messageType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isSupportAgent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PostSupportMessageCommand &&
    other.ticketId == ticketId &&
    other.message == message &&
    other.mediaUrl == mediaUrl &&
    other.messageType == messageType &&
    other.isSupportAgent == isSupportAgent;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (ticketId == null ? 0 : ticketId!.hashCode) +
    (message == null ? 0 : message!.hashCode) +
    (mediaUrl == null ? 0 : mediaUrl!.hashCode) +
    (messageType == null ? 0 : messageType!.hashCode) +
    (isSupportAgent == null ? 0 : isSupportAgent!.hashCode);

  @override
  String toString() => 'PostSupportMessageCommand[ticketId=$ticketId, message=$message, mediaUrl=$mediaUrl, messageType=$messageType, isSupportAgent=$isSupportAgent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.ticketId != null) {
      json[r'ticketId'] = this.ticketId;
    } else {
      json[r'ticketId'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    if (this.mediaUrl != null) {
      json[r'mediaUrl'] = this.mediaUrl;
    } else {
      json[r'mediaUrl'] = null;
    }
    if (this.messageType != null) {
      json[r'messageType'] = this.messageType;
    } else {
      json[r'messageType'] = null;
    }
    if (this.isSupportAgent != null) {
      json[r'isSupportAgent'] = this.isSupportAgent;
    } else {
      json[r'isSupportAgent'] = null;
    }
    return json;
  }

  /// Returns a new [PostSupportMessageCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PostSupportMessageCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PostSupportMessageCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PostSupportMessageCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PostSupportMessageCommand(
        ticketId: mapValueOfType<String>(json, r'ticketId'),
        message: mapValueOfType<String>(json, r'message'),
        mediaUrl: mapValueOfType<String>(json, r'mediaUrl'),
        messageType: MessageType.fromJson(json[r'messageType']),
        isSupportAgent: mapValueOfType<bool>(json, r'isSupportAgent'),
      );
    }
    return null;
  }

  static List<PostSupportMessageCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PostSupportMessageCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PostSupportMessageCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PostSupportMessageCommand> mapFromJson(dynamic json) {
    final map = <String, PostSupportMessageCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PostSupportMessageCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PostSupportMessageCommand-objects as value to a dart map
  static Map<String, List<PostSupportMessageCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PostSupportMessageCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PostSupportMessageCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

