import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedTypedList<T> implements ReflectedType {
  @override
  final List anotations;

  const ReflectedTypedList({required this.anotations});

  @override
  bool get acceptsNull => false;

  @override
  Type get dartType => List<T>;

  @override
  bool get hasDefaultValue => true;

  @override
  String get name => 'List<$T>';

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.list;

  @override
  Result createNewInstance({ReflectionManager? manager}) => ResultValue(content: <T>[]);

  @override
  bool checkThatTypeIsCompatible({required Type type}) => type == List<T>;

  @override
  bool checkThatObjectIsCompatible({required value}) => value is List<T>;

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => rawValue is List<T> || rawValue is T || rawValue is Iterable;

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => type == (List<T>) || type == T || type == List || (type == Iterable<T>) || (type == Iterable);

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (rawValue is Iterable) {
      return _cloneList(oldList: rawValue, manager: manager);
    } else if (rawValue is T) {
      final itemResult = _cloneItem(actualReflector: null, item: rawValue, manager: manager);
      if (itemResult.itsFailure) return itemResult.cast();
      return ResultValue(content: [itemResult.content.$2]);
    } else {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FlexibleOration(message: 'Cannot convert object to a list of type %1', textParts: [T]),
      );
    }
  }

  Result _cloneList({required Iterable oldList, ReflectionManager? manager}) {
    final newList = <T>[];
    int position = 1;
    ReflectedType? actualReflector;

    for (final item in oldList) {
      final convResult = _cloneItem(actualReflector: actualReflector, item: item, manager: manager);

      if (convResult.itsCorrect) {
        actualReflector = convResult.content.$1;
        newList.add(convResult.content.$2);
      } else {
        return NegativeResult.property(
          propertyName: FlexibleOration(message: 'Item #%1', textParts: [position]),
          message: convResult.error.message,
        );
      }

      position += 1;
    }

    return ResultValue(content: newList);
  }

  Result<(ReflectedType, T)> _cloneItem({dynamic item, ReflectionManager? manager, ReflectedType? actualReflector}) {
    if (item == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'The list contains a null value; that type of value is not accepted'),
      );
    }

    if (actualReflector == null || !actualReflector.checkThatObjectIsCompatible(value: item)) {
      final searchReflector = GetDynamicReflectorByType(dartType: item.runtimeType, reflectionManager: manager).execute();
      if (searchReflector.itsFailure) return searchReflector.cast();

      if (searchReflector.content.reflectionMode == ReflectedTypeMode.unkown) {
        return NegativeResult.controller(
          code: ErrorCode.wrongType,
          message: FixedOration(message: 'The reflector for a list item was not found'),
        );
      } else {
        actualReflector = searchReflector.content;
      }
    }

    final convertResult = actualReflector.convertOrClone(rawValue: item);
    if (convertResult.itsCorrect) {
      if (convertResult.content is T) {
        return ResultValue(content: (actualReflector, (convertResult.content as T)));
      } else {
        return NegativeResult.controller(
          code: ErrorCode.implementationFailure,
          message: FlexibleOration(message: 'The reflector has not generated an item of type %1', textParts: [T]),
        );
      }
    } else {
      return NegativeResult.controller(code: ErrorCode.implementationFailure, message: convertResult.error.message);
    }
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'The list contains a null value; that type of value is not accepted'),
      );
    }

    if (value is Iterable) {
      int i = 1;
      final convertedValue = [];

      ReflectedType? actualReflector;

      for (final item in value) {
        if (actualReflector == null || !actualReflector.checkThatObjectIsCompatible(value: item)) {
          final searchReflector = GetDynamicReflectorByType(dartType: item.runtimeType, reflectionManager: manager).execute();
          if (searchReflector.itsFailure) return searchReflector.cast();

          if (searchReflector.content.reflectionMode == ReflectedTypeMode.unkown) {
            return NegativeResult.controller(
              code: ErrorCode.wrongType,
              message: FixedOration(message: 'The reflector for a list item was not found'),
            );
          } else {
            actualReflector = searchReflector.content;
          }
        }

        final convertResult = actualReflector.serialize(value: value);
        if (convertResult.itsCorrect) {
          convertedValue.add(convertResult.content);
          i += 1;
        } else {
          return NegativeResult.property(
            propertyName: FlexibleOration(message: 'Item #%1', textParts: [i]),
            message: convertResult.error.message,
          );
        }
      }

      return ResultValue(content: convertedValue);
    } else if (value is T) {
      final searchReflector = GetDynamicReflectorByType(dartType: value.runtimeType, reflectionManager: manager).execute();
      if (searchReflector.itsFailure) return searchReflector.cast();

      final itemResult = searchReflector.content.serialize(value: value);
      if (itemResult.itsFailure) return itemResult.cast();
      return ResultValue(content: [itemResult.content]);
    } else {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FlexibleOration(message: 'Cannot convert object to a list of type %1', textParts: [T]),
      );
    }
  }
}
