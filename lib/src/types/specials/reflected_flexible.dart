import 'dart:developer';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedFlexible with DisposableMixin, InitializableMixin implements ReflectedType {
  final List externalAnotations;
  final ReflectionManager manager;
  final Type realType;

  late ReflectedType _realReflector;

  late List _annotationSet;

  ReflectedFlexible({required this.externalAnotations, required this.manager, required this.realType});

  @override
  bool get acceptsNull => _tryInitialize(function: (x) => x.acceptsNull, defaultValue: false);

  @override
  Type get dartType => _tryInitialize(function: (x) => x.dartType, defaultValue: dynamic);

  @override
  bool get hasDefaultValue => _tryInitialize(function: (x) => x.hasDefaultValue, defaultValue: false);

  @override
  bool checkThatObjectIsCompatible({required value}) => _tryInitialize(function: (x) => x.checkThatObjectIsCompatible(value: value), defaultValue: false);

  @override
  bool checkThatTypeIsCompatible({required Type type}) => _tryInitialize(function: (x) => x.checkThatTypeIsCompatible(type: type), defaultValue: false);

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => _tryInitialize(
    function: (x) => x.checkIfObjectCanBeConverted(rawValue: rawValue, manager: manager ?? this.manager),
    defaultValue: false,
  );

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => _tryInitialize(
    function: (x) => x.checkIfThisTypeCanBeConverted(type: type, manager: manager ?? this.manager),
    defaultValue: false,
  );

  @override
  String get name => _tryInitialize(function: (x) => x.name, defaultValue: '¿?');

  @override
  ReflectedTypeMode get reflectionMode => _tryInitialize(function: (x) => x.reflectionMode, defaultValue: ReflectedTypeMode.unkown);

  @override
  List get anotations => _tryInitialize(function: (x) => _annotationSet, defaultValue: externalAnotations);

  R _tryInitialize<R>({required R Function(ReflectedType x) function, required R defaultValue}) {
    if (isInitialized) {
      return function(_realReflector);
    }

    final initResult = initialize();
    if (initResult.itsCorrect) {
      return function(_realReflector);
    } else {
      log('[ReflectedFlexible] The initialization of the flexible class failed, the error was: ${initResult.error.message}');
      return defaultValue;
    }
  }

  @override
  Result<void> performInitialization() {
    final searchResult = GetDynamicReflectorByType(dartType: realType, anotations: externalAnotations, reflectionManager: manager).execute();
    if (searchResult.itsCorrect) {
      _realReflector = searchResult.content;
      _annotationSet = [...externalAnotations, ..._realReflector.anotations];
      return voidResult;
    } else {
      return searchResult.cast();
    }
  }

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus;

    return _realReflector.convertOrClone(rawValue: rawValue, manager: manager ?? manager);
  }

  @override
  Result createNewInstance({ReflectionManager? manager}) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus;

    return _realReflector.createNewInstance(manager: manager ?? manager);
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus;

    return _realReflector.serialize(value: value, manager: manager ?? manager);
  }

  @override
  void performObjectDiscard() {
    _annotationSet.clear();
  }
}
