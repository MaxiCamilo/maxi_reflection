import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedNullable implements ReflectedType {
  @override
  final Type dartType;
  @override
  final List anotations;
  final ReflectedType reflectedType;

  const ReflectedNullable({required this.dartType, required this.anotations, required this.reflectedType});

  @override
  bool get acceptsNull => true;

  @override
  Result createNewInstance() => ResultValue(content: null);

  @override
  bool get hasDefaultValue => true;
  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.dynamicType;

  @override
  String get name => '${reflectedType.name}?';

  @override
  bool isObjectCompatible({required value}) => value == null || reflectedType.isObjectCompatible(value: value);

  @override
  bool isTypeCompatible({required Type type}) => dartType == type || reflectedType.isTypeCompatible( type: type);

  @override
  bool thisObjectCanConvert({required rawValue}) => rawValue == null || reflectedType.thisObjectCanConvert( rawValue: rawValue);

  @override
  bool thisTypeCanConvert({required Type type}) => dartType == type || reflectedType.thisTypeCanConvert( type: type);

  @override
  Result convertOrClone({required rawValue}) {
    if (rawValue == null) {
      return ResultValue(content: null);
    } else {
      return reflectedType.convertOrClone(rawValue: rawValue);
    }
  }

  @override
  Result serialize({required value}) {
    if (value == null) {
      return ResultValue(content: null);
    } else {
      return reflectedType.serialize(value: value);
    }
  }
}
