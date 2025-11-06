import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectedClass implements ReflectedType {
  bool get isConstClass;
  bool get isInterface;
  String get packagePrefix;

  String get typeSignature;

  Type? get extendsType;
  List<Type> get traits;

  List<ReflectedMethod> get methods;
  List<ReflectedField> get fields;

  Result<dynamic> invokeContructor({String name = '', InvocationParameters parameters = InvocationParameters.emptry});
  Result<dynamic> invoke({required dynamic instance, required String name, required InvocationParameters parameters, bool tryAccommodateParameters = false});

  Result<dynamic> obtainValue({required String name, required dynamic instance});
  Result<void> changeValue({required String name, required dynamic instance, required dynamic value});

  Result<ReflectedEntity> buildEntityReflector({required ReflectionManager manager});
}
