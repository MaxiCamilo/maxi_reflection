import 'dart:developer';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/src/entities/reflected_entity_implementation.dart';
import 'package:maxi_reflection/src/logic/serialize_class_to_map.dart';
import 'package:meta/meta.dart';

abstract class ReflectedClassImplementation<T extends Object> with DisposableMixin, InitializableMixin implements ReflectedClass {
  @override
  final List anotations;

  @override
  final Type? extendsType;

  @override
  final bool isConstClass;

  @override
  final bool isInterface;

  @override
  final String packagePrefix;

  @override
  final List<Type> traits;

  final bool hasBaseConstructor;

  final String typeName;

  final ReflectionManager manager;

  final _allMethods = <ReflectedMethod>[];
  final _allFields = <ReflectedField>[];

  final _contructors = <ReflectedMethod>[];

  final _nativeMethods = <ReflectedMethod>[];
  final _nativeFields = <ReflectedField>[];

  @protected
  List<ReflectedMethod> buildNativeMethods({required ReflectionManager manager});

  @protected
  List<ReflectedField> buildNativeFields({required ReflectionManager manager});

  ReflectedClassImplementation({
    required this.anotations,
    required this.extendsType,
    required this.isConstClass,
    required this.isInterface,
    required this.packagePrefix,
    required this.traits,
    required this.typeName,
    required this.manager,
    required this.hasBaseConstructor,
  });

  @override
  bool get acceptsNull => false;

  @override
  bool get hasDefaultValue => !isInterface && hasBaseConstructor;

  @override
  String get name => typeName;

  @override
  Type get dartType => T;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.classType;

  @override
  String get typeSignature => '$packagePrefix.$name';

  @override
  bool checkThatObjectIsCompatible({required value}) => value != null && value.runtimeType == T;

  @override
  bool checkThatTypeIsCompatible({required Type type}) => type == T;

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => rawValue != null && hasDefaultValue && rawValue is Map<String, dynamic>;

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => hasDefaultValue && type == Map<String, dynamic>;

  @override
  List<ReflectedField> get fields => _tryInitialize(function: () => _allFields, defaultValue: _nativeFields);

  @override
  List<ReflectedMethod> get methods => _tryInitialize(function: () => _allMethods, defaultValue: _nativeMethods);

  R _tryInitialize<R>({required R Function() function, required R defaultValue}) {
    if (isInitialized) {
      return function();
    }

    final initResult = initialize();
    if (initResult.itsCorrect) {
      return function();
    } else {
      log('[$runtimeType] The initialization of the reflectedclassimplementation failed, the error was: ${initResult.error.message}');
      return defaultValue;
    }
  }

  @override
  Result<void> performInitialization() {
    _allMethods.clear();
    _allFields.clear();
    _contructors.clear();
    _nativeMethods.clear();
    _nativeFields.clear();

    _nativeMethods.addAll(buildNativeMethods(manager: manager));
    _nativeFields.addAll(buildNativeFields(manager: manager));

    _allMethods.addAll(_nativeMethods);
    _allFields.addAll(_nativeFields);

    if (extendsType != null) {
      final foundExtendReflector = manager.trySearchClassByType(extendsType!);
      if (foundExtendReflector.itsFailure) return foundExtendReflector.cast();

      if (foundExtendReflector.content != null) {
        _allMethods.addAll(foundExtendReflector.content!.methods);
        _allFields.addAll(foundExtendReflector.content!.fields);
      }
    }

    for (final oneTrait in traits) {
      final foundTraitdReflector = manager.trySearchClassByType(oneTrait);
      if (foundTraitdReflector.itsFailure) return foundTraitdReflector.cast();

      if (foundTraitdReflector.content != null) {
        _allMethods.addAll(foundTraitdReflector.content!.methods);
        _allFields.addAll(foundTraitdReflector.content!.fields);
      }
    }

    _contructors.addAll(_nativeMethods.where((x) => x.methodType == ReflectedMethodType.contructor));

    return voidResult;
  }

  @override
  Result<ReflectedEntity<T>> buildEntityReflector({required ReflectionManager manager}) {
    return ResultValue(
      content: ReflectedEntityImplementation<T>(classReflector: this, manager: manager),
    );
  }

  @override
  Result<void> changeValue({required String name, required instance, required value}) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    final foundField = _allFields.selectItem((x) => x.name == name);
    if (foundField == null) {
      return NegativeResult.controller(
        code: ErrorCode.nonExistent,
        message: FlexibleOration(message: 'The reflected class %1 does not have a field named %2', textParts: [typeName, name]),
      );
    }

