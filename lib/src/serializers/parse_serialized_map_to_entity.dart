import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ParseSerializedMapToEntity implements SyncFunctionality<dynamic> {
  final Map<String, dynamic> serializedMap;
  final ReflectionManager reflectionManager;

  const ParseSerializedMapToEntity({required this.serializedMap, required this.reflectionManager});

  @override
  Result<dynamic> execute() {
    final typeSignature = serializedMap[ReflectedType.prefixType];
    if (typeSignature == null) {
      return NegativeResult.controller(
        code: ErrorCode.incorrectFormat,
        message: FixedOration(message: 'The serialized map does not contain the type signature'),
      );
    }

    final reflectedClassResult = reflectionManager.trySearchTypeByName(typeSignature);
    if (reflectedClassResult.itsFailure) return reflectedClassResult.cast();

    if (reflectedClassResult.content == null) {
      return NegativeResult.controller(
        code: ErrorCode.incorrectFormat,
        message: FlexibleOration(message: 'The serialized map contains an unknown type signature %1', textParts: [typeSignature]),
      );
    }

    return reflectedClassResult.content!.convertOrClone(rawValue: serializedMap, manager: reflectionManager);
  }
}
