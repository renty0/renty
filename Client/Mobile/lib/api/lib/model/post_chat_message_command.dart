//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PostChatMessageCommand {
  /// Returns a new [PostChatMessageCommand] instance.
  PostChatMessageCommand({
    this.chatId,
    this.message,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? chatId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? message;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PostChatMessageCommand &&
    other.chatId == chatId &&
    other.message == message;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (chatId == null ? 0 : chatId!.hashCode) +
    (message == null ? 0 : message!.hashCode);

  @override
  String toString() => 'PostChatMessageCommand[chatId=$chatId, message=$message]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.chatId != null) {
      json[r'chatId'] = this.chatId;
    } else {
      json[r'chatId'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    return json;
  }

  /// Returns a new [PostChatMessageCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PostChatMessageCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PostChatMessageCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PostChatMessageCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PostChatMessageCommand(
        chatId: mapValueOfType<String>(json, r'chatId'),
        message: mapValueOfType<String>(json, r'message'),
      );
    }
    return null;
  }

  static List<PostChatMessageCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PostChatMessageCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PostChatMessageCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PostChatMessageCommand> mapFromJson(dynamic json) {
    final map = <String, PostChatMessageCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PostChatMessageCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PostChatMessageCommand-objects as value to a dart map
  static Map<String, List<PostChatMessageCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PostChatMessageCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PostChatMessageCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