    return foundField.changeValue(instance: instance, value: value);
  }

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    if (isInterface) {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'The class %1 is an interface; it\'s not possible to instantiate it', textParts: [name]),
      );
    }

    if (!hasBaseConstructor) {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'Class %1 has no base constructor', textParts: [name]),
      );
    }

    if (rawValue is T) {
      return _clone(value: rawValue, manager: manager);
    } else if (rawValue is Map<String, dynamic>) {
      return _parseMapToObject(mapValue: rawValue, manager: manager);
    } else {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'It is not possible to convert value %1 to class %2', textParts: [rawValue.runtimeType, name]),
      );
    }
  }

  Result<T> _clone({required T value, ReflectionManager? manager}) {
    final newObjectResult = createNewInstance(manager: manager);
    if (newObjectResult.itsFailure) return newObjectResult.cast();
    final newObject = newObjectResult.content;

    for (final field in fields.where((x) => !x.readOnly)) {
      final propValue = field.obtainValue(instance: value);
      if (propValue.itsFailure) return propValue.cast();

      final setResult = field.changeValue(instance: value, value: propValue.content);
      if (setResult.itsFailure) return setResult.cast();
    }

    return Result<T>.adapt(newObject);
  }

  Result<T> _parseMapToObject({required Map<String, dynamic> mapValue, ReflectionManager? manager}) {
    final newObjectResult = createNewInstance(manager: manager);
    if (newObjectResult.itsFailure) return newObjectResult.cast();
    final newObject = newObjectResult.content;

    for (final field in fields.where((x) => !x.readOnly)) {
      if (mapValue.containsKey(field.name)) {
        final setResult = field.changeValue(instance: newObject, value: mapValue[field.name]);
        if (setResult.itsFailure) return setResult.cast();
      }
    }

    return Result<T>.adapt(newObject);
  }

  @override
  Result invoke({required instance, required String name, required InvocationParameters parameters, bool tryAccommodateParameters = false}) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    final foundMethod = _allMethods.selectItem((x) => x.name == name);
    if (foundMethod == null) {
      return NegativeResult.controller(
        code: ErrorCode.nonExistent,
        message: FlexibleOration(message: 'The reflected class %1 does not have a mathod named %2', textParts: [typeName, name]),
      );
    }

    return tryAccommodateParameters ? foundMethod.accommodateAndInvoke(instance: instance, parameters: parameters) : foundMethod.invoke(instance: instance, parameters: parameters);
  }

  @override
  Result<T> invokeContructor({String name = '', InvocationParameters parameters = InvocationParameters.empty}) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    if (name.isEmpty || name == typeName) {
      final baseContructor = _contructors.selectItem((x) => x.name == typeName);

      if (baseContructor == null) {
        return NegativeResult.controller(
          code: ErrorCode.nonExistent,
          message: FlexibleOration(message: 'Class %1 does not contain a base constructor', textParts: [typeName]),
        );
      } else {
        return baseContructor.invoke(instance: null, parameters: parameters).cast<T>();
      }
    }

    final foundFactory = _contructors.selectItem((x) => x.name == name);
    if (foundFactory == null) {
      return NegativeResult.controller(
        code: ErrorCode.nonExistent,
        message: FlexibleOration(message: 'The class %1 does not contain a constructor named %2', textParts: [typeName, name]),
      );
    }

    return foundFactory.invoke(instance: null, parameters: parameters).cast<T>();
  }

  @override
  Result obtainValue({required String name, required instance}) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    final foundField = _allFields.selectItem((x) => x.name == name);
    if (foundField == null) {
      return NegativeResult.controller(
        code: ErrorCode.nonExistent,
        message: FlexibleOration(message: 'The reflected class %1 does not have a field named %2', textParts: [typeName, name]),
      );
    }

    return foundField.obtainValue(instance: instance);
  }

  @override
  Result<Map<String, dynamic>> serialize({required value, ReflectionManager? manager}) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    return SerializeClassToMap(reflectedClass: this, fields: fields, manager: manager).serialize(value: value);
  }

  @override
  void performObjectDiscard() {
    _allMethods.clear();
    _allFields.clear();
    _contructors.clear();
    _nativeMethods.clear();
    _nativeFields.clear();
  }
}
