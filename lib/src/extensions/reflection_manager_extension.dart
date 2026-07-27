import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

extension ReflectionManagerExtension on ReflectionManager {
  Result<Map<String, dynamic>> serializeEntityToMap({required dynamic object}) {
    final typeResult = GetDynamicReflectorByType(dartType: object.runtimeType, reflectionManager: this).execute();
    if (typeResult.itsFailure) {
      return typeResult.cast();
    }

    final type = typeResult.content;
    return type.serialize(value: object, manager: this).cast<Map<String, dynamic>>();
  }
}
