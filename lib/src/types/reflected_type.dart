import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

enum ReflectedTypeMode { unkown, primitive, enums, reflectedClass, dynamicType, classType, entityClass, maxiClass, list, map }

abstract interface class ReflectedType {
  static const String prefixType = '\$type';

  List get anotations;
  String get name;
  Type get dartType;
  ReflectedTypeMode get reflectionMode;
  bool get acceptsNull;
  bool get hasDefaultValue;

  bool checkThatTypeIsCompatible({required Type type});
  bool checkThatObjectIsCompatible({required dynamic value});

  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager});
  bool checkIfObjectCanBeConverted({required dynamic rawValue, ReflectionManager? manager});

  Result<dynamic> createNewInstance({ReflectionManager? manager});
  Result<dynamic> serialize({required dynamic value, ReflectionManager? manager});
  Result<dynamic> convertOrClone({required dynamic rawValue, ReflectionManager? manager});
}
