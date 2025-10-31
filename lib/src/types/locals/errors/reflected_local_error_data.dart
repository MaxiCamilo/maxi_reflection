import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/src/types/locals/errors/reflected_local_controlled_failure.dart';
import 'package:maxi_reflection/src/types/locals/errors/reflected_local_invalid_property.dart';

class ReflectedLocalErrorData implements ReflectedType {
  static const String typeSerialization = 'Maxi.Error';

  @override
  final List anotations;

  const ReflectedLocalErrorData({required this.anotations});

  @override
  bool get acceptsNull => false;

  @override
  Type get dartType => ErrorData;

  @override
  bool get hasDefaultValue => false;

  @override
  String get name => typeSerialization;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.maxiClass;

  @override
  bool isTypeCompatible({required Type type}) => type == ErrorData;

  @override
  bool isObjectCompatible({required value}) => value is ErrorData;

  @override
  bool thisObjectCanConvert({required rawValue, ReflectionManager? manager}) => rawValue != null && thisTypeCanConvert(type: rawValue.runtimeType);

  @override
  bool thisTypeCanConvert({required Type type, ReflectionManager? manager}) => const [ErrorData, ControlledFailure, InvalidProperty].contains(type);

  bool isErrorTypeName(String typeName) => const [typeSerialization, ReflectedLocalControlledFailure.typeSerialization, ReflectedLocalInvalidProperty.typeSerialization].contains(typeName);

  @override
  Result createNewInstance({ReflectionManager? manager}) {
    return NegativeResult.controller(
      code: ErrorCode.implementationFailure,
      message: const FixedOration(message: 'Cannot create error instance without message'),
    );
  }

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    // TODO: implement convertOrClone
    throw UnimplementedError();
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    // TODO: implement serialize
    throw UnimplementedError();
  }
}
