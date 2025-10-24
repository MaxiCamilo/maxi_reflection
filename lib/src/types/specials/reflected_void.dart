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
  bool thisObjectCanConvert({required rawValue}) => true;

  @override
  bool thisTypeCanConvert({required Type type}) => true;

  @override
  bool isObjectCompatible({required value}) => true;

  @override
  bool isTypeCompatible({required Type type}) => true;

  @override
  Result convertOrClone({required rawValue}) => voidResult;

  @override
  Result createNewInstance() => voidResult;

  @override
  Result serialize({required value}) => voidResult;
}
