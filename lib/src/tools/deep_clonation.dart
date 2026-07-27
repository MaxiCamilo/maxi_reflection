import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class DeepClonation<T> implements SyncFunctionality<T> {
  final ReflectionManager reflectionManager;
  final T source;

  const DeepClonation({required this.reflectionManager, required this.source});

  @override
  Result<T> execute() {
    final operatorResult = GetDynamicReflectorByType(dartType: source.runtimeType, reflectionManager: reflectionManager).execute();
    if (operatorResult.itsFailure) {
      return operatorResult.cast();
    }

    final operatorType = operatorResult.content;
    return operatorType.convertOrClone(rawValue: source, manager: reflectionManager).cast<T>();
  }
}
