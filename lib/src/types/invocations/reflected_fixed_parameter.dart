import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedFixedParameter {
  final List anotations;
  final ReflectedType reflectedType;
  final String name;
  final int index;
  final bool isOptional;
  final dynamic defaultValue;

  const ReflectedFixedParameter({required this.anotations, required this.reflectedType, required this.name, required this.index, required this.isOptional, required this.defaultValue});
}
