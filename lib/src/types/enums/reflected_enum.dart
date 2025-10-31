import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedEnum implements ReflectedType {
  final List<ReflectedEnumOption> options;

  @override
  final List anotations;

  @override
  final Type dartType;

  const ReflectedEnum({required this.anotations, required this.options, required this.dartType});

  @override
  bool get acceptsNull => false;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.enums;

  @override
  bool get hasDefaultValue => true;

  @override
  Result createNewInstance({ReflectionManager? manager}) => ResultValue(content: options.first.value);
  @override
  bool thisTypeCanConvert({required Type type, ReflectionManager? manager}) => type == dartType || const [Enum, int, String].contains(type);

  @override
  bool thisObjectCanConvert({required rawValue, ReflectionManager? manager}) => rawValue != null && (rawValue is Enum || isTypeCompatible(type: rawValue.runtimeType));

  @override
  bool isObjectCompatible({required value}) => value.runtimeType == dartType || options.any((x) => x.value == value);

  @override
  bool isTypeCompatible({required Type type}) => type == dartType || options.any((x) => x.value.runtimeType == type);

  @override
  String get name => dartType.toString();

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    final result = convertOrClone(rawValue: value);
    if (result.itsFailure) return result;
    return ResultValue(content: (result.content as Enum).index);
  }

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (rawValue is Enum) {
      for (final opt in options) {
        if (opt.value == rawValue) {
          return ResultValue(content: opt.value);
        }
      }

      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'The enumerated value is incorrect, expected type %1, but received a %2', textParts: [dartType, rawValue.runtimeType]),
      );
    }

    if (rawValue is num) {
      final index = rawValue.toInt();
      for (final opt in options) {
        if (opt.index == index) {
          return ResultValue(content: opt.value);
        }
      }

      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'Option number %1 does not exist', textParts: [index]),
      );
    }

    if (rawValue is String) {
      for (final opt in options) {
        if (opt.name == rawValue) {
          return ResultValue(content: opt.value);
        }
      }

      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The option called %1 does not exist', textParts: [rawValue]),
      );
    }

    return NegativeResult.controller(
      code: ErrorCode.wrongType,
      message: FlexibleOration(message: 'Cannot convert value of type %1 to an enum', textParts: [rawValue.runtimeType]),
    );
  }
}
