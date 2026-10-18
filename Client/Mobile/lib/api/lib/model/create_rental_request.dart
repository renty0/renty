//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateRentalRequest {
  /// Returns a new [CreateRentalRequest] instance.
  CreateRentalRequest({
    this.itemId,
    this.startDate,
    this.endDate,
    this.pricingType,
    this.notes,
    this.requestExpertReview,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? itemId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? startDate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? endDate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? pricingType;

  String? notes;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? requestExpertReview;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateRentalRequest &&
    other.itemId == itemId &&
    other.startDate == startDate &&
    other.endDate == endDate &&
    other.pricingType == pricingType &&
    other.notes == notes &&
    other.requestExpertReview == requestExpertReview;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (itemId == null ? 0 : itemId!.hashCode) +
    (startDate == null ? 0 : startDate!.hashCode) +
    (endDate == null ? 0 : endDate!.hashCode) +
    (pricingType == null ? 0 : pricingType!.hashCode) +
    (notes == null ? 0 : notes!.hashCode) +
    (requestExpertReview == null ? 0 : requestExpertReview!.hashCode);

  @override
  String toString() => 'CreateRentalRequest[itemId=$itemId, startDate=$startDate, endDate=$endDate, pricingType=$pricingType, notes=$notes, requestExpertReview=$requestExpertReview]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.itemId != null) {
      json[r'itemId'] = this.itemId;
    } else {
      json[r'itemId'] = null;
    }
    if (this.startDate != null) {
      json[r'startDate'] = this.startDate!.toUtc().toIso8601String();
    } else {
      json[r'startDate'] = null;
    }
    if (this.endDate != null) {
      json[r'endDate'] = this.endDate!.toUtc().toIso8601String();
    } else {
      json[r'endDate'] = null;
    }
    if (this.pricingType != null) {
      json[r'pricingType'] = this.pricingType;
    } else {
      json[r'pricingType'] = null;
    }
    if (this.notes != null) {
      json[r'notes'] = this.notes;
    } else {
      json[r'notes'] = null;
    }
    if (this.requestExpertReview != null) {
      json[r'requestExpertReview'] = this.requestExpertReview;
    } else {
      json[r'requestExpertReview'] = null;
    }
    return json;
  }

  /// Returns a new [CreateRentalRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateRentalRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateRentalRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateRentalRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateRentalRequest(
        itemId: mapValueOfType<String>(json, r'itemId'),
        startDate: mapDateTime(json, r'startDate', r''),
        endDate: mapDateTime(json, r'endDate', r''),
        pricingType: mapValueOfType<String>(json, r'pricingType'),
        notes: mapValueOfType<String>(json, r'notes'),
        requestExpertReview: mapValueOfType<bool>(json, r'requestExpertReview'),
      );
    }
    return null;
  }

  static List<CreateRentalRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateRentalRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateRentalRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateRentalRequest> mapFromJson(dynamic json) {
    final map = <String, CreateRentalRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateRentalRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateRentalRequest-objects as value to a dart map
  static Map<String, List<CreateRentalRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateRentalRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateRentalRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

