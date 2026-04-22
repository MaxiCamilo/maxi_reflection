import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedValidator with DisposableMixin, InitializableMixin implements Validator {
  final ReflectedClass reflectedClass;
  final ReflectionManager manager;

  late List<Validator> _classValidators;
  late List<(ReflectedField, List<Validator>)> _fieldValidators;
  late List<ReflectedField> _reflectedFieldList;
  late List<ReflectedField> _fieldList;

  ReflectedValidator({required this.reflectedClass, required this.manager});

  factory ReflectedValidator.fromType({required Type type, required ReflectionManager manager}) {
    final reflectedClassResult = manager.trySearchClassByType(type);
    if (reflectedClassResult.itsFailure) {
      throw Exception('The type $type is not compatible with any reflected class in the manager');
    }
    return ReflectedValidator(reflectedClass: reflectedClassResult.content!, manager: manager);
  }

  @override
  Result<void> performInitialization() {
    _classValidators = reflectedClass.anotations.whereType<Validator>().toList();
    _fieldValidators = [];
    _fieldList = [];
    _reflectedFieldList = [];
    for (final field in reflectedClass.fields) {
      final validators = field.anotations.whereType<Validator>().toList();
      if (validators.isNotEmpty) {
        _fieldValidators.add((field, validators));
      }

      if (field.reflectedType.reflectionMode == ReflectedTypeMode.classType) {
        _reflectedFieldList.add(field);
      }

      if (field.reflectedType.reflectionMode == ReflectedTypeMode.list) {
        _fieldList.add(field);
      }
    }

    return voidResult;
  }

  @override
  Result<void> validateValue({required value}) {
    final initResult = initialize();
    if (initResult.itsFailure) {
      return initResult.cast();
    }

    if (!reflectedClass.checkThatObjectIsCompatible(value: value)) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'A value of type %1 was defined in a validator of type %2, which are not compatible', textParts: [value.runtimeType, reflectedClass.typeSignature]),
      );
    }

    for (final validator in _classValidators) {
      final result = validator.validateValue(value: value);
      if (result.itsFailure) {
        return result;
      }
    }

    final errorFields = <InvalidProperty>[];

    for (final (field, validators) in _fieldValidators) {
      final fieldValue = field.obtainValue(instance: value, manager: manager);
      if (fieldValue.itsFailure) {
        final text = field.anotations.selectType<Oration>() ?? FixedOration(message: field.name);
        errorFields.add(InvalidProperty(propertyName: text, message: fieldValue.error.message));
      }
      for (final validator in validators) {
        final result = validator.validateValue(value: fieldValue.content);
        if (result.itsFailure) {
          final text = field.anotations.selectType<Oration>() ?? FixedOration(message: field.name);
          errorFields.add(InvalidProperty(propertyName: text, message: fieldValue.error.message));
        }
      }
    }

    ReflectedClass? lastReflectedClass;

    for (final field in _reflectedFieldList) {
      final fieldValue = field.obtainValue(instance: value, manager: manager);
      if (fieldValue.itsFailure) {
        final text = field.anotations.selectType<Oration>() ?? FixedOration(message: field.name);
        errorFields.add(InvalidProperty(propertyName: text, message: fieldValue.error.message));
      }

      if (fieldValue.content == null) continue;

      if (lastReflectedClass == null || !lastReflectedClass.checkThatTypeIsCompatible(type: fieldValue.content.runtimeType)) {
        final reflectedClassResult = manager.trySearchClassByType(fieldValue.content.runtimeType);
        if (reflectedClassResult.itsFailure) {
          final text = field.anotations.selectType<Oration>() ?? FixedOration(message: field.name);
          errorFields.add(
            InvalidProperty(
              propertyName: text,
              message: FlexibleOration(message: 'The type %1 of the property is not compatible with any reflected class in the validator', textParts: [fieldValue.content.runtimeType]),
            ),
          );
          continue;
        }
        lastReflectedClass = reflectedClassResult.content!;
      }

      final valResult = ReflectedValidator(reflectedClass: lastReflectedClass, manager: manager).validateValue(value: fieldValue.content);
      if (valResult.itsFailure) {
        final text = field.anotations.selectType<Oration>() ?? FixedOration(message: field.name);
        errorFields.add(InvalidProperty(propertyName: text, message: valResult.error.message));
      }
    }

    for (final field in _fieldList) {
      final fieldValue = field.obtainValue(instance: value, manager: manager).cast<Iterable>();
      if (fieldValue.itsFailure) {
        final text = field.anotations.selectType<Oration>() ?? FixedOration(message: field.name);
        errorFields.add(InvalidProperty(propertyName: text, message: fieldValue.error.message));
      }

      int position = 1;
      for (final item in fieldValue.content) {
        if (item == null) continue;

        final primitiveResult = GetPrimitiveReflector(dartType: item.runtimeType).execute();
        if (primitiveResult.itsFailure) {
          final text = field.anotations.selectType<Oration>() ?? FixedOration(message: field.name);
          errorFields.add(
            InvalidProperty(
              propertyName: text,
              message: FlexibleOration(message: 'The item in position %1 of the list is of type %2, which is not supported by the validator', textParts: [position, item.runtimeType]),
            ),
          );
        }

        if (primitiveResult.content != null) continue;

        if (lastReflectedClass == null || !lastReflectedClass.checkThatTypeIsCompatible(type: item.runtimeType)) {
          final reflectedClassResult = manager.trySearchClassByType(item.runtimeType);
          if (reflectedClassResult.itsFailure) {
            final text = field.anotations.selectType<Oration>() ?? FixedOration(message: field.name);
            errorFields.add(
              InvalidProperty(
                propertyName: text,
                message: FlexibleOration(message: 'The item in position %1 of the list is of type %2, which is not compatible with any reflected class in the validator', textParts: [position, item.runtimeType]),
              ),
            );
            continue;
          }
          lastReflectedClass = reflectedClassResult.content!;
        }

        final itemValResult = ReflectedValidator(reflectedClass: lastReflectedClass, manager: manager).validateValue(value: item);
        if (itemValResult.itsFailure) {
          final text = field.anotations.selectType<Oration>() ?? FixedOration(message: field.name);
          errorFields.add(
            InvalidProperty(
              propertyName: text,
              message: FlexibleOration(message: 'The item in position %1 of the list is invalid due to the following reason: %2', textParts: [position, itemValResult.error.message]),
            ),
          );
        }
        position++;
      }
    }

    if (errorFields.isNotEmpty) {
      return NegativeResult.entity(
        entityName: reflectedClass.anotations.selectType<Oration>() ?? FixedOration(message: reflectedClass.name),
        invalidProperties: errorFields,
      );
    }

    return voidResult;
  }

  @override
  void performObjectDiscard() {}
}
