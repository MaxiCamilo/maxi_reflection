import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class TrySerializeUnkownObject implements SyncFunctionality<dynamic> {
  final ReflectionManager reflectionManager;
  final dynamic rawValue;

  const TrySerializeUnkownObject({required this.reflectionManager, required this.rawValue});

  @override
  Result<dynamic> execute() {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'It is not possible to convert a null value to JSON'),
      );
    } else if (rawValue is List) {
      return _parseList(rawValue: rawValue as List);
    } else if (rawValue is Map<String, dynamic>) {
      return _parseMap(rawValue: rawValue as Map<String, dynamic>);
    } else {
      return NegativeResult.controller(
        code: ErrorCode.incorrectFormat,
        message: FlexibleOration(message: 'Its not possible to serialize type %1 to JSON', textParts: [rawValue.runtimeType.toString()]),
      );
    }
  }

  Result<List> _parseList({required List<dynamic> rawValue}) {
    final parsedList = <dynamic>[];

    for (final item in rawValue) {
      final objSerializer = GetDynamicReflectorByType(dartType: item.runtimeType, reflectionManager: reflectionManager).execute();
      if (objSerializer.itsFailure) return objSerializer.cast();

      final itemResult = objSerializer.content.serialize(value: item, manager: reflectionManager);
      if (itemResult.itsFailure) return itemResult.cast();

      parsedList.add(itemResult.content);
    }

    return ResultValue(content: parsedList);
  }

  Result<Map<String, dynamic>> _parseMap({required Map<String, dynamic> rawValue}) {
    final parsedMap = <String, dynamic>{};

    for (final entry in rawValue.entries) {
      final objSerializer = GetDynamicReflectorByType(dartType: entry.value.runtimeType, reflectionManager: reflectionManager).execute();
      if (objSerializer.itsFailure) return objSerializer.cast();

      final itemResult = objSerializer.content.serialize(value: entry.value, manager: reflectionManager);
      if (itemResult.itsFailure) return itemResult.cast();

      parsedMap[entry.key] = itemResult.content;
    }

    return ResultValue(content: parsedMap);
  }
}
