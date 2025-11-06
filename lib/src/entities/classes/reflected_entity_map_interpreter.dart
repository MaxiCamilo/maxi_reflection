import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/src/entities/classes/reflected_entity_change_primary_key.dart';
import 'package:maxi_reflection/src/logic/edit_fields_from_map.dart';

class ReflectedEntityMapInterpreter<T> implements ReflectedEntityInterpreter<Map<String, dynamic>, T> {
  final bool identifierRequired;
  final bool zeroIdentifiersAreAccepted;
  final bool requiredFieldEnable;

  final ReflectedEntity<T> entityClass;

  const ReflectedEntityMapInterpreter({required this.identifierRequired, required this.zeroIdentifiersAreAccepted, required this.requiredFieldEnable, required this.entityClass});

  @override
  Result<T> interpretValue({required Map<String, dynamic> values, template, bool validate = true, ReflectionManager? manager}) {
    late final T newValue;
    if (template == null) {
      final newValueResult = entityClass.createNewInstance(manager: manager);
      if (newValueResult.itsFailure) return newValueResult.cast();
      newValue = newValueResult.content;
    } else {
      final newValueResult = entityClass.convertOrClone(rawValue: template, manager: manager);
      if (newValueResult.itsFailure) return newValueResult.cast();
      newValue = newValueResult.content;
    }



    final hasPrimaryKey = entityClass.getPrimaryKeyField();
    if (hasPrimaryKey.itsCorrect) {
      final changePrimaryKeyResult = ReflectedEntityChangePrimaryKey(
        instance: newValue,
        idValue: values[hasPrimaryKey.content.name],
        entityClass: entityClass,
        identifierRequired: identifierRequired,
        zeroIdentifiersAreAccepted: zeroIdentifiersAreAccepted,
      ).execute();
      if (changePrimaryKeyResult.itsFailure) return changePrimaryKeyResult.cast();
    }

    final changeResult = EditFieldsFromMap(fields: entityClass.changeableFields, requiredFieldEnable: requiredFieldEnable, values: values, manager: manager, instance: newValue).execute();
    if (changeResult.itsFailure) return changeResult.cast();

    return ResultValue<T>(content: newValue);
  }
}
