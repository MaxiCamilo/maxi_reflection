import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedEntityBasicCloner<T> implements CustomCloner<T> {
  final ReflectedEntity reflectedEntity;

  const ReflectedEntityBasicCloner({required this.reflectedEntity});

  @override
  Result<T> cloneValue({required T original, ReflectionManager? manager}) {
    if (reflectedEntity.classReflector.isInterface) {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'Entity %1 is an interface; it is not possible to create an instance', textParts: [reflectedEntity.name]),
      );
    }

    final newValueResult = reflectedEntity.createNewInstance(manager: manager);
    if (newValueResult.itsFailure) return newValueResult.cast();
    final newValue = newValueResult.content as T;

    for (final prop in reflectedEntity.changeableFields) {
      final propValueResult = prop.obtainValue(instance: original);
      if (propValueResult.itsFailure) return propValueResult.cast();

      final changeResult = prop.changeValue(instance: newValue, value: propValueResult.content);
      if (changeResult.itsFailure) return changeResult.cast();
    }

    return ResultValue<T>(content: newValue);
  }
}
