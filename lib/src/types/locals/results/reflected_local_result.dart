import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class ReflectedLocalResult<T> implements ReflectedType {
  static const String typeSerialization = 'Maxi.Result';

  static const String _isOkProperty = 'isOk';
  static const String _contentTypeProperty = 'contentType';
  static const String _contentProperty = 'content';
  static const String _errorProperty = 'error';

  @override
  final List anotations;

  final ReflectionManager? reflectionManager;

  const ReflectedLocalResult({required this.anotations, this.reflectionManager});

  bool get isVoidResult => T == dynamic || T.toString() == 'void';

  @override
  bool get acceptsNull => isVoidResult;

  @override
  Type get dartType => Result<T>;

  @override
  bool get hasDefaultValue => isVoidResult;

  @override
  String get name => typeSerialization;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.maxiClass;

  @override
  Result createNewInstance({ReflectionManager? manager}) {
    if (isVoidResult) {
      return ResultValue(content: voidResult);
    } else {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FixedOration(message: 'It is not possible to generate an empty result reflectivel'),
      );
    }
  }

  @override
  bool isObjectCompatible({required value}) => value is Result<T>;

  @override
  bool isTypeCompatible({required Type type}) => type == Result<T>;

  @override
  bool thisTypeCanConvert({required Type type, ReflectionManager? manager}) =>
      [ResultValue<T>, T, NegativeResult<T>, ExceptionResult<T>, CancelationResult<T>, ErrorData, ControlledFailure, InvalidProperty, Map<String, dynamic>].contains(type);

  @override
  bool thisObjectCanConvert({required rawValue, ReflectionManager? manager}) => (rawValue == null && isVoidResult) || (rawValue != null && thisTypeCanConvert(type: rawValue.runtimeType));

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (isVoidResult && (value == null || value == voidResult)) {
      return ResultValue(content: {ReflectedType.prefixType: typeSerialization, _isOkProperty: true, _contentTypeProperty: 'void', _contentProperty: ''});
    }

    if (value == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    final isOk = (value is Result) ? (value.itsCorrect) : (value is! ErrorData);
    final rawContent = (value is Result) ? (value.itsCorrect ? value.content : value.error) : value;

    final contentFormated = _serializeValue(value: rawContent);
    if (contentFormated.itsFailure) return contentFormated.cast();

    final contentType = contentFormated.content.$1;
    final contentValue = contentFormated.content.$2;

    return ResultValue(content: {ReflectedType.prefixType: typeSerialization, _isOkProperty: isOk, _contentTypeProperty: contentType, (isOk ? _contentProperty : _errorProperty): contentValue});
  }

  Result<(String, dynamic)> _serializeValue({required dynamic value}) {
    final reflectorResult = GetDynamicReflectorByType(dartType: value.runtimeType, reflectionManager: reflectionManager, anotations: anotations).execute();
    if (reflectorResult.itsFailure) return reflectorResult.cast();

    final reflector = reflectorResult.content;
    if (!reflector.thisObjectCanConvert(rawValue: value)) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'It is not possible to serialize content of type %1 for the result', textParts: [value.runtimeType]),
      ).cast();
    }

    final result = reflector.convertOrClone(rawValue: value);
    if (result.itsFailure) return result.cast();

    return ResultValue(content: (reflector.name, result.content));
  }

  @override
  Result<Result<T>> convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      if (isVoidResult) {
        return ResultValue(content: voidResult as Result<T>);
      } else {
        return NegativeResult.controller(
          code: ErrorCode.nullValue,
          message: FixedOration(message: 'Null values are not accepted'),
        );
      }
    }

    if (rawValue is Result<T>) {
      return ResultValue(content: rawValue);
    }

    if (rawValue is T) {
      return ResultValue(content: ResultValue<T>(content: rawValue));
    }

    if (rawValue is ErrorData) {
      return ResultValue(content: NegativeResult(error: rawValue));
    }

    if (rawValue is Map<String, dynamic>) {
      return _parseMapToResult(rawValue);
    } else {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'It\'s not possible to convert the content %1 for a result', textParts: [rawValue.runtimeType]),
      );
    }
  }

  Result<Result<T>> _parseMapToResult(Map<String, dynamic> mapValue) {
    final isOkResult = mapValue.getRequiredValueWithSpecificType<bool>(key: _isOkProperty);
    if (isOkResult.itsFailure) return isOkResult.cast();
    final isOk = isOkResult.content;

    final contentTypeResult = mapValue.getRequiredValueWithSpecificType<String>(key: _contentTypeProperty);
    if (contentTypeResult.itsFailure) return contentTypeResult.cast();
    final contentType = contentTypeResult.content;

    if (isOk) {
      return _parseMapValueToResult(mapValue: mapValue, contentType: contentType);
    } else {
      return _parseMapErrorToResult(mapValue: mapValue, contentType: contentType);
    }
  }

  Result<Result<T>> _parseMapValueToResult({required Map<String, dynamic> mapValue, required String contentType}) {
    if (contentType == 'void') {
      if (isVoidResult) {
        return ResultValue<Result<T>>(content: voidResult as Result<T>);
      } else {
        return NegativeResult.controller(
          code: ErrorCode.nullValue,
          message: FixedOration(message: 'An non-empty result was expected'),
        );
      }
    }

    final contentResult = mapValue.getRequiredValue(key: _contentProperty);
    if (contentResult.itsFailure) return contentResult.cast();

    final contentReflector = GetDynamicReflectorByName(typeName: _contentProperty, anotations: anotations, reflectionManager: reflectionManager).execute();
    if (contentReflector.itsFailure) return contentReflector.cast();

    final valueResult = contentReflector.content.convertOrClone(rawValue: contentResult.content);
    if (valueResult.itsFailure) return valueResult.cast();

    if (valueResult.content is T) {
      return ResultValue<ResultValue<T>>(content: ResultValue<T>(content: valueResult.content as T));
    } else {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'The reflector did not generate a value of type %1, but of type %2', textParts: [T, valueResult.content.runtimeType]),
      );
    }
  }

  Result<Result<T>> _parseMapErrorToResult({required Map<String, dynamic> mapValue, required String contentType}) {
    final errorContentResult = mapValue.getRequiredValue(key: _errorProperty);
    if (errorContentResult.itsFailure) return errorContentResult.cast();

    final errorReflector = ReflectedLocalErrorData(anotations: anotations);
    if (!errorReflector.isErrorTypeName(contentType)) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'The type %1 is not a valid error format', textParts: [contentType]),
      );
    }

    final errorContent = errorReflector.convertOrClone(rawValue: errorContentResult);
    if (errorContent.itsFailure) return errorContent.cast();

    if (errorContent.content is ErrorData) {
      return ResultValue<Result<T>>(content: NegativeResult<T>(error: errorContent.content as ErrorData));
    } else {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'The reflector did not generate a value of type %1, but of type %2', textParts: [ErrorData, errorContent.content.runtimeType]),
      );
    }
  }
}
