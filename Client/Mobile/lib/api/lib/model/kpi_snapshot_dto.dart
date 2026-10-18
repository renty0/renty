//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class KpiSnapshotDto {
  /// Returns a new [KpiSnapshotDto] instance.
  KpiSnapshotDto({
    this.id,
    this.date,
    this.period,
    this.activeUsers,
    this.newUsers,
    this.rentals,
    this.revenue,
    this.fraudRate,
    this.recommendationCtr,
    this.totalItems,
    this.totalOrders,
    this.createdAt,
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
  DateTime? date;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? period;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? activeUsers;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? newUsers;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? rentals;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? revenue;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? fraudRate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? recommendationCtr;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? totalItems;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? totalOrders;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is KpiSnapshotDto &&
    other.id == id &&
    other.date == date &&
    other.period == period &&
    other.activeUsers == activeUsers &&
    other.newUsers == newUsers &&
    other.rentals == rentals &&
    other.revenue == revenue &&
    other.fraudRate == fraudRate &&
    other.recommendationCtr == recommendationCtr &&
    other.totalItems == totalItems &&
    other.totalOrders == totalOrders &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (date == null ? 0 : date!.hashCode) +
    (period == null ? 0 : period!.hashCode) +
    (activeUsers == null ? 0 : activeUsers!.hashCode) +
    (newUsers == null ? 0 : newUsers!.hashCode) +
    (rentals == null ? 0 : rentals!.hashCode) +
    (revenue == null ? 0 : revenue!.hashCode) +
    (fraudRate == null ? 0 : fraudRate!.hashCode) +
    (recommendationCtr == null ? 0 : recommendationCtr!.hashCode) +
    (totalItems == null ? 0 : totalItems!.hashCode) +
    (totalOrders == null ? 0 : totalOrders!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'KpiSnapshotDto[id=$id, date=$date, period=$period, activeUsers=$activeUsers, newUsers=$newUsers, rentals=$rentals, revenue=$revenue, fraudRate=$fraudRate, recommendationCtr=$recommendationCtr, totalItems=$totalItems, totalOrders=$totalOrders, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.date != null) {
      json[r'date'] = this.date!.toUtc().toIso8601String();
    } else {
      json[r'date'] = null;
    }
    if (this.period != null) {
      json[r'period'] = this.period;
    } else {
      json[r'period'] = null;
    }
    if (this.activeUsers != null) {
      json[r'activeUsers'] = this.activeUsers;
    } else {
      json[r'activeUsers'] = null;
    }
    if (this.newUsers != null) {
      json[r'newUsers'] = this.newUsers;
    } else {
      json[r'newUsers'] = null;
    }
    if (this.rentals != null) {
      json[r'rentals'] = this.rentals;
    } else {
      json[r'rentals'] = null;
    }
    if (this.revenue != null) {
      json[r'revenue'] = this.revenue;
    } else {
      json[r'revenue'] = null;
    }
    if (this.fraudRate != null) {
      json[r'fraudRate'] = this.fraudRate;
    } else {
      json[r'fraudRate'] = null;
    }
    if (this.recommendationCtr != null) {
      json[r'recommendationCtr'] = this.recommendationCtr;
    } else {
      json[r'recommendationCtr'] = null;
    }
    if (this.totalItems != null) {
      json[r'totalItems'] = this.totalItems;
    } else {
      json[r'totalItems'] = null;
    }
    if (this.totalOrders != null) {
      json[r'totalOrders'] = this.totalOrders;
    } else {
      json[r'totalOrders'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [KpiSnapshotDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static KpiSnapshotDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "KpiSnapshotDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "KpiSnapshotDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return KpiSnapshotDto(
        id: mapValueOfType<String>(json, r'id'),
        date: mapDateTime(json, r'date', r''),
        period: mapValueOfType<String>(json, r'period'),
        activeUsers: mapValueOfType<int>(json, r'activeUsers'),
        newUsers: mapValueOfType<int>(json, r'newUsers'),
        rentals: mapValueOfType<int>(json, r'rentals'),
        revenue: num.parse('${json[r'revenue']}'),
        fraudRate: mapValueOfType<double>(json, r'fraudRate'),
        recommendationCtr: mapValueOfType<double>(json, r'recommendationCtr'),
        totalItems: mapValueOfType<int>(json, r'totalItems'),
        totalOrders: mapValueOfType<int>(json, r'totalOrders'),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<KpiSnapshotDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KpiSnapshotDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KpiSnapshotDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, KpiSnapshotDto> mapFromJson(dynamic json) {
    final map = <String, KpiSnapshotDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = KpiSnapshotDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of KpiSnapshotDto-objects as value to a dart map
  static Map<String, List<KpiSnapshotDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<KpiSnapshotDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = KpiSnapshotDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

