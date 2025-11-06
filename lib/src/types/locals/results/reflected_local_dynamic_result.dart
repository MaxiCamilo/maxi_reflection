import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class ReflectedLocalDynamicResult implements ReflectedType {
  static const String typeSerialization = 'Maxi.Result';

  static const String _isOkProperty = 'isOk';
  static const String _contentTypeProperty = 'contentType';
  static const String _contentProperty = 'content';
  static const String _errorProperty = 'error';

  @override
  final List anotations;

  const ReflectedLocalDynamicResult({required this.anotations});

  @override
  bool get acceptsNull => true;

  @override
  Type get dartType => Result;

  @override
  bool get hasDefaultValue => true;

  @override
  String get name => typeSerialization;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.maxiClass;

  @override
  bool checkThatObjectIsCompatible({required value}) => value is Result;

  @override
  bool checkThatTypeIsCompatible({required Type type}) => type == Result;

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => true;

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => true;

  @override
  Result createNewInstance({ReflectionManager? manager}) => voidResult;

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return ResultValue(content: voidResult);
    }

    if (rawValue is Result) {
      return ResultValue(content: rawValue);
    }

    if (rawValue is ErrorData) {
      return ResultValue(content: NegativeResult(error: rawValue));
    }

    if (rawValue is Map<String, dynamic>) {
      return _parseMapToResult(rawValue);
    }

    return ResultValue(content: ResultValue(content: rawValue));
  }

  Result<Result> _parseMapToResult(Map<String, dynamic> mapValue) {
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

  Result<Result> _parseMapValueToResult({required Map<String, dynamic> mapValue, required String contentType, ReflectionManager? manager}) {
    if (contentType == 'void') {
      return ResultValue(content: voidResult);
    }

    final contentResult = mapValue.getRequiredValue(key: _contentProperty);
    if (contentResult.itsFailure) return contentResult.cast();

    final contentReflector = GetDynamicReflectorByName(typeName: _contentProperty, anotations: anotations, reflectionManager: manager).execute();
    if (contentReflector.itsFailure) return contentReflector.cast();

    final valueResult = contentReflector.content.convertOrClone(rawValue: contentResult.content);
    if (valueResult.itsFailure) return valueResult.cast();

    return ResultValue(content: ResultValue(content: valueResult.content));
  }

  Result<Result> _parseMapErrorToResult({required Map<String, dynamic> mapValue, required String contentType}) {
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
      return ResultValue<Result>(content: NegativeResult(error: errorContent.content as ErrorData));
    } else {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'The reflector did not generate a value of type %1, but of type %2', textParts: [ErrorData, errorContent.content.runtimeType]),
      );
    }
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value == null) {
      return ResultValue(content: {ReflectedType.prefixType: typeSerialization, _isOkProperty: true, _contentTypeProperty: 'void', _contentProperty: ''});
    }

    if (value is Result) {
      return serialize(value: value.content, manager: manager);
    }

    final reflectorResult = GetDynamicReflectorByType(dartType: dartType, anotations: anotations, reflectionManager: manager).execute();
    if (reflectorResult.itsFailure) return reflectorResult.cast();

    final reflector = reflectorResult.content;
    if (reflector.reflectionMode == ReflectedTypeMode.unkown) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'Cannot serialize object of type %1 because it has no assigned reflector', textParts: [value.runtimeType]),
      );
    }

    return reflector.serialize(value: value);
  }
}
