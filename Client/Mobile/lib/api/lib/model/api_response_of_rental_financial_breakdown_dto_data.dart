//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfRentalFinancialBreakdownDtoData {
  /// Returns a new [ApiResponseOfRentalFinancialBreakdownDtoData] instance.
  ApiResponseOfRentalFinancialBreakdownDtoData({
    this.rentalId,
    this.initialRentalPrice,
    this.initialDeposit,
    this.initialExpertFee,
    this.escrowRental,
    this.escrowDeposit,
    this.escrowExpert,
    this.distributedToOwner,
    this.distributedToRenter,
    this.distributedToExpert,
    this.platformRevenue,
    this.penaltiesCollected,
    this.rentalStatus,
    this.cancellationReason,
    this.transactions = const [],
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
  num? initialRentalPrice;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? initialDeposit;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? initialExpertFee;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? escrowRental;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? escrowDeposit;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? escrowExpert;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? distributedToOwner;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? distributedToRenter;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? distributedToExpert;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? platformRevenue;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? penaltiesCollected;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? rentalStatus;

  String? cancellationReason;

  List<WalletTransactionDto> transactions;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfRentalFinancialBreakdownDtoData &&
    other.rentalId == rentalId &&
    other.initialRentalPrice == initialRentalPrice &&
    other.initialDeposit == initialDeposit &&
    other.initialExpertFee == initialExpertFee &&
    other.escrowRental == escrowRental &&
    other.escrowDeposit == escrowDeposit &&
    other.escrowExpert == escrowExpert &&
    other.distributedToOwner == distributedToOwner &&
    other.distributedToRenter == distributedToRenter &&
    other.distributedToExpert == distributedToExpert &&
    other.platformRevenue == platformRevenue &&
    other.penaltiesCollected == penaltiesCollected &&
    other.rentalStatus == rentalStatus &&
    other.cancellationReason == cancellationReason &&
    _deepEquality.equals(other.transactions, transactions);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (rentalId == null ? 0 : rentalId!.hashCode) +
    (initialRentalPrice == null ? 0 : initialRentalPrice!.hashCode) +
    (initialDeposit == null ? 0 : initialDeposit!.hashCode) +
    (initialExpertFee == null ? 0 : initialExpertFee!.hashCode) +
    (escrowRental == null ? 0 : escrowRental!.hashCode) +
    (escrowDeposit == null ? 0 : escrowDeposit!.hashCode) +
    (escrowExpert == null ? 0 : escrowExpert!.hashCode) +
    (distributedToOwner == null ? 0 : distributedToOwner!.hashCode) +
    (distributedToRenter == null ? 0 : distributedToRenter!.hashCode) +
    (distributedToExpert == null ? 0 : distributedToExpert!.hashCode) +
    (platformRevenue == null ? 0 : platformRevenue!.hashCode) +
    (penaltiesCollected == null ? 0 : penaltiesCollected!.hashCode) +
    (rentalStatus == null ? 0 : rentalStatus!.hashCode) +
    (cancellationReason == null ? 0 : cancellationReason!.hashCode) +
    (transactions.hashCode);

  @override
  String toString() => 'ApiResponseOfRentalFinancialBreakdownDtoData[rentalId=$rentalId, initialRentalPrice=$initialRentalPrice, initialDeposit=$initialDeposit, initialExpertFee=$initialExpertFee, escrowRental=$escrowRental, escrowDeposit=$escrowDeposit, escrowExpert=$escrowExpert, distributedToOwner=$distributedToOwner, distributedToRenter=$distributedToRenter, distributedToExpert=$distributedToExpert, platformRevenue=$platformRevenue, penaltiesCollected=$penaltiesCollected, rentalStatus=$rentalStatus, cancellationReason=$cancellationReason, transactions=$transactions]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.rentalId != null) {
      json[r'rentalId'] = this.rentalId;
    } else {
      json[r'rentalId'] = null;
    }
    if (this.initialRentalPrice != null) {
      json[r'initialRentalPrice'] = this.initialRentalPrice;
    } else {
      json[r'initialRentalPrice'] = null;
    }
    if (this.initialDeposit != null) {
      json[r'initialDeposit'] = this.initialDeposit;
    } else {
      json[r'initialDeposit'] = null;
    }
    if (this.initialExpertFee != null) {
      json[r'initialExpertFee'] = this.initialExpertFee;
    } else {
      json[r'initialExpertFee'] = null;
    }
    if (this.escrowRental != null) {
      json[r'escrowRental'] = this.escrowRental;
    } else {
      json[r'escrowRental'] = null;
    }
    if (this.escrowDeposit != null) {
      json[r'escrowDeposit'] = this.escrowDeposit;
    } else {
      json[r'escrowDeposit'] = null;
    }
    if (this.escrowExpert != null) {
      json[r'escrowExpert'] = this.escrowExpert;
    } else {
      json[r'escrowExpert'] = null;
    }
    if (this.distributedToOwner != null) {
      json[r'distributedToOwner'] = this.distributedToOwner;
    } else {
      json[r'distributedToOwner'] = null;
    }
    if (this.distributedToRenter != null) {
      json[r'distributedToRenter'] = this.distributedToRenter;
    } else {
      json[r'distributedToRenter'] = null;
    }
    if (this.distributedToExpert != null) {
      json[r'distributedToExpert'] = this.distributedToExpert;
    } else {
      json[r'distributedToExpert'] = null;
    }
    if (this.platformRevenue != null) {
      json[r'platformRevenue'] = this.platformRevenue;
    } else {
      json[r'platformRevenue'] = null;
    }
    if (this.penaltiesCollected != null) {
      json[r'penaltiesCollected'] = this.penaltiesCollected;
    } else {
      json[r'penaltiesCollected'] = null;
    }
    if (this.rentalStatus != null) {
      json[r'rentalStatus'] = this.rentalStatus;
    } else {
      json[r'rentalStatus'] = null;
    }
    if (this.cancellationReason != null) {
      json[r'cancellationReason'] = this.cancellationReason;
    } else {
      json[r'cancellationReason'] = null;
    }
      json[r'transactions'] = this.transactions;
    return json;
  }

  /// Returns a new [ApiResponseOfRentalFinancialBreakdownDtoData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfRentalFinancialBreakdownDtoData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfRentalFinancialBreakdownDtoData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfRentalFinancialBreakdownDtoData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfRentalFinancialBreakdownDtoData(
        rentalId: mapValueOfType<String>(json, r'rentalId'),
        initialRentalPrice: num.parse('${json[r'initialRentalPrice']}'),
        initialDeposit: num.parse('${json[r'initialDeposit']}'),
        initialExpertFee: num.parse('${json[r'initialExpertFee']}'),
        escrowRental: num.parse('${json[r'escrowRental']}'),
        escrowDeposit: num.parse('${json[r'escrowDeposit']}'),
        escrowExpert: num.parse('${json[r'escrowExpert']}'),
        distributedToOwner: num.parse('${json[r'distributedToOwner']}'),
        distributedToRenter: num.parse('${json[r'distributedToRenter']}'),
        distributedToExpert: num.parse('${json[r'distributedToExpert']}'),
        platformRevenue: num.parse('${json[r'platformRevenue']}'),
        penaltiesCollected: num.parse('${json[r'penaltiesCollected']}'),
        rentalStatus: mapValueOfType<String>(json, r'rentalStatus'),
        cancellationReason: mapValueOfType<String>(json, r'cancellationReason'),
        transactions: WalletTransactionDto.listFromJson(json[r'transactions']),
      );
    }
    return null;
  }

  static List<ApiResponseOfRentalFinancialBreakdownDtoData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfRentalFinancialBreakdownDtoData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfRentalFinancialBreakdownDtoData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfRentalFinancialBreakdownDtoData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfRentalFinancialBreakdownDtoData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfRentalFinancialBreakdownDtoData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfRentalFinancialBreakdownDtoData-objects as value to a dart map
  static Map<String, List<ApiResponseOfRentalFinancialBreakdownDtoData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfRentalFinancialBreakdownDtoData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfRentalFinancialBreakdownDtoData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

