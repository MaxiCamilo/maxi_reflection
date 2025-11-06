import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectionManager {
  List<ReflectedType> get reflectedTypes;
  List<ReflectedEnum> get reflectedEnums;

  List<ReflectedType> get customReflectors;

  Result<ReflectedEntity<T>> searchEntityReflected<T>();

  Result<ReflectedEntity?> trySearchEntityReflected(Type type);

  Result<ReflectedType?> trySearchTypeByType(Type type);
  Result<ReflectedType?> trySearchTypeByName(String name);

  Result<ReflectedClass?> trySearchClassByName(String name);
  Result<ReflectedClass?> trySearchClassByType(Type type);

  bool addCustomReflector(ReflectedType newReflector);
}
