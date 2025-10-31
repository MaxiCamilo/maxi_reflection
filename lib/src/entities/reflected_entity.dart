import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectedEntity implements ReflectedType {
  ReflectedClass get classReflector;

  Oration get formalName;

  bool get itHasPrimaryKey;
  Validator get validator;

  List<CustomConverter> get customConverters;
  List<CustomSerializer> get customSerializers;

  List<ReflectedField> get changeableFields;

  Result<ReflectedField> getPrimaryKeyField();
  Result<int> getPrimaryKey({required dynamic item});

  ReflectedEntity makeAnotherReflector({List<CustomConverter> preferentCustomConverters = const [], List<CustomSerializer> preferentCustomSerializers = const []});

  ReflectedEntityInterpreter<Map<String, dynamic>> buildMapInterpreter({required bool identifierRequired, required bool zeroIdentifiersAreAccepted, required bool requiredFieldEnable});
  CustomSerializer<Map<String, dynamic>> buildMapSerializator();

  List buildEmptyList();

  Result<List> buildList({required List rawValues});
}
