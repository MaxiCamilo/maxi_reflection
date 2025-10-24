import 'dart:typed_data';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class GetPrimitiveReflector implements SyncFunctionality<ReflectedType?> {
  final Type dartType;
  final List anotations;

  const GetPrimitiveReflector({required this.dartType, this.anotations = const []});

  @override
  Result<ReflectedType?> execute() {
    if (dartType == String) return ResultValue(content: ReflectedPrimitiveString(anotations: anotations));
    if (dartType == int) return ResultValue(content: ReflectedPrimitiveInt(anotations: anotations));
    if (dartType == double) return ResultValue(content: ReflectedPrimitiveDouble(anotations: anotations));
    if (dartType == DateTime) return ResultValue(content: ReflectedPrimitiveDatetime(anotations: anotations));
    if (dartType == Uint8List) return ResultValue(content: ReflectedPrimitiveBinary(anotations: anotations));
    if (dartType == bool) return ResultValue(content: ReflectedPrimitiveBool(anotations: anotations));

    if (dartType.toString().last == '?') {
      final realTypeName = dartType.toString().removeLastCharacters(1);
      final searchByName = GetPrimitiveReflectorByName(name: realTypeName,  anotations: anotations).execute();
      if (searchByName.itsFailure || searchByName.content == null) return searchByName;
      return ResultValue(
        content: ReflectedNullable(dartType: dartType, anotations: anotations, reflectedType: searchByName.content!),
      );
    }

    return ResultValue(content: null);
  }
}
