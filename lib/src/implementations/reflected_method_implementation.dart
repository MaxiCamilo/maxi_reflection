import 'dart:developer';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:meta/meta.dart';

abstract class ReflectedMethodImplementation<T> implements ReflectedMethod {
  @protected
  T internalInvoke({required dynamic instance, required InvocationParameters parameters});

  const ReflectedMethodImplementation();

  Result<void> _checkIfStatic(bool hasInstance) {
    if (!hasInstance && !isStatic) {
      return NegativeResult.property(
        propertyName: Oration.searchOration(
          list: anotations,
          defaultOration: FixedOration(message: name),
        ),
        message: FixedOration(message: 'To invoke this method, an instance must be defined (it is not static)'),
      );
    } else {
      return voidResult;
    }
  }

  Result<InvocationParameters> _verifyParameters(InvocationParameters parameters) {
    if (namedParameters.isEmpty && fixedParameters.isEmpty) {
      return ResultValue(content: parameters);
    }

    final paraClon = InvocationParameters.clone(parameters);

    final isFixOk = _verifyFixedParameters(paraClon);
    if (isFixOk.itsFailure) return isFixOk.cast();
    final isNamedOk = _verifyNamedParameters(paraClon);
    if (isNamedOk.itsFailure) return isNamedOk.cast();

    return ResultValue(content: paraClon);
  }

  Result<void> _verifyFixedParameters(InvocationParameters parameters) {
    for (int i = 0; i < fixedParameters.length; i++) {
      final parOper = fixedParameters[i];
      //Exists?
      if (i >= parameters.fixedParameters.length) {
        if (parOper.isOptional) {
          parameters.fixedParameters.add(parOper.defaultValue);
          continue;
        } else {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: anotations,
              defaultOration: FixedOration(message: name),
            ),
            message: FlexibleOration(message: 'To invoke this method, the named parameter %1 must be defined', textParts: [parOper.name]),
          );
        }
      }

      final value = parameters.fixed(i);

      if (!parOper.reflectedType.isObjectCompatible(value: value)) {
        if (parOper.reflectedType.thisObjectCanConvert(rawValue: value)) {
          final conversionResult = parOper.reflectedType.convertOrClone(rawValue: value);
          if (conversionResult.itsCorrect) {
            parameters.namedParameters[parOper.name] = conversionResult.content;
          } else {
            return NegativeResult.property(
              propertyName: Oration.searchOration(
                list: anotations,
                defaultOration: FixedOration(message: name),
              ),
              message: FlexibleOration(message: 'The value for parameter %1 cannot be converted: %2', textParts: [parOper.name, conversionResult.error.message]),
            );
          }
        } else {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: anotations,
              defaultOration: FixedOration(message: name),
            ),
            message: FlexibleOration(message: 'The parameter %1 does not accept the value type %2', textParts: [parOper.name, value.runtimeType]),
          );
        }
      }
    }

    return voidResult;
  }

  Result<void> _verifyNamedParameters(InvocationParameters parameters) {
    for (int i = 0; i < namedParameters.length; i++) {
      final parOper = namedParameters[i];
      //Exists?
      if (i >= parameters.namedParameters.length) {
        if (parOper.isRequired) {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: anotations,
              defaultOration: FixedOration(message: name),
            ),
            message: FlexibleOration(message: 'To be able to invoke this method, %1 fixed arguments are required, but %2 arguments were defined', textParts: [fixedParameters.length, parameters.fixedParameters]),
          );
        } else {
          parameters.namedParameters[parOper.name] = parOper.defaultValue;
          continue;
        }
      }

      final value = parameters.named(parOper.name);
      final isCompatible = parOper.reflectedType.isObjectCompatible(value: value);
      if (!isCompatible) {
        if (parOper.reflectedType.isObjectCompatible(value: value)) {
          final conversionResult = parOper.reflectedType.convertOrClone(rawValue: value);
          if (conversionResult.itsCorrect) {
            parameters.namedParameters[parOper.name] = conversionResult.content;
          } else {
            return NegativeResult.property(
              propertyName: Oration.searchOration(
                list: anotations,
                defaultOration: FixedOration(message: name),
              ),
              message: FlexibleOration(message: 'The value for parameter %1 cannot be converted: %2', textParts: [parOper.name, conversionResult.error.message]),
            );
          }
        } else {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: anotations,
              defaultOration: FixedOration(message: name),
            ),
            message: FlexibleOration(message: 'The parameter %1 does not accept the value type %2', textParts: [parOper.name, value.runtimeType]),
          );
        }
      }
    }

    return voidResult;
  }

  @override
  Result accommodateAndInvoke({required instance, required InvocationParameters parameters}) {
    final ifStaticResult = _checkIfStatic(instance != null);
    if (ifStaticResult.itsFailure) return ifStaticResult.cast();

    if (namedParameters.isEmpty && fixedParameters.isEmpty) {
      return invoke(instance: instance, parameters: parameters);
    }

    final paraClon = InvocationParameters.clone(parameters);

    for (final para in parameters.namedParameters.entries) {
      if (namedParameters.any((x) => x.name == para.key)) continue;

      final correctName = para.key.replaceAll('.', '').replaceAll('-', '').replaceAll(' ', '').toLowerCase();
      for (final candidate in namedParameters) {
        final candidateName = candidate.name.toLowerCase();
        if (correctName == candidateName) {
          paraClon.namedParameters[candidate.name] = para.value;
          continue;
        }
      }

      for (final candidate in fixedParameters) {
        final candidateName = candidate.name.toLowerCase();
        if (correctName == candidateName) {
          paraClon.fixedParameters.insert(candidate.index, para.value);
          continue;
        }
      }
    }

    return invoke(instance: instance, parameters: paraClon);
  }

  @override
  Result invoke({required instance, required InvocationParameters parameters}) {
    final ifStaticResult = _checkIfStatic(instance != null);
    if (ifStaticResult.itsFailure) return ifStaticResult.cast();

    final newParameters = _verifyParameters(parameters);
    if (newParameters.itsFailure) return newParameters;

    try {
      return ResultValue<T>(
        content: internalInvoke(instance: instance, parameters: newParameters.content),
      );
    } catch (ex, st) {
      log('Exception in reflected method $name!: ${ex.toString()}');
      log('---------------------------------------------------------------------------');
      log(st.toString());
      log('---------------------------------------------------------------------------');
      return ExceptionResult(
        exception: ex,
        stackTrace: st,
        message: FlexibleOration(message: 'Exception in reflected method %1', textParts: [name]),
      );
    }
  }
}
