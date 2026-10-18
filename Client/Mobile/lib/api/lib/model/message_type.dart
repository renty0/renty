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
class MessageType {
  /// Instantiate a new enum with the provided [value].
  const MessageType._(this.value);

  /// The underlying value of this enum member.
  final int value;

  @override
  String toString() => value.toString();

  int toJson() => value;

  static const number0 = MessageType._(0);
  static const number1 = MessageType._(1);
  static const number2 = MessageType._(2);
  static const number3 = MessageType._(3);
  static const number4 = MessageType._(4);

  /// List of all possible values in this [enum][MessageType].
  static const values = <MessageType>[
    number0,
    number1,
    number2,
    number3,
    number4,
  ];

  static MessageType? fromJson(dynamic value) => MessageTypeTypeTransformer().decode(value);

  static List<MessageType> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageType>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageType.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MessageType] to int,
/// and [decode] dynamic data back to [MessageType].
class MessageTypeTypeTransformer {
  factory MessageTypeTypeTransformer() => _instance ??= const MessageTypeTypeTransformer._();

  const MessageTypeTypeTransformer._();

  int encode(MessageType data) => data.value;

  /// Decodes a [dynamic value][data] to a MessageType.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MessageType? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case 0: return MessageType.number0;
        case 1: return MessageType.number1;
        case 2: return MessageType.number2;
        case 3: return MessageType.number3;
        case 4: return MessageType.number4;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MessageTypeTypeTransformer] instance.
  static MessageTypeTypeTransformer? _instance;
}

