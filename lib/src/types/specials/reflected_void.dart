import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedVoid implements ReflectedType {
  @override
  final List anotations;

  const ReflectedVoid({required this.anotations});

  @override
  bool get acceptsNull => true;

  @override
  Type get dartType => dynamic;

  @override
  bool get hasDefaultValue => true;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.dynamicType;

  @override
  String get name => 'void';

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => true;

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => true;

  @override
  bool checkThatObjectIsCompatible({required value}) => true;

  @override
  bool checkThatTypeIsCompatible({required Type type}) => true;

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) => voidResult;

  @override
  Result createNewInstance({ReflectionManager? manager}) => voidResult;

  @override
  Result serialize({required value, ReflectionManager? manager}) => voidResult;
}
