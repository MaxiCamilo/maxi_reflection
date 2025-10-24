import 'dart:convert';
import 'dart:typed_data';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedPrimitiveBinary implements ReflectedType {
  static final _empty = Uint8List.fromList(const []);

  @override
  final List anotations;

  const ReflectedPrimitiveBinary({this.anotations = const []});

  @override
  String get name => 'Uint8List';

  @override
  bool get acceptsNull => false;

  @override
  Result createNewInstance() => ResultValue(content: _empty);

  @override
  bool get hasDefaultValue => true;

  @override
  Type get dartType => Uint8List;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.primitive;

  @override
  bool isObjectCompatible({required value}) => value is Uint8List;

  @override
  bool isTypeCompatible({required Type type}) => type == Uint8List;

  @override
  bool thisTypeCanConvert({required Type type}) => const [Uint8List, String, List<int>].contains(type);

  @override
  bool thisObjectCanConvert({required rawValue}) => rawValue != null && thisTypeCanConvert(type: rawValue.runtimeType);

  @override
  Result serialize({required value}) {
    if (value is Uint8List) {
      return ResultValue(content: value);
    } else {
      return convertOrClone(rawValue: value);
    }
  }

  @override
  Result convertOrClone({required rawValue}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (rawValue is Uint8List) {
      return ResultValue(content: rawValue);
    }

    if (rawValue is List<int>) {
      return volatileFunction(
        error: (ex, st) => NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FixedOration(message: 'Failed to pass the list of numbers to a binary buffer'),
        ),
        function: () => Uint8List.fromList(rawValue),
      );
    }

    if (rawValue is String) {
      return volatileFunction(
        error: (ex, st) => NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FixedOration(message: 'The text does not have a valid Base64 format'),
        ),
        function: () => base64.decode(rawValue),
      );
    }

    return NegativeResult.controller(
      code: ErrorCode.wrongType,
      message: FlexibleOration(message: 'Cannot convert value of type %1 to a binary', textParts: [rawValue.runtimeType]),
    );
  }
}
