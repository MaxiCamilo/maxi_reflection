import 'package:maxi_reflection/maxi_reflection_ext.dart';
import 'package:maxi_reflection/src/types/reflected_type.dart';

class ReflectedFieldInstance<E, R> extends ReflectedFieldImplementation<E, R> {
  @override
  final List anotations;

  @override
  final bool isFinal;

  @override
  final bool isLate;

  @override
  final bool isStatic;

  @override
  final String name;

  @override
  final ReflectedType reflectedType;

  final R Function(E? instance) getter;
  final void Function(E? instance, R value) setter;

  const ReflectedFieldInstance({
    required this.anotations,
    required this.isFinal,
    required this.isLate,
    required this.isStatic,
    required this.name,
    required this.reflectedType,
    required this.setter,
    required this.getter,
  });

  @override
  R internalGetter({required E? instance}) => getter(instance);

  @override
  void internalSetter({required E? instance, required R value}) => setter(instance, value);
}
