import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';
//import 'package:maxi_reflection/src/types/invocations/reflected_fixed_parameter.dart';
//import 'package:maxi_reflection/src/types/invocations/reflected_named_parameter.dart';

enum ReflectedMethodType { method, contructor, getter, setter }

abstract interface class ReflectedMethod {
  List get anotations;
  ReflectedType get reflectedType;
  String get name;
  bool get isStatic;
  ReflectedMethodType get methodType;
  List<ReflectedFixedParameter> get fixedParameters;
  List<ReflectedNamedParameter> get namedParameters;

  Result<dynamic> invoke({required dynamic instance, required InvocationParameters parameters});
  Result<dynamic> accommodateAndInvoke({required dynamic instance, required InvocationParameters parameters});
}
