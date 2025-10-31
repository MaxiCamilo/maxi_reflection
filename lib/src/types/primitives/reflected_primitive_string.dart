import 'dart:convert';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedPrimitiveString implements ReflectedType {
  @override
  final List anotations;

  const ReflectedPrimitiveString({this.anotations = const []});

  @override
  String get name => 'String';
  @override
  bool get acceptsNull => false;

  @override
  Result createNewInstance({ReflectionManager? manager}) => ResultValue(content: '');

  @override
  bool get hasDefaultValue => true;

  @override
  Type get dartType => String;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.primitive;

  @override
  bool isObjectCompatible({required value}) => value is String;

  @override
  bool isTypeCompatible({required Type type}) => type == String;

  @override
  bool thisTypeCanConvert({required Type type, ReflectionManager? manager}) => true;
  @override
  bool thisObjectCanConvert({required rawValue, ReflectionManager? manager}) => rawValue != null;

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value is String) {
      return ResultValue(content: value);
    } else {
      return convertOrClone(rawValue: value, manager: manager);
    }
  }

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (rawValue is DateTime) {
      return ResultValue(content: rawValue.toUtc().toIso8601String());
    }

    if (rawValue is List<int>) {
      return volatileFunction(
        error: (ex, st) => NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FixedOration(message: 'The binary value is not valid for text conversion using base64'),
        ),
        function: () => base64.encode(rawValue),
      );
    }

    return ResultValue(content: rawValue.toString());
  }
}
