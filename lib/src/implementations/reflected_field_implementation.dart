import 'dart:developer';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:meta/meta.dart';

abstract class ReflectedFieldImplementation<T> implements ReflectedField {
  const ReflectedFieldImplementation();

  @protected
  T internalGetter({required dynamic instance});
  void internalSetter({required dynamic instance, required dynamic value});

  @override
  bool get readOnly => isFinal;

  Result<void> _checkIfStatic(bool hasInstance) {
    if (!hasInstance && !isStatic) {
      return NegativeResult.property(
        propertyName: Oration.searchOration(
          list: anotations,
          defaultOration: FixedOration(message: name),
        ),
        message: FixedOration(message: 'An instance is required to get the value of this field, as it is not static'),
      );
    } else {
      return voidResult;
    }
  }

  @override
  Result obtainValue({required instance}) {
    final ifStaticResult = _checkIfStatic(instance != null);
    if (ifStaticResult.itsFailure) return ifStaticResult.cast();

    try {
      return ResultValue<T>(content: internalGetter(instance: instance));
    } catch (ex, st) {
      log('Exception in obtain field value $name!: ${ex.toString()}');
      log('---------------------------------------------------------------------------');
      log(st.toString());
      log('---------------------------------------------------------------------------');
      return ExceptionResult(
        exception: ex,
        stackTrace: st,
        message: FlexibleOration(message: 'Exception in obtain field value %1', textParts: [name]),
      );
    }
  }

  @override
  Result<void> changeValue({required instance, required value}) {
    if (readOnly) {
      return NegativeResult.property(
        propertyName: Oration.searchOration(
          list: anotations,
          defaultOration: FixedOration(message: name),
        ),
        message: FlexibleOration(message: 'Field %1 is read-only and may not be changed', textParts: [name]),
      );
    }

    final ifStaticResult = _checkIfStatic(instance != null);
    if (ifStaticResult.itsFailure) return ifStaticResult.cast();

    if (!reflectedType.isObjectCompatible(value: value)) {
      if (reflectedType.thisObjectCanConvert(rawValue: value)) {
        final convertedResult = reflectedType.convertOrClone(rawValue: value);
        if (convertedResult.itsCorrect) {
          value = convertedResult.content;
        } else {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: anotations,
              defaultOration: FixedOration(message: name),
            ),
            message: FlexibleOration(message: 'The value for field %1 was attempted to be made compatile, because: %2', textParts: [name, convertedResult.error.message]),
          );
        }
      } else {
        return NegativeResult.property(
          propertyName: Oration.searchOration(
            list: anotations,
            defaultOration: FixedOration(message: name),
          ),
          message: FlexibleOration(message: 'The field %1 does not accept a value of type %2', textParts: [name]),
        );
      }
    }

    try {
      internalSetter(instance: instance, value: value);
      return voidResult;
    } catch (ex, st) {
      log('Exception when changing the value of field $name!: ${ex.toString()}');
      log('---------------------------------------------------------------------------');
      log(st.toString());
      log('---------------------------------------------------------------------------');
      return ExceptionResult(
        exception: ex,
        stackTrace: st,
        message: FlexibleOration(message: 'Exception in reflected field %1', textParts: [name]),
      );
    }
  }
}
