import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedEntityChangePrimaryKey implements SyncFunctionality<void> {
  final bool identifierRequired;
  final bool zeroIdentifiersAreAccepted;

  final ReflectedEntity entityClass;
  final dynamic instance;
  final dynamic idValue;

  const ReflectedEntityChangePrimaryKey({required this.instance, required this.idValue, required this.entityClass, required this.identifierRequired, required this.zeroIdentifiersAreAccepted});

  @override
  Result<void> execute() {
    if (!entityClass.itHasPrimaryKey) {
      return voidResult;
    }

    int? id;

    final primaryKeyResult = entityClass.getPrimaryKeyField();
    if (primaryKeyResult.itsFailure) return primaryKeyResult.cast();
    final primaryKey = primaryKeyResult.content;

    if (idValue != null) {
      final idResult = PrimitiveConverter.castInt(idValue);
      if (idResult.itsCorrect) {
        id = idResult.content;
      } else {
        return NegativeResult.property(
          propertyName: Oration.searchOration(
            list: primaryKey.anotations,
            defaultOration: FixedOration(message: primaryKey.name),
          ),
          message: idResult.error.message,
        );
      }
    }

    if (identifierRequired && id == null) {
      return NegativeResult.property(
        propertyName: entityClass.formalName,
        message: FlexibleOration(
          message: 'The entity identifier field is missing (%1)',
          textParts: [
            Oration.searchOration(
              list: primaryKey.anotations,
              defaultOration: FixedOration(message: primaryKey.name),
            ),
          ],
        ),
      );
    }

    if (id != null) {
      if (id == 0 && !zeroIdentifiersAreAccepted) {
        return NegativeResult.property(
          propertyName: entityClass.formalName,
          message: FlexibleOration(
            message: 'Identifiers equal to zero are not accepted (%1)',
            textParts: [
              Oration.searchOration(
                list: primaryKey.anotations,
                defaultOration: FixedOration(message: primaryKey.name),
              ),
            ],
          ),
        );
      }

      if (id < 0) {
        return NegativeResult.property(
          propertyName: entityClass.formalName,
          message: FlexibleOration(
            message: 'Negative IDs are not permitted (%1)',
            textParts: [
              Oration.searchOration(
                list: primaryKey.anotations,
                defaultOration: FixedOration(message: primaryKey.name),
              ),
            ],
          ),
        );
      }

      final changeResult = primaryKey.changeValue(instance: instance, value: idValue);
      if (changeResult.itsFailure) {
        return NegativeResult.property(
          propertyName: Oration.searchOration(
            list: primaryKey.anotations,
            defaultOration: FixedOration(message: primaryKey.name),
          ),
          message: FlexibleOration(message: 'Could not change the primary key of entity %1: %2', textParts: [entityClass.formalName, changeResult.error.message]),
        );
      }
    }

    return voidResult;
  }
}
