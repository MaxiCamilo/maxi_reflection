import 'package:maxi_framework/maxi_framework.dart';

enum ReflectedTypeMode { unkown, primitive, enums, reflectedClass, dynamicType, maxiClass }

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

  bool thisTypeCanConvert({required Type type});
  bool thisObjectCanConvert({required dynamic rawValue});

  Result<dynamic> createNewInstance();
  Result<dynamic> serialize({required dynamic value});
  Result<dynamic> convertOrClone({required dynamic rawValue});
}
