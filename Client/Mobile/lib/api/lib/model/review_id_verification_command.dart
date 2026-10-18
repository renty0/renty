//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReviewIdVerificationCommand {
  /// Returns a new [ReviewIdVerificationCommand] instance.
  ReviewIdVerificationCommand({
    this.idVerificationId,
    this.status,
    this.rejectionReason,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? idVerificationId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  String? rejectionReason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReviewIdVerificationCommand &&
    other.idVerificationId == idVerificationId &&
    other.status == status &&
    other.rejectionReason == rejectionReason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (idVerificationId == null ? 0 : idVerificationId!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (rejectionReason == null ? 0 : rejectionReason!.hashCode);

  @override
  String toString() => 'ReviewIdVerificationCommand[idVerificationId=$idVerificationId, status=$status, rejectionReason=$rejectionReason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.idVerificationId != null) {
      json[r'idVerificationId'] = this.idVerificationId;
    } else {
      json[r'idVerificationId'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.rejectionReason != null) {
      json[r'rejectionReason'] = this.rejectionReason;
    } else {
      json[r'rejectionReason'] = null;
    }
    return json;
  }

  /// Returns a new [ReviewIdVerificationCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReviewIdVerificationCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReviewIdVerificationCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReviewIdVerificationCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReviewIdVerificationCommand(
        idVerificationId: mapValueOfType<String>(json, r'idVerificationId'),
        status: mapValueOfType<String>(json, r'status'),
        rejectionReason: mapValueOfType<String>(json, r'rejectionReason'),
      );
    }
    return null;
  }

  static List<ReviewIdVerificationCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReviewIdVerificationCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReviewIdVerificationCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReviewIdVerificationCommand> mapFromJson(dynamic json) {
    final map = <String, ReviewIdVerificationCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReviewIdVerificationCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReviewIdVerificationCommand-objects as value to a dart map
  static Map<String, List<ReviewIdVerificationCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReviewIdVerificationCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReviewIdVerificationCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

