import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedDynamic implements ReflectedType {
  @override
  final List anotations;

  const ReflectedDynamic({required this.anotations});

  @override
  bool get acceptsNull => true;

  @override
  Type get dartType => dynamic;

  @override
  bool get hasDefaultValue => true;

  @override
  String get name => 'Dynamic';

  @override
  Result createNewInstance({ReflectionManager? manager}) => voidResult;

  @override
  bool checkThatObjectIsCompatible({required value}) => true;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.dynamicType;

  @override
  bool checkThatTypeIsCompatible({required Type type}) => true;

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => true;

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => true;

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    final reflector = GetDynamicReflectorByType(dartType: value.runtimeType, reflectionManager: manager).execute();
    if (reflector.itsFailure) return reflector.cast();
    if (reflector.content.reflectionMode == ReflectedTypeMode.unkown) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'The reflector of type %1 was not found', textParts: [value.runtimeType]),
      );
    }

    return reflector.content.serialize(value: value);
  }

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    final reflector = GetDynamicReflectorByType(dartType: rawValue.runtimeType, reflectionManager: manager).execute();
    if (reflector.itsFailure) return reflector.cast();
    if (reflector.content.reflectionMode == ReflectedTypeMode.unkown) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'The reflector of type %1 was not found', textParts: [rawValue.runtimeType]),
      );
    }

    return reflector.content.convertOrClone(rawValue: rawValue, manager: manager);
  }
}
