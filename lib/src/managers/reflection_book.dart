import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectionBook {
  String get prefixName;

  List<ReflectedEnum> buildEnums({required ReflectionManager manager});

  List<ReflectedClass> buildClassReflectors({required ReflectionManager manager});

  List<ReflectedType> buildOtherReflectors({required ReflectionManager manager});
}
