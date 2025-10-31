import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectionManager {
  List<ReflectedType> get reflectedTypes;
  List<ReflectedEnum> get reflectedEnums;

  List<ReflectedType> get customReflectors;

  Result<ReflectedType?> trySearchTypeByType(Type type);
  Result<ReflectedType?> trySearchTypeByName(String name);

  bool addCustomReflector(ReflectedType newReflector);
}
