import 'dart:convert';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ParseSerializedListToEntity<T> implements SyncFunctionality<List<T>> {
  final ReflectionManager reflectionManager;
  final dynamic rawValue;
  final bool omitEqualList;
  final bool omitDynamicTypes;

  const ParseSerializedListToEntity({required this.reflectionManager, required this.rawValue, this.omitEqualList = false, this.omitDynamicTypes = false});

  const ParseSerializedListToEntity.omitDynamicTypes({required this.reflectionManager, required this.rawValue}) : omitDynamicTypes = true, omitEqualList = true;

  @override
  Result<List<T>> execute() {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'It is not possible to convert a null value to List'),
      );
    } else if (rawValue is List<T> && !omitEqualList) {
      return ResultValue(content: rawValue);
    } else if (rawValue is List) {
      return _parseList(rawValue: rawValue as List);
    } else if (rawValue is Map<String, dynamic>) {
      final objResult = ParseSerializedMapToEntity(serializedMap: rawValue, reflectionManager: reflectionManager).execute();
      if (objResult.itsFailure) return objResult.cast();

      if (objResult.content is T) {
        return ResultValue(content: [objResult.content as T]);
      } else {
        return NegativeResult.controller(
          code: ErrorCode.incorrectFormat,
          message: FlexibleOration(message: 'Its not possible to convert type %1 to List<%2>', textParts: [rawValue.runtimeType.toString(), T.toString()]),
        );
      }
    } else if (rawValue is T) {
      return ResultValue(content: [rawValue]);
    } else if (rawValue is String) {
      final jsonResult = tryFunction(const FixedOration(message: 'It is not possible to decode the JSON string'), () => json.decode(rawValue));
      if (jsonResult.itsFailure) return jsonResult.cast();

      return ParseSerializedListToEntity<T>(reflectionManager: reflectionManager, rawValue: jsonResult.content).execute();
    } else {
      return NegativeResult.controller(
        code: ErrorCode.incorrectFormat,
        message: FlexibleOration(message: 'Its not possible to convert type %1 to List', textParts: [rawValue.runtimeType.toString()]),
      );
    }
  }

  Result<List<T>> _parseList({required List<dynamic> rawValue}) {
    final parsedList = <T>[];

    for (final item in rawValue) {
      if (item is T && (!omitDynamicTypes || T != dynamic)) {
        parsedList.add(item);
        continue;
      }

      late final dynamic parse;

      if (item is Map<String, dynamic>) {
        final objResult = ParseSerializedMapToEntity(serializedMap: item, reflectionManager: reflectionManager).execute();
        if (objResult.itsFailure) return objResult.cast();
        parse = objResult.content;
      } else if (item is String) {
        final jsonResult = tryFunction(const FixedOration(message: 'It is not possible to decode the JSON string'), () => json.decode(item));
        if (jsonResult.itsFailure) return jsonResult.cast();

        final objResult = ParseSerializedMapToEntity(serializedMap: jsonResult.content, reflectionManager: reflectionManager).execute();
        if (objResult.itsFailure) return objResult.cast();
        parse = objResult.content;
      } else {
        final refResult = GetDynamicReflectorByType(dartType: item.runtimeType, reflectionManager: reflectionManager).execute();
        if (refResult.itsFailure) return refResult.cast();

        final objResult = refResult.content.convertOrClone(rawValue: item, manager: reflectionManager);
        if (objResult.itsFailure) return objResult.cast();

        parse = objResult.content;
      }

      if (parse is T) {
        parsedList.add(parse);
      } else {
        return NegativeResult.controller(
          code: ErrorCode.incorrectFormat,
          message: FlexibleOration(message: 'Its not possible to convert type %1 to List<%2>', textParts: [item.runtimeType.toString(), T.toString()]),
        );
      }
    }
    return ResultValue(content: parsedList);
  }
}
