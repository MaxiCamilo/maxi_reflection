import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class CopySameFields implements SyncFunctionality<Map<String, dynamic>> {
  final Object source;
  final Object destination;
  final ReflectionManager reflectionManager;
  final bool cloneFields;

  const CopySameFields.deepCopy({required this.source, required this.destination, required this.reflectionManager}) : cloneFields = true;
  const CopySameFields.softCopy({required this.source, required this.destination, required this.reflectionManager}) : cloneFields = false;

  @override
  Result<Map<String, dynamic>> execute() {
    final srcReflectorResult = reflectionManager.trySearchEntityReflected(source.runtimeType);
    if (srcReflectorResult.itsFailure) {
      return srcReflectorResult.cast();
    }
    if (srcReflectorResult.content == null) {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'Source type %1 is not reflected', textParts: [source.runtimeType]),
      );
    }
    final srcReflector = srcReflectorResult.content!;

    final destReflectorResult = reflectionManager.trySearchEntityReflected(destination.runtimeType);
    if (destReflectorResult.itsFailure) {
      return destReflectorResult.cast();
    }
    if (destReflectorResult.content == null) {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'Destination type %1 is not reflected', textParts: [destination.runtimeType]),
      );
    }
    final destReflector = destReflectorResult.content!;
    final matchingFields = <(ReflectedField, ReflectedField)>[];

    ///////////////////////////////////////////////////////////////////////////////////////////////

    for (final srcField in srcReflector.changeableFields) {
      final destField = destReflector.changeableFields.selectItem((x) => x.name == srcField.name && srcField.reflectedType.checkIfThisTypeCanBeConverted(type: x.reflectedType.dartType));
      if (destField != null) {
        matchingFields.add((srcField, destField));
      }
    }

    final resultMap = <String, dynamic>{};

    ///////////////////////////////////////////////////////////////////////////////////////////////

    for (final (srcField, destField) in matchingFields) {
      final srcValueResult = srcField.obtainValue(instance: source, manager: reflectionManager);
      if (srcValueResult.itsFailure) {
        return srcValueResult.cast();
      }
      final srcValue = srcValueResult.content;

      if (cloneFields) {
        final clonedValueResult = DeepClonation(reflectionManager: reflectionManager, source: srcValue).execute();
        if (clonedValueResult.itsFailure) {
          return clonedValueResult.cast();
        }
        final clonedValue = clonedValueResult.content;
        final destSetResult = destField.changeValue(instance: destination, value: clonedValue, manager: reflectionManager);
        if (destSetResult.itsFailure) {
          return destSetResult.cast();
        }
        resultMap[destField.name] = clonedValue;
      } else {
        final destSetResult = destField.changeValue(instance: destination, value: srcValue, manager: reflectionManager);
        if (destSetResult.itsFailure) {
          return destSetResult.cast();
        }
        resultMap[destField.name] = srcValue;
      }
    }

    return ResultValue(content: resultMap);
  }
}
