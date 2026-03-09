//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// 
class UserType {
  /// Instantiate a new enum with the provided [value].
  const UserType._(this.value);

  /// The underlying value of this enum member.
  final int value;

  @override
  String toString() => value.toString();

  int toJson() => value;

  static const number1 = UserType._(1);
  static const number2 = UserType._(2);
  static const number3 = UserType._(3);

  /// List of all possible values in this [enum][UserType].
  static const values = <UserType>[
    number1,
    number2,
    number3,
  ];

  static UserType? fromJson(dynamic value) => UserTypeTypeTransformer().decode(value);

  static List<UserType> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserType>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserType.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [UserType] to int,
/// and [decode] dynamic data back to [UserType].
class UserTypeTypeTransformer {
  factory UserTypeTypeTransformer() => _instance ??= const UserTypeTypeTransformer._();

  const UserTypeTypeTransformer._();

  int encode(UserType data) => data.value;

  /// Decodes a [dynamic value][data] to a UserType.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  UserType? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case 1: return UserType.number1;
        case 2: return UserType.number2;
        case 3: return UserType.number3;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [UserTypeTypeTransformer] instance.
  static UserTypeTypeTransformer? _instance;
}

