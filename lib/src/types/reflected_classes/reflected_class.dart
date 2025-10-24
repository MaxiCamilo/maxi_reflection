import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectedClass implements ReflectedType {
  bool get isConstClass;
  bool get isInterface;

  List<ReflectedMethod> get methods;
  List<ReflectedField> get fields;

  Result<dynamic> invokeContructor({required String name, required InvocationParameters parameters});
  Result<dynamic> invoke({required dynamic instance, required InvocationParameters parameters, bool tryAccommodateParameters = false});

  Result<dynamic> obtainValue({required String name, required dynamic instance});
  Result<dynamic> changeValue({required String name, required dynamic instance, required dynamic value});
}
