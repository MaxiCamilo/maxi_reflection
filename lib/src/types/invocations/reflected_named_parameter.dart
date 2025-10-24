import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedNamedParameter {
  final List anotations;
  final ReflectedType reflectedType;
  final String name;
  final bool isRequired;
  final dynamic defaultValue;

  const ReflectedNamedParameter({required this.anotations, required this.reflectedType, required this.name, required this.isRequired, required this.defaultValue});
}
