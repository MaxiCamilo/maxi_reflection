import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedPrimitiveBool implements ReflectedType {
  @override
  final List anotations;

  const ReflectedPrimitiveBool({this.anotations = const []});

  @override
  String get name => 'Bool';

  @override
  bool get acceptsNull => false;

  @override
  Result createNewInstance({ReflectionManager? manager}) => ResultValue(content: false);

  @override
  bool get hasDefaultValue => true;

  @override
  Type get dartType => bool;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.primitive;

  @override
  bool isObjectCompatible({required value}) => value is bool;

  @override
  bool isTypeCompatible({required Type type}) => type == bool;

  @override
  bool thisTypeCanConvert({required Type type, ReflectionManager? manager}) => const [bool, String, int, double, num].contains(type);

  @override
  bool thisObjectCanConvert({required rawValue, ReflectionManager? manager}) => rawValue != null && thisTypeCanConvert(type: rawValue.runtimeType);

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (rawValue is bool) {
      return ResultValue(content: rawValue);
    }

    if (rawValue is num) {
      if (rawValue > 1) {
        return NegativeResult.controller(
          code: ErrorCode.nullValue,
          message: FixedOration(message: 'The numeric value cannot be converted to boolean (it must be 0 or 1)'),
        );
      }
      return ResultValue(content: rawValue == 1);
    }

    if (rawValue is String) {
      final textValue = rawValue.toLowerCase();
      return switch (textValue) {
        'true' => const ResultValue(content: true),
        'false' => const ResultValue(content: false),
        'yes' => const ResultValue(content: true),
        'no' => const ResultValue(content: false),
        'si' => const ResultValue(content: true),
        't' => const ResultValue(content: true),
        'f' => const ResultValue(content: false),
        's' => const ResultValue(content: true),
        'y' => const ResultValue(content: true),
        'n' => const ResultValue(content: false),
        '0' => const ResultValue(content: false),
        '1' => const ResultValue(content: true),
        _ => NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FixedOration(message: 'The textual value cannot be converted to boolean'),
        ),
      };
    }

    return NegativeResult.controller(
      code: ErrorCode.wrongType,
      message: FlexibleOration(message: 'Cannot convert value of type %1 to a boolean', textParts: [rawValue.runtimeType]),
    );
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    // TODO: implement serialize
    throw UnimplementedError();
  }
}
