import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

enum ReflectedTypeMode { unkown, primitive, enums, reflectedClass, dynamicType, maxiClass, list, map }

abstract interface class ReflectedType {
  static const String prefixType = '\$type';

  List get anotations;
  String get name;
  Type get dartType;
  ReflectedTypeMode get reflectionMode;
  bool get acceptsNull;
  bool get hasDefaultValue;

  bool isTypeCompatible({required Type type});
  bool isObjectCompatible({required dynamic value});

  bool thisTypeCanConvert({required Type type, ReflectionManager? manager});
  bool thisObjectCanConvert({required dynamic rawValue, ReflectionManager? manager});

  Result<dynamic> createNewInstance({ReflectionManager? manager});
  Result<dynamic> serialize({required dynamic value, ReflectionManager? manager});
  Result<dynamic> convertOrClone({required dynamic rawValue, ReflectionManager? manager});
}
