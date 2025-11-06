import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectedEntity<T> implements ReflectedType {
  ReflectedClass get classReflector;

  Oration get formalName;

  bool get itHasPrimaryKey;
  Validator get validator;

  List<CustomConverter> get customConverters;
  List<CustomSerializer> get customSerializers;

  List<ReflectedField> get changeableFields;
  CustomCloner<T> get cloner;

  Result<ReflectedField> getPrimaryKeyField();
  Result<int> getPrimaryKey({required dynamic item});
  Result<void> changePrimaryKey({required dynamic item, required int newID});

  ReflectedEntity makeAnotherReflector({List<CustomConverter> preferentCustomConverters = const [], List<CustomSerializer> preferentCustomSerializers = const []});

  ReflectedEntityInterpreter<Map<String, dynamic>, T> buildMapInterpreter({required bool identifierRequired, required bool zeroIdentifiersAreAccepted, required bool requiredFieldEnable});
  CustomSerializer<Map<String, dynamic>> buildMapSerializator({required dynamic rawValue});

  @override
  Result<T> convertOrClone({required rawValue, ReflectionManager? manager});

  @override
  Result<T> createNewInstance({ReflectionManager? manager});

  Result<List<T>> buildEmptyList();
}
