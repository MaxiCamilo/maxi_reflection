import 'dart:convert';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class JsonSerializer implements Serializer<String, String> {
  final ReflectionManager reflectionManager;

  const JsonSerializer({required this.reflectionManager});

  @override
  Result<String> serializeObject({required item}) {
    if (item == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'It is not possible to convert a null value to JSON'),
      );
    }

    final reflectorResult = GetDynamicReflectorByType(dartType: item.runtimeType, reflectionManager: reflectionManager).execute();
    if (reflectorResult.itsFailure) return reflectorResult.cast();

    final serializationResult = reflectorResult.content.serialize(value: item, manager: reflectionManager);
    if (serializationResult.itsFailure) return serializationResult.cast();

    return volatileFunction(
      error: (ex, st) => NegativeResult.controller(
        code: ErrorCode.incorrectFormat,
        message: FixedOration(message: 'Cannot convert the value to json format'),
      ),
      function: () => json.encode(item),
    );
  }

  static Result parseTextToJson({required String text}) {
    return volatileFunction(
      error: (ex, st) => NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FixedOration(message: 'The text is not a valid JSON'),
      ),
      function: () => json.decode(text),
    );
  }

  @override
  Result<T> interpret<T>({required String rawValue}) {
    final reflectorResult = GetDynamicReflectorByType(dartType: T, reflectionManager: reflectionManager).execute();
    if (reflectorResult.itsFailure) return reflectorResult.cast();

    final jsonResult = parseTextToJson(text: rawValue);
    if (jsonResult.itsFailure) return jsonResult.cast();

    return reflectorResult.content.convertOrClone(rawValue: jsonResult, manager: reflectionManager).cast<T>();
  }

  @override
  Result<List<T>> interpretAsList<T>({required String rawValue}) {
    if (rawValue.isEmpty || rawValue == 'null') return ResultValue(content: <T>[]);

    final reflectorResult = GetDynamicReflectorByType(dartType: T, reflectionManager: reflectionManager).execute();
    if (reflectorResult.itsFailure) return reflectorResult.cast();

    final jsonResult = parseTextToJson(text: rawValue);
    if (jsonResult.itsFailure) return jsonResult.cast();

    if (jsonResult.content is! List) {
      final onlyOneResult = reflectorResult.content.convertOrClone(rawValue: jsonResult.content);
      if (onlyOneResult.itsCorrect) {
        return ResultValue(content: <T>[onlyOneResult.content]);
      } else {
        return NegativeResult(error: jsonResult.error);
      }
    }

    final list = <T>[];

    int i = 1;
    for (final item in jsonResult.content) {
      final newObjectResult = reflectorResult.content.convertOrClone(rawValue: item);
      if (newObjectResult.itsCorrect) {
        list.add(newObjectResult.cast<T>().content);
      } else {
        return NegativeResult.property(
          propertyName: FlexibleOration(message: 'List item %1', textParts: [i]),
          message: newObjectResult.error.message,
        );
      }

      i += 1;
    }

    return ResultValue(content: list);
  }

  @override
  Result<List> interpretAsListUsingType({required String rawValue, required Type type}) {
    if (rawValue.isEmpty || rawValue == 'null') return ResultValue(content: []);

    final reflectorResult = GetDynamicReflectorByType(dartType: type, reflectionManager: reflectionManager).execute();
    if (reflectorResult.itsFailure) return reflectorResult.cast();

    final jsonResult = parseTextToJson(text: rawValue);
    if (jsonResult.itsFailure) return jsonResult.cast();

    if (jsonResult.content is! List) {
      final onlyOneResult = reflectorResult.content.convertOrClone(rawValue: jsonResult.content);
      if (onlyOneResult.itsCorrect) {
        return ResultValue(content: [onlyOneResult.content]);
      } else {
        return NegativeResult(error: jsonResult.error);
      }
    }

    final list = [];

    int i = 1;
    for (final item in jsonResult.content) {
      final newObjectResult = reflectorResult.content.convertOrClone(rawValue: item);
      if (newObjectResult.itsCorrect) {
        list.add(newObjectResult.content);
      } else {
        return NegativeResult.property(
          propertyName: FlexibleOration(message: 'List item %1', textParts: [i]),
          message: newObjectResult.error.message,
        );
      }

      i += 1;
    }

    return ResultValue(content: list);
  }

  @override
  Result interpretUsingType({required String rawValue, required Type type}) {
    final jsonResult = parseTextToJson(text: rawValue);
    if (jsonResult.itsFailure) return jsonResult.cast();

    final reflectorResult = GetDynamicReflectorByType(dartType: type, reflectionManager: reflectionManager).execute();
    if (reflectorResult.itsFailure) return reflectorResult.cast();

    return reflectorResult.content.convertOrClone(rawValue: jsonResult.content, manager: reflectionManager);
  }
}
