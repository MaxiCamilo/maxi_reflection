import 'dart:typed_data';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class GetPrimitiveReflectorByName implements SyncFunctionality<ReflectedType?> {
  final String name;

  final List anotations;

  const GetPrimitiveReflectorByName({required this.name,  this.anotations = const []});

  @override
  Result<ReflectedType?> execute() {
    String lowName = name.toLowerCase();
    if (lowName == 'string') return ResultValue(content: ReflectedPrimitiveString(anotations: anotations));
    if (lowName == 'int') return ResultValue(content: ReflectedPrimitiveInt(anotations: anotations));
    if (lowName == 'double') return ResultValue(content: ReflectedPrimitiveDouble(anotations: anotations));
    if (lowName == 'datetime') return ResultValue(content: ReflectedPrimitiveDatetime(anotations: anotations));
    if (lowName == 'uint8list') return ResultValue(content: ReflectedPrimitiveBinary(anotations: anotations));
    if (lowName == 'bool') return ResultValue(content: ReflectedPrimitiveBool(anotations: anotations));

    if (name.toString().last == '?') {
      final realTypeName = name.toString().removeLastCharacters(1);
      lowName = realTypeName.toLowerCase();
      final realType = _getDartTypeByName(lowName);
      if (realType == null) {
        return ResultValue(content: null);
      }

      final searchByName = GetPrimitiveReflectorByName(name: lowName,  anotations: anotations).execute();
      if (searchByName.itsFailure || searchByName.content == null) return searchByName;
      return ResultValue(
        content: ReflectedNullable(dartType: realType, anotations: anotations, reflectedType: searchByName.content!),
      );
    }

    return ResultValue(content: null);
  }

  static Type? _getDartTypeByName(String lowName) {
    return switch (lowName) {
      'string' => String,
      'int' => int,
      'double' => double,
      'datetime' => DateTime,
      'uint8list' => Uint8List,
      'bool' => bool,
      _ => null,
    };
  }
}
