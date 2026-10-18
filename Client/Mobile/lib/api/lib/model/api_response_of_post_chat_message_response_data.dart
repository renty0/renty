//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfPostChatMessageResponseData {
  /// Returns a new [ApiResponseOfPostChatMessageResponseData] instance.
  ApiResponseOfPostChatMessageResponseData({
    this.success,
    this.error,
    this.messageId,
    this.message,
    this.mediaUrl,
    this.messageType,
    this.createdAt,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? success;

  String? error;

  String? messageId;

  String? message;

  String? mediaUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  MessageType? messageType;

  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfPostChatMessageResponseData &&
    other.success == success &&
    other.error == error &&
    other.messageId == messageId &&
    other.message == message &&
    other.mediaUrl == mediaUrl &&
    other.messageType == messageType &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (success == null ? 0 : success!.hashCode) +
    (error == null ? 0 : error!.hashCode) +
    (messageId == null ? 0 : messageId!.hashCode) +
    (message == null ? 0 : message!.hashCode) +
    (mediaUrl == null ? 0 : mediaUrl!.hashCode) +
    (messageType == null ? 0 : messageType!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'ApiResponseOfPostChatMessageResponseData[success=$success, error=$error, messageId=$messageId, message=$message, mediaUrl=$mediaUrl, messageType=$messageType, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.success != null) {
      json[r'success'] = this.success;
    } else {
      json[r'success'] = null;
    }
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
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
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [ApiResponseOfPostChatMessageResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfPostChatMessageResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfPostChatMessageResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfPostChatMessageResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfPostChatMessageResponseData(
        success: mapValueOfType<bool>(json, r'success'),
        error: mapValueOfType<String>(json, r'error'),
        messageId: mapValueOfType<String>(json, r'messageId'),
        message: mapValueOfType<String>(json, r'message'),
        mediaUrl: mapValueOfType<String>(json, r'mediaUrl'),
        messageType: MessageType.fromJson(json[r'messageType']),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<ApiResponseOfPostChatMessageResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfPostChatMessageResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfPostChatMessageResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfPostChatMessageResponseData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfPostChatMessageResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfPostChatMessageResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfPostChatMessageResponseData-objects as value to a dart map
  static Map<String, List<ApiResponseOfPostChatMessageResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfPostChatMessageResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfPostChatMessageResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

