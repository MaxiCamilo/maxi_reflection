import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class ReflectedLocalInvalidProperty implements ReflectedType {
  static const String typeSerialization = 'Maxi.Error.Property';

  @override
  final List anotations;

  const ReflectedLocalInvalidProperty({required this.anotations});

  @override
  bool get acceptsNull => false;

  @override
  Type get dartType => InvalidProperty;

  @override
  bool get hasDefaultValue => false;

  @override
  String get name => typeSerialization;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.maxiClass;

  @override
  bool isTypeCompatible({required Type type}) => type == InvalidProperty;

  @override
  bool isObjectCompatible({required value}) => value is InvalidProperty;

  @override
  bool thisTypeCanConvert({required Type type, ReflectionManager? manager}) => const [InvalidProperty, ControlledFailure, ErrorData, Map<String, dynamic>].contains(type);

  @override
  bool thisObjectCanConvert({required rawValue, ReflectionManager? manager}) => rawValue != null && (rawValue is ErrorData || rawValue is Map<String, dynamic>);

  @override
  Result createNewInstance({ReflectionManager? manager}) {
    return NegativeResult.controller(
      code: ErrorCode.implementationFailure,
      message: const FixedOration(message: 'Cannot create error instance without message'),
    );
  }

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (rawValue is ErrorData) {
      return ResultValue(
        content: ControlledFailure(errorCode: rawValue.errorCode, message: rawValue.message),
      );
    }
    if (rawValue is! Map<String, dynamic>) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FixedOration(message: 'This value cannot be converted to a invalid property message'),
      );
    }

    final rawMessageResult = rawValue.getRequiredValue(key: 'message');
    if (rawMessageResult.itsFailure) return rawMessageResult.cast();
    final messageResult = ReflectedLocalOration(anotations: anotations).convertOrClone(rawValue: rawMessageResult.content);
    if (messageResult.itsFailure) return messageResult.cast();

    final rawPropertyNameResult = rawValue.getRequiredValue(key: 'propertyName');
    if (rawPropertyNameResult.itsFailure) return rawPropertyNameResult.cast();
    final propertyNameResult = ReflectedLocalOration(anotations: anotations).convertOrClone(rawValue: rawPropertyNameResult.content);
    if (propertyNameResult.itsFailure) return propertyNameResult.cast();

    return ResultValue(
      content: InvalidProperty(message: messageResult.content, propertyName: propertyNameResult.content),
    );
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value is InvalidProperty) {
      return ResultValue(
        content: <String, dynamic>{
          ReflectedType.prefixType: typeSerialization,
          'propertyName': ReflectedLocalOration(anotations: anotations).serialize(value: value.propertyName),
          'message': ReflectedLocalOration(anotations: anotations).serialize(value: value.message),
        },
      );
    } else {
      final convert = convertOrClone(rawValue: value);
      if (convert.itsFailure) return convert.cast();

      return serialize(value: convert.content);
    }
  }
}
