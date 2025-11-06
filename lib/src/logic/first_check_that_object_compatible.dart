import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class FirstCheckThatObjectCompatible implements SyncFunctionality<void> {
  final ReflectedType reflectedType;
  final dynamic object;
  final bool acceptNull;
  final ReflectionManager? manager;

  const FirstCheckThatObjectCompatible({required this.reflectedType, required this.object, required this.acceptNull, required this.manager});

  @override
  Result<void> execute() {
    if (object == null) {
      if (acceptNull) {
        return voidResult;
      } else {
        return NegativeResult.controller(
          code: ErrorCode.nullValue,
          message: FixedOration(message: 'Null values are not accepted'),
        );
      }
    }

    if (reflectedType.checkThatObjectIsCompatible(value: object) || reflectedType.checkIfObjectCanBeConverted(rawValue: object, manager: manager)) {
      return voidResult;
    } else {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'This value %1 is not compatible with type %2', textParts: [object.runtimeType, reflectedType.name]),
      );
    }
  }
}
