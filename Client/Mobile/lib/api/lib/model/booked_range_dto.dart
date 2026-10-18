//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BookedRangeDto {
  /// Returns a new [BookedRangeDto] instance.
  BookedRangeDto({
    this.start,
    this.end,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? start;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? end;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookedRangeDto &&
    other.start == start &&
    other.end == end;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (start == null ? 0 : start!.hashCode) +
    (end == null ? 0 : end!.hashCode);

  @override
  String toString() => 'BookedRangeDto[start=$start, end=$end]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.start != null) {
      json[r'start'] = this.start!.toUtc().toIso8601String();
    } else {
      json[r'start'] = null;
    }
    if (this.end != null) {
      json[r'end'] = this.end!.toUtc().toIso8601String();
    } else {
      json[r'end'] = null;
    }
    return json;
  }

  /// Returns a new [BookedRangeDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookedRangeDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BookedRangeDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BookedRangeDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BookedRangeDto(
        start: mapDateTime(json, r'start', r''),
        end: mapDateTime(json, r'end', r''),
      );
    }
    return null;
  }

  static List<BookedRangeDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookedRangeDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookedRangeDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookedRangeDto> mapFromJson(dynamic json) {
    final map = <String, BookedRangeDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookedRangeDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookedRangeDto-objects as value to a dart map
  static Map<String, List<BookedRangeDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookedRangeDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookedRangeDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

