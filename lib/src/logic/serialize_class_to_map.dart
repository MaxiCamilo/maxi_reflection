import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class SerializeClassToMap implements CustomSerializer<Map<String, dynamic>> {
  final ReflectedClass reflectedClass;
  final List<ReflectedField> fields;
  final ReflectionManager? manager;

  const SerializeClassToMap({required this.reflectedClass, required this.fields, required this.manager});

  @override
  bool thisObjectCanSerialize({required rawValue, ReflectionManager? manager}) => reflectedClass.checkIfObjectCanBeConverted(rawValue: rawValue, manager: manager);

  @override
  Result<Map<String, dynamic>> serialize({required value, ReflectionManager? manager}) {
    if (!reflectedClass.checkThatObjectIsCompatible(value: value)) {
      final reconvertResult = reflectedClass.convertOrClone(rawValue: value, manager: manager);
      if (reconvertResult.itsFailure) {
        return reconvertResult.cast();
      }
      value = reconvertResult.content;
    }

    final mapValue = <String, dynamic>{ReflectedType.prefixType: reflectedClass.typeSignature};

    for (final field in fields) {
      final fieldValueResult = field.obtainValue(instance: value);
      if (fieldValueResult.itsFailure) return fieldValueResult.cast();

      dynamic serializeValue;
      for (final conv in field.anotations.whereType<CustomSerializer>()) {
        if (conv.thisObjectCanSerialize(rawValue: fieldValueResult.content)) {
          final convertResult = conv.serialize(value: fieldValueResult.content, manager: manager);
          if (convertResult.itsCorrect) {
            serializeValue = convertResult.content;
            break;
          } else {
            return NegativeResult.property(
              propertyName: Oration.searchOration(
                list: field.anotations,
                defaultOration: FixedOration(message: field.name),
              ),
              message: convertResult.error.message,
            );
          }
        }
      }

      if (serializeValue == null) {
        final currentSerializationResult = field.reflectedType.serialize(value: fieldValueResult.content, manager: manager);
        if (currentSerializationResult.itsCorrect) {
          serializeValue = currentSerializationResult.content;
        } else {
          return NegativeResult.property(
            propertyName: Oration.searchOration(
              list: field.anotations,
              defaultOration: FixedOration(message: field.name),
            ),
            message: currentSerializationResult.error.message,
          );
        }
      }

      mapValue[field.name] = serializeValue;
    }

    return ResultValue(content: mapValue);
  }
}
