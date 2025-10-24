import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class GetDynamicReflectorByType implements SyncFunctionality<ReflectedType> {
  final Type dartType;
  final ReflectionManager? reflectionManager;
  final List anotations;

  const GetDynamicReflectorByType({required this.dartType, this.reflectionManager, this.anotations = const []});

  @override
  Result<ReflectedType> execute() {
    if (dartType == dynamic) {
      return ResultValue(content: ReflectedDynamic(anotations: anotations));
    }

    final name = dartType.toString();

    if (name == 'void') {
      return ResultValue(content: ReflectedVoid(anotations: anotations));
    }

    final primitive = GetPrimitiveReflector(dartType: dartType).execute();
    if (primitive.itsFailure) return primitive.cast();
    if (primitive.content != null) return ResultValue(content: primitive.content!);

    if (name.last == '?') {
      final realType = GetDynamicReflectorByName(typeName: name.removeLastCharacters(1), reflectionManager: reflectionManager, anotations: anotations).execute();
      if (realType.itsFailure) return realType.cast();

      return ResultValue(
        content: ReflectedNullable(dartType: dartType, anotations: anotations, reflectedType: realType.content),
      );
    }

    final local = GetLocalReflector(dartType: dartType, anotations: anotations).execute();
    if (local.itsFailure) return primitive.cast();
    if (local.content != null) return ResultValue(content: local.content!);

    if (reflectionManager != null) {
      for (final refleEnum in reflectionManager!.reflectedEnums) {
        if (refleEnum.isTypeCompatible(type: dartType)) {
          return ResultValue(content: refleEnum);
        }
      }

      for (final refleType in reflectionManager!.reflectedTypes) {
        if (refleType.isTypeCompatible(type: dartType)) {
          return ResultValue(content: refleType);
        }
      }
    }

    return ResultValue(
      content: ReflectedUnknownType(dartType: dartType, anotations: anotations),
    );
    /*
    return NegativeResult.controller(
      code: ErrorCode.implementationFailure,
      message: FlexibleOration(message: 'No reflector found for type %1', textParts: [dartType]),
    );*/
  }
}
