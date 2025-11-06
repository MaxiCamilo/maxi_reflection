import 'dart:developer';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:meta/meta.dart';

abstract class ReflectedFieldImplementation<E, R> implements ReflectedField {
  const ReflectedFieldImplementation();

  @protected
  R internalGetter({required E? instance});
  void internalSetter({required E? instance, required R value});

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

  Result<void> _checkInstanceType({required dynamic instance}) {
    if (!isStatic && instance is! E) {
      return NegativeResult.property(
        propertyName: Oration.searchOration(
          list: anotations,
          defaultOration: FixedOration(message: name),
        ),
        message: FlexibleOration(message: 'The field requires an instance of type %1', textParts: [E]),
      );
    }

    return voidResult;
  }

  @override
  Result obtainValue({required instance}) {
    final ifStaticResult = _checkIfStatic(instance != null);
    if (ifStaticResult.itsFailure) return ifStaticResult.cast();

    final itsInstanceCorrect = _checkInstanceType(instance: instance);
    if (itsInstanceCorrect.itsFailure) return itsInstanceCorrect.cast();

    try {
      return ResultValue<R>(content: internalGetter(instance: instance));
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

    final itsInstanceCorrect = _checkInstanceType(instance: instance);
    if (itsInstanceCorrect.itsFailure) return itsInstanceCorrect.cast();

    for (final anot in anotations.whereType<CustomConverter>()) {
      if (anot.checkIfObjectCanBeConverted(rawValue: value)) {
        final convResult = anot.convertOrClone(rawValue: value);
        if (convResult.itsCorrect) {
          value = convResult.content;
        } else {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: anotations,
              defaultOration: FixedOration(message: name),
            ),
            message: convResult.error.message,
          );
        }
      }
    }

    if (!reflectedType.checkThatObjectIsCompatible(value: value)) {
      if (reflectedType.checkIfObjectCanBeConverted(rawValue: value)) {
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
