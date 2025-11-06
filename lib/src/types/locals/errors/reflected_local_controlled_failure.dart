import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class ReflectedLocalControlledFailure implements ReflectedType {
  static const String typeSerialization = 'Maxi.Error.Controlled';

  @override
  final List anotations;

  const ReflectedLocalControlledFailure({required this.anotations});

  @override
  bool get acceptsNull => false;

  @override
  Type get dartType => ControlledFailure;

  @override
  bool get hasDefaultValue => false;

  @override
  String get name => typeSerialization;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.maxiClass;

  @override
  bool checkThatTypeIsCompatible({required Type type}) => type == ControlledFailure;

  @override
  bool checkThatObjectIsCompatible({required value}) => value is ControlledFailure;

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => const [ControlledFailure, InvalidProperty, ErrorData, Map<String, dynamic>].contains(type);

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => rawValue != null && (rawValue is ErrorData || rawValue is Map<String, dynamic>);

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
        message: FixedOration(message: 'This value cannot be converted to a error message'),
      );
    }

    final rawErrorCodeResult = rawValue.getRequiredValue(key: 'message');
    final errorCodeResult = PrimitiveConverter.castEnum(options: ErrorCode.values, value: rawErrorCodeResult.content);
    if (errorCodeResult.itsFailure) return errorCodeResult.cast();

    final rawMessageResult = rawValue.getRequiredValue(key: 'message');
    if (rawMessageResult.itsFailure) return rawMessageResult.cast();

    final messageResult = ReflectedLocalOration(anotations: anotations).convertOrClone(rawValue: rawMessageResult.content);
    if (messageResult.itsFailure) return messageResult.cast();

    return ResultValue(
      content: ControlledFailure(errorCode: errorCodeResult.content, message: messageResult.content),
    );
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value is ErrorData) {
      return ResultValue(
        content: <String, dynamic>{
          ReflectedType.prefixType: typeSerialization,
          'errorCode': value.errorCode.index,
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
