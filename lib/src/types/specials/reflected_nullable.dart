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
  Result createNewInstance({ReflectionManager? manager}) => ResultValue(content: null);

  @override
  bool get hasDefaultValue => true;
  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.dynamicType;

  @override
  String get name => '${reflectedType.name}?';

  @override
  bool checkThatObjectIsCompatible({required value}) => value == null || reflectedType.checkThatObjectIsCompatible(value: value);

  @override
  bool checkThatTypeIsCompatible({required Type type}) => dartType == type || reflectedType.checkThatTypeIsCompatible(type: type);

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => rawValue == null || reflectedType.checkIfObjectCanBeConverted(rawValue: rawValue, manager: manager);

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => dartType == type || reflectedType.checkIfThisTypeCanBeConverted(type: type, manager: manager);

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return ResultValue(content: null);
    } else {
      return reflectedType.convertOrClone(rawValue: rawValue, manager: manager);
    }
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value == null) {
      return ResultValue(content: null);
    } else {
      return reflectedType.serialize(value: value, manager: manager);
    }
  }
}
