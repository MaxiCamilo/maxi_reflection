import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectedField {
  List get anotations;
  ReflectedType get reflectedType;
  String get name;
  bool get isStatic;
  bool get readOnly;
  bool get isLate;
  bool get isFinal;

  Result<void> changeValue({required dynamic instance, required dynamic value});
  Result<dynamic> obtainValue({required dynamic instance});
}
