import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class GetDynamicReflectorByName implements SyncFunctionality<ReflectedType> {
  final String typeName;
  final ReflectionManager? reflectionManager;
  final List anotations;

  const GetDynamicReflectorByName({required this.typeName, this.reflectionManager, this.anotations = const []});

  @override
  Result<ReflectedType> execute() {
    if (typeName == 'dynamic') {
      return ResultValue(content: ReflectedDynamic(anotations: anotations));
    }

    if (typeName == 'void' || typeName == 'null') {
      return ResultValue(content: ReflectedVoid(anotations: anotations));
    }

    if (typeName.last == '?') {
      final realType = GetDynamicReflectorByName(typeName: typeName.removeLastCharacters(1), reflectionManager: reflectionManager, anotations: anotations).execute();
      if (realType.itsFailure) return realType.cast();

      return ResultValue(
        content: ReflectedNullable(dartType: dynamic, anotations: anotations, reflectedType: realType.content),
      );
    }

    final primitive = GetPrimitiveReflectorByName(name: typeName, anotations: anotations).execute();
    if (primitive.itsFailure) return primitive.cast();
    if (primitive.content != null) return ResultValue(content: primitive.content!);

    final local = GetLocalReflectorByName(name: typeName, anotations: anotations).execute();
    if (local.itsFailure) return primitive.cast();
    if (local.content != null) return ResultValue(content: local.content!);

    if (reflectionManager != null) {
      final reflec = reflectionManager!.trySearchTypeByName(typeName);
      if (reflec.itsFailure) return reflec.cast();
      if (reflec.content != null) return ResultValue(content: reflec.content!);
    }

    return ResultValue(
      content: ReflectedUnknownType(dartType: dynamic, anotations: anotations),
    );
  }
}
