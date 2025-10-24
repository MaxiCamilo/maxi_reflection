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
  Result createNewInstance() => voidResult;

  @override
  Result convertOrClone({required rawValue}) => ResultValue(content: rawValue);

  @override
  bool isObjectCompatible({required value}) => true;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.dynamicType;

  @override
  bool isTypeCompatible({required Type type}) => true;

  @override
  Result serialize({required value}) => ResultValue(content: value);

  @override
  bool thisObjectCanConvert({required rawValue}) => true;

  @override
  bool thisTypeCanConvert({required Type type}) => true;
}
