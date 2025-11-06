import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class ReflectedLocalOration implements ReflectedType {
  static const String typeSerialization = 'Maxi.Text';

  @override
  final List anotations;

  const ReflectedLocalOration({required this.anotations});

  @override
  bool get acceptsNull => false;

  @override
  Type get dartType => Oration;

  @override
  bool get hasDefaultValue => true;

  @override
  String get name => typeSerialization;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.maxiClass;

  @override
  Result createNewInstance({ReflectionManager? manager}) => ResultValue(content: const FixedOration(message: ''));

  @override
  bool checkThatObjectIsCompatible({required value}) => value is Oration;

  @override
  bool checkThatTypeIsCompatible({required Type type}) => type == Oration || type == FlexibleOration || type == FixedOration;

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => const [FixedOration, FlexibleOration, Oration, Map<String, dynamic>].contains(type);

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => rawValue != null && (rawValue is Oration || checkIfThisTypeCanBeConverted(type: rawValue.runtimeType));

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value! is Oration) {
      final convertedValue = convertOrClone(rawValue: value);
      if (convertedValue.itsFailure) return convertedValue;

      value = convertedValue.content;
    }

    if (value is FixedOration) {
      return ReflectedLocalFixedOration(anotations: anotations).serialize(value: value);
    } else {
      return ReflectedLocalFlexibleOration(anotations: anotations).serialize(value: value);
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

    if (rawValue is Oration) {
      return ResultValue(content: rawValue is FixedOration ? FixedOration.clone(rawValue) : FlexibleOration.clone(rawValue));
    }

    if (rawValue is! Map<String, dynamic>) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FixedOration(message: 'This value cannot be converted to a translatable text'),
      );
    }

    if (rawValue.containsKey('textParts')) {
      return ReflectedLocalFlexibleOration(anotations: anotations).serialize(value: rawValue);
    } else {
      return ReflectedLocalFixedOration(anotations: anotations).serialize(value: rawValue);
    }
  }
}
