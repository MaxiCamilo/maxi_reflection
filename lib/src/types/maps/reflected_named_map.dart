import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedNamedMap implements ReflectedType {
  @override
  final List anotations;

  const ReflectedNamedMap({this.anotations = const []});

  @override
  bool get acceptsNull => false;

  @override
  Type get dartType => Map<String, dynamic>;

  @override
  bool get hasDefaultValue => true;

  @override
  String get name => 'Map<String,dynamic>';

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.map;

  @override
  bool checkThatObjectIsCompatible({required value}) => value is Map<String, dynamic>;

  @override
  bool checkThatTypeIsCompatible({required Type type}) => type == Map<String, dynamic>;

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => false;

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => false;

  @override
  Result createNewInstance({ReflectionManager? manager}) => ResultValue(content: <String, dynamic>{});

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (value is! Map<String, dynamic>) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FixedOration(message: 'Only named maps are accepted'),
      );
    }

    return ResultValue(content: Map<String, dynamic>.from(value));
  }

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (rawValue is! Map<String, dynamic>) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FixedOration(message: 'Only named maps are accepted'),
      );
    }

    return ResultValue(content: Map<String, dynamic>.from(rawValue));
  }
}
