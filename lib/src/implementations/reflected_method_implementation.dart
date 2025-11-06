import 'dart:developer';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:meta/meta.dart';

abstract class ReflectedMethodImplementation<E, R> implements ReflectedMethod {
  @protected
  R internalInvoke({required E? instance, required InvocationParameters parameters});

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

      dynamic value = parameters.fixed(i);
      for (final anot in parOper.anotations.whereType<CustomConverter>()) {
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

      if (!parOper.reflectedType.checkThatObjectIsCompatible(value: value)) {
        if (parOper.reflectedType.checkIfObjectCanBeConverted(rawValue: value)) {
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
    for (final prop in namedParameters) {
      //Exists?
      if (!parameters.namedParameters.containsKey(prop.name)) {
        if (prop.isRequired) {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: anotations,
              defaultOration: FixedOration(message: name),
            ),
            message: FlexibleOration(message: 'To be able to invoke this method, %1 fixed arguments are required, but %2 arguments were defined', textParts: [fixedParameters.length, parameters.fixedParameters]),
          );
        } else {
          parameters.namedParameters[prop.name] = prop.defaultValue;
          continue;
        }
      }

      dynamic propValue = parameters.namedParameters[prop.name];

      for (final anot in prop.anotations.whereType<CustomConverter>()) {
        if (anot.checkIfObjectCanBeConverted(rawValue: propValue)) {
          final convResult = anot.convertOrClone(rawValue: propValue);
          if (convResult.itsCorrect) {
            propValue = convResult.content;
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

      final isCompatible = prop.reflectedType.checkThatObjectIsCompatible(value: propValue);
      if (!isCompatible) {
        if (prop.reflectedType.checkIfObjectCanBeConverted(rawValue: propValue)) {
          final conversionResult = prop.reflectedType.convertOrClone(rawValue: propValue);
          if (conversionResult.itsCorrect) {
            parameters.namedParameters[prop.name] = conversionResult.content;
          } else {
            return NegativeResult.property(
              propertyName: Oration.searchOration(
                list: anotations,
                defaultOration: FixedOration(message: name),
              ),
              message: FlexibleOration(message: 'The value for parameter %1 cannot be converted: %2', textParts: [prop.name, conversionResult.error.message]),
            );
          }
        } else {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: anotations,
              defaultOration: FixedOration(message: name),
            ),
            message: FlexibleOration(message: 'The parameter %1 does not accept the value type %2', textParts: [prop.name, propValue.runtimeType]),
          );
        }
      }
    }

    return voidResult;
  }

  @override
  Result<R> accommodateAndInvoke({required instance, required InvocationParameters parameters}) {
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
  Result<R> invoke({required instance, required InvocationParameters parameters}) {
    final ifStaticResult = _checkIfStatic(instance != null);
    if (ifStaticResult.itsFailure) return ifStaticResult.cast();

    if (!isStatic && instance is! E) {
      return NegativeResult.property(
        propertyName: Oration.searchOration(
          list: anotations,
          defaultOration: FixedOration(message: name),
        ),
        message: FlexibleOration(message: 'The method requires an instance of type %1', textParts: [E]),
      );
    }

    final newParameters = _verifyParameters(parameters);
    if (newParameters.itsFailure) return newParameters.cast();

    try {
      final resultValue = ResultValue<R>(
        content: internalInvoke(instance: isStatic ? null : instance, parameters: newParameters.content),
      );

      if (resultValue.itsFailure) return resultValue;

      dynamic value = resultValue.content;

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

      return ResultValue(content: value).cast<R>();
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
