//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetChatsResponse {
  /// Returns a new [GetChatsResponse] instance.
  GetChatsResponse({
    this.chats = const [],
  });

  List<ChatListDto> chats;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetChatsResponse &&
    _deepEquality.equals(other.chats, chats);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (chats.hashCode);

  @override
  String toString() => 'GetChatsResponse[chats=$chats]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'chats'] = this.chats;
    return json;
  }

  /// Returns a new [GetChatsResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetChatsResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetChatsResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetChatsResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetChatsResponse(
        chats: ChatListDto.listFromJson(json[r'chats']),
      );
    }
    return null;
  }

  static List<GetChatsResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetChatsResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetChatsResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetChatsResponse> mapFromJson(dynamic json) {
    final map = <String, GetChatsResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetChatsResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetChatsResponse-objects as value to a dart map
  static Map<String, List<GetChatsResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetChatsResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetChatsResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

