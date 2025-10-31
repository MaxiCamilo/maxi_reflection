import 'dart:typed_data';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

sealed class PrimitiveConverter {
  static Result<String> castString(dynamic value) => const ReflectedPrimitiveString(anotations: []).convertOrClone(rawValue: value).cast<String>();
  static Result<int> castInt(dynamic value) => const ReflectedPrimitiveInt(anotations: []).convertOrClone(rawValue: value).cast<int>();
  static Result<double> castDouble(dynamic value) => const ReflectedPrimitiveDouble(anotations: []).convertOrClone(rawValue: value).cast<double>();
  static Result<DateTime> castDateTime(dynamic value) => const ReflectedPrimitiveDatetime(anotations: []).convertOrClone(rawValue: value).cast<DateTime>();
  static Result<bool> castBoolean(dynamic value) => const ReflectedPrimitiveBool(anotations: []).convertOrClone(rawValue: value).cast<bool>();
  static Result<Uint8List> castBinary(dynamic value) => const ReflectedPrimitiveBinary(anotations: []).convertOrClone(rawValue: value).cast<Uint8List>();

  static Result<ReflectedType?> getReflector(Type type) => GetPrimitiveReflector(dartType: type).execute();
  static Result<ReflectedType?> getReflectorByName(String name) => GetPrimitiveReflectorByName(name: name).execute();

  static Result<T> castEnum<T extends Enum>({required List<T> options, required dynamic value}) {
    if (value == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values cannot be valid options'),
      );
    }

    if (value is int) {
      for (final opt in options) {
        if (opt.index == value) {
          return ResultValue(content: opt);
        }
      }
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The option number %1 is not valid', textParts: [value]),
      );
    } else if (value is String) {
      for (final opt in options) {
        if (opt.name == value) {
          return ResultValue(content: opt);
        }
      }
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The option named %1 is not valid', textParts: [value]),
      );
    } else if (value is num) {
      return castEnum<T>(options: options, value: value.toInt());
    } else {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'To select an option, you must enter a number or a name'),
      );
    }
  }
}
