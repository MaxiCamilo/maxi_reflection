import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class EntityValidator implements Validator {
  final ReflectedClass classReflector;

  late final List<Validator> _ownValidators;
  late final Map<ReflectedField, List<Validator>> _fieldValidators;

  EntityValidator({required this.classReflector}) {
    _ownValidators = classReflector.anotations.whereType<Validator>().toList(growable: false);
    _fieldValidators = <ReflectedField, List<Validator>>{};

    for (final field in classReflector.fields) {
      if (field.readOnly) {
        continue;
      }

      final validators = field.anotations.whereType<Validator>().toList(growable: false);
      if (validators.isNotEmpty) _fieldValidators[field] = validators;
    }
  }

  @override
  Result<void> validateValue({required value}) {
    if (!classReflector.isObjectCompatible(value: value)) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'The value of type %1 is not compatible with entity %2', textParts: [value.runtimeType, classReflector.name]),
      );
    }

    for (final validator in _ownValidators) {
      final validResult = validator.validateValue(value: value);
      if (validResult.itsFailure) {
        return validResult.cast();
      }
    }

    for (final part in _fieldValidators.entries) {
      final prop = part.key;
      final validators = part.value;

      final propValueResult = prop.obtainValue(instance: value);
      if (propValueResult.itsFailure) return propValueResult.cast();
      final propValue = propValueResult.content;

      for (final oneValidator in validators) {
        final propResult = oneValidator.validateValue(value: propValue);
        if (propResult.itsFailure) {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: [prop.anotations, ...prop.reflectedType.anotations],
              defaultOration: FixedOration(message: prop.name),
            ),
            message: propResult.error.message,
          );
        }
      }
    }

    return voidResult;
  }
}
