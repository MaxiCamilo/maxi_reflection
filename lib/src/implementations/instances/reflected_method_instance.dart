import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';
import 'package:maxi_reflection/src/types/reflected_classes/reflected_method.dart';
import 'package:maxi_reflection/src/types/reflected_type.dart';

class ReflectedMethodInstance<E, R> extends ReflectedMethodImplementation<E, R> {
  @override
  final List anotations;

  @override
  final String name;

  @override
  final bool isStatic;

  @override
  final ReflectedMethodType methodType;

  @override
  final List<ReflectedFixedParameter> fixedParameters;

  @override
  final List<ReflectedNamedParameter> namedParameters;

  @override
  final ReflectedType reflectedType;

  final R Function(E? instance, InvocationParameters parameters) invoker;

  const ReflectedMethodInstance({
    required this.anotations,
    required this.name,
    required this.isStatic,
    required this.methodType,
    required this.fixedParameters,
    required this.namedParameters,
    required this.reflectedType,
    required this.invoker,
  });

  @override
  R internalInvoke({required E? instance, required InvocationParameters parameters}) => invoker(instance, parameters);
}
