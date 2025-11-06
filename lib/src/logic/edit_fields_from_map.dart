import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class EditFieldsFromMap implements SyncFunctionality<void> {
  final List<ReflectedField> fields;
  final Map<String, dynamic> values;
  final dynamic instance;
  final bool requiredFieldEnable;
  final ReflectionManager? manager;

  const EditFieldsFromMap({required this.fields, required this.instance, required this.values, required this.requiredFieldEnable, required this.manager});

  @override
  Result<void> execute() {
    for (final field in fields) {
      if (field.readOnly) {
        continue;
      }

      if (!values.containsKey(field.name)) {
        if (requiredFieldEnable && field.anotations.any((x) => x == requiredField)) {
          final propertyName = Oration.searchOration(
            list: field.anotations,
            defaultOration: FixedOration(message: field.name),
          );
          return NegativeResult.property(
            propertyName: propertyName,
            message: FlexibleOration(message: 'The field %1 is required for the entity to be valid', textParts: [propertyName]),
          );
        } else {
          continue;
        }
      }

      dynamic fieldValue = values[field.name];

      //It has converter?
      for (final conv in field.anotations.whereType<CustomConverter>()) {
        if (conv.checkIfObjectCanBeConverted(rawValue: fieldValue, manager: manager)) {
          final convValueResult = conv.convertOrClone(rawValue: fieldValue, manager: manager);
          if (convValueResult.itsCorrect) {
            fieldValue = convValueResult.content;
            break;
          } else {
            return NegativeResult.property(
              propertyName: Oration.searchOration(
                list: field.anotations,
                defaultOration: FixedOration(message: field.name),
              ),
              message: convValueResult.error.message,
            );
          }
        }
      }

      final changeValueResult = field.changeValue(instance: instance, value: fieldValue);
      if (changeValueResult.itsFailure) {
        return changeValueResult.cast();
      }
    }

    return voidResult;
  }
}
