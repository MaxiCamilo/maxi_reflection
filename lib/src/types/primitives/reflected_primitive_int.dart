import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedPrimitiveInt implements ReflectedType {
  @override
  final List anotations;

  const ReflectedPrimitiveInt({this.anotations = const []});

  @override
  String get name => 'Int';

  @override
  bool get acceptsNull => false;

  @override
  Result createNewInstance({ReflectionManager? manager}) => ResultValue(content: 0);

  @override
  bool get hasDefaultValue => true;

  @override
  Type get dartType => int;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.primitive;

  @override
  bool isObjectCompatible({required value}) => value is int;

  @override
  bool isTypeCompatible({required Type type}) => type == int;

  @override
  bool thisTypeCanConvert({required Type type, ReflectionManager? manager}) => const [int, double, num, String, bool, DateTime, Enum].contains(type);
  @override
  bool thisObjectCanConvert({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return false;
    }
    if (rawValue is Enum) {
      return true;
    }

    return thisTypeCanConvert(type: rawValue.runtimeType);
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value is int) {
      return ResultValue(content: value);
    } else {
      return convertOrClone(rawValue: value, ifEmptyIsZero: true,manager: manager);
    }
  }

  @override
  Result convertOrClone({required rawValue, bool ifEmptyIsZero = false, ReflectionManager? manager}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }
    if (rawValue is int) {
      return ResultValue(content: rawValue);
    } else if (rawValue is double) {
      return ResultValue(content: rawValue.toInt());
    } else if (rawValue is String) {
      if (ifEmptyIsZero && rawValue.isEmpty) {
        return ResultValue(content: 0);
      }

      final parse = int.tryParse(rawValue);
      return parse == null
          ? NegativeResult.controller(
              code: ErrorCode.invalidValue,
              message: FixedOration(message: 'The text value is not numerical'),
            )
          : ResultValue(content: parse);
    } else if (rawValue is DateTime) {
      return ResultValue(content: rawValue.isUtc ? rawValue.millisecondsSinceEpoch : rawValue.toUtc().millisecondsSinceEpoch);
    } else if (rawValue is bool) {
      return ResultValue(content: rawValue ? 1 : 0);
    } else if (rawValue is Enum) {
      return ResultValue(content: rawValue.index);
    } else {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'Cannot convert value of type %1 to an integer', textParts: [rawValue.runtimeType]),
      );
    }
  }
}
