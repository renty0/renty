//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SupportTicketStatusData {
  /// Returns a new [SupportTicketStatusData] instance.
  SupportTicketStatusData({
    this.ticketId,
    this.status,
  });

  String? ticketId;

  String? status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SupportTicketStatusData &&
    other.ticketId == ticketId &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (ticketId == null ? 0 : ticketId!.hashCode) +
    (status == null ? 0 : status!.hashCode);

  @override
  String toString() => 'SupportTicketStatusData[ticketId=$ticketId, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.ticketId != null) {
      json[r'ticketId'] = this.ticketId;
    } else {
      json[r'ticketId'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    return json;
  }

  /// Returns a new [SupportTicketStatusData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SupportTicketStatusData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SupportTicketStatusData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SupportTicketStatusData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SupportTicketStatusData(
        ticketId: mapValueOfType<String>(json, r'ticketId'),
        status: mapValueOfType<String>(json, r'status'),
      );
    }
    return null;
  }

  static List<SupportTicketStatusData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SupportTicketStatusData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SupportTicketStatusData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SupportTicketStatusData> mapFromJson(dynamic json) {
    final map = <String, SupportTicketStatusData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SupportTicketStatusData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SupportTicketStatusData-objects as value to a dart map
  static Map<String, List<SupportTicketStatusData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SupportTicketStatusData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SupportTicketStatusData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

