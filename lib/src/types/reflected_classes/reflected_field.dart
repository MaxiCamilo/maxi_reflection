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

  Result<void> changeValue({required dynamic instance, required dynamic value, required ReflectionManager manager});
  Result<dynamic> obtainValue({required dynamic instance, required ReflectionManager manager});

  static Never constSeterError(String name) => throw NegativeResult.controller(
    code: ErrorCode.implementationFailure,
    message: FlexibleOration(message: 'Field %1 is constant, it cannot be modified', textParts: [name]),
  );

  static Never finalSeterError(String name) => throw NegativeResult.controller(
    code: ErrorCode.implementationFailure,
    message: FlexibleOration(message: 'Field %1 cannot be modified', textParts: [name]),
  );
}
