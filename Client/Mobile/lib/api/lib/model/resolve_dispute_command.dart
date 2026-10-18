//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ResolveDisputeCommand {
  /// Returns a new [ResolveDisputeCommand] instance.
  ResolveDisputeCommand({
    this.rentalId,
    this.resolutionDecision,
    this.ownerCompensation,
    this.renterRefund,
    this.reason,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? rentalId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? resolutionDecision;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? ownerCompensation;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? renterRefund;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ResolveDisputeCommand &&
    other.rentalId == rentalId &&
    other.resolutionDecision == resolutionDecision &&
    other.ownerCompensation == ownerCompensation &&
    other.renterRefund == renterRefund &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (rentalId == null ? 0 : rentalId!.hashCode) +
    (resolutionDecision == null ? 0 : resolutionDecision!.hashCode) +
    (ownerCompensation == null ? 0 : ownerCompensation!.hashCode) +
    (renterRefund == null ? 0 : renterRefund!.hashCode) +
    (reason == null ? 0 : reason!.hashCode);

  @override
  String toString() => 'ResolveDisputeCommand[rentalId=$rentalId, resolutionDecision=$resolutionDecision, ownerCompensation=$ownerCompensation, renterRefund=$renterRefund, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.rentalId != null) {
      json[r'rentalId'] = this.rentalId;
    } else {
      json[r'rentalId'] = null;
    }
    if (this.resolutionDecision != null) {
      json[r'resolutionDecision'] = this.resolutionDecision;
    } else {
      json[r'resolutionDecision'] = null;
    }
    if (this.ownerCompensation != null) {
      json[r'ownerCompensation'] = this.ownerCompensation;
    } else {
      json[r'ownerCompensation'] = null;
    }
    if (this.renterRefund != null) {
      json[r'renterRefund'] = this.renterRefund;
    } else {
      json[r'renterRefund'] = null;
    }
    if (this.reason != null) {
      json[r'reason'] = this.reason;
    } else {
      json[r'reason'] = null;
    }
    return json;
  }

  /// Returns a new [ResolveDisputeCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ResolveDisputeCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ResolveDisputeCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ResolveDisputeCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ResolveDisputeCommand(
        rentalId: mapValueOfType<String>(json, r'rentalId'),
        resolutionDecision: mapValueOfType<String>(json, r'resolutionDecision'),
        ownerCompensation: num.parse('${json[r'ownerCompensation']}'),
        renterRefund: num.parse('${json[r'renterRefund']}'),
        reason: mapValueOfType<String>(json, r'reason'),
      );
    }
    return null;
  }

  static List<ResolveDisputeCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ResolveDisputeCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ResolveDisputeCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ResolveDisputeCommand> mapFromJson(dynamic json) {
    final map = <String, ResolveDisputeCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ResolveDisputeCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ResolveDisputeCommand-objects as value to a dart map
  static Map<String, List<ResolveDisputeCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ResolveDisputeCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ResolveDisputeCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

