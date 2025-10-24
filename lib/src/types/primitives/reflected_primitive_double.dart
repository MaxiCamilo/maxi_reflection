import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedPrimitiveDouble implements ReflectedType {
  @override
  final List anotations;

  const ReflectedPrimitiveDouble({this.anotations = const []});

  @override
  String get name => 'Double';

  @override
  bool get acceptsNull => false;

  @override
  Result createNewInstance() => ResultValue(content: 0.0);

  @override
  bool get hasDefaultValue => true;

  @override
  Type get dartType => double;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.primitive;

  @override
  bool isObjectCompatible({required value}) => value is double;

  @override
  bool isTypeCompatible({required Type type}) => type == double;

  @override
  bool thisTypeCanConvert({required Type type}) => const [double, int, num, String, bool, DateTime, Enum].contains(type);
  @override
  bool thisObjectCanConvert({required rawValue}) {
    if (rawValue == null) {
      return false;
    }
    if (rawValue is Enum) {
      return true;
    }

    return thisTypeCanConvert(type: rawValue.runtimeType);
  }

  @override
  Result serialize({required value}) {
    if (value is double) {
      return ResultValue(content: value);
    } else {
      return convertOrClone(rawValue: value, ifEmptyIsZero: true);
    }
  }

  @override
  Result convertOrClone({required rawValue, bool ifEmptyIsZero = false}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }
    if (rawValue is double) {
      return ResultValue(content: rawValue);
    } else if (rawValue is int) {
      return ResultValue(content: rawValue.toDouble());
    } else if (rawValue is String) {
      if (ifEmptyIsZero && rawValue.isEmpty) {
        return ResultValue(content: 0.0);
      }

      final parse = double.tryParse(rawValue);
      return parse == null
          ? NegativeResult.controller(
              code: ErrorCode.invalidValue,
              message: FixedOration(message: 'The text value is not numerical'),
            )
          : ResultValue(content: parse);
    } else if (rawValue is DateTime) {
      return ResultValue(content: rawValue.isUtc ? rawValue.millisecondsSinceEpoch.toDouble() : rawValue.toUtc().millisecondsSinceEpoch.toDouble());
    } else if (rawValue is bool) {
      return ResultValue(content: rawValue ? 1.0 : 0.0);
    } else if (rawValue is Enum) {
      return ResultValue(content: rawValue.index.toDouble());
    } else {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'Cannot convert value of type %1 to a decimal number', textParts: [rawValue.runtimeType]),
      );
    }
  }
}
