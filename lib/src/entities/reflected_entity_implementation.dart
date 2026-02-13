import 'dart:developer';

import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/src/entities/classes/entity_validator.dart';
import 'package:maxi_reflection/src/entities/classes/reflected_entity_basic_cloner.dart';
import 'package:maxi_reflection/src/entities/classes/reflected_entity_change_primary_key.dart';
import 'package:maxi_reflection/src/entities/classes/reflected_entity_map_interpreter.dart';
import 'package:maxi_reflection/src/logic/first_check_that_object_compatible.dart';
import 'package:maxi_reflection/src/logic/serialize_class_to_map.dart';

class ReflectedEntityImplementation<T> with DisposableMixin, InitializableMixin implements ReflectedType, ReflectedEntity<T> {
  final ReflectionManager manager;

  @override
  final ReflectedClass classReflector;

  @override
  late CustomCloner<T> cloner;

  @override
  late Validator validator;

  @override
  late Oration formalName;

  @override
  late List<ReflectedField> changeableFields;

  @override
  late List<CustomConverter<T>> customConverters;

  @override
  late List<CustomSerializer> customSerializers;

  @override
  bool get acceptsNull => false;

  @override
  List get anotations => classReflector.anotations;

  @override
  bool get hasDefaultValue => classReflector.hasDefaultValue;

  @override
  bool get itHasPrimaryKey => _primaryKey != null;

  @override
  Type get dartType => classReflector.dartType;

  @override
  String get name => classReflector.name;

  late ReflectedField? _primaryKey;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.entityClass;

  ReflectedEntityImplementation({required this.classReflector, required this.manager});

  R _tryInitialize<R>({required R Function() function, required R defaultValue}) {
    if (isInitialized) {
      return function();
    }

    final initResult = initialize();
    if (initResult.itsCorrect) {
      return function();
    } else {
      log('[ReflectedEntityImplementation] The initialization of the reflectedclass failed, the error was: ${initResult.error.message}');
      return defaultValue;
    }
  }

  @override
  Result<void> performInitialization() {
    changeableFields = classReflector.fields.where((x) => !x.readOnly).toList(growable: false);
    customConverters = classReflector.anotations.whereType<CustomConverter<T>>().toList(growable: false);
    customSerializers = classReflector.anotations.whereType<CustomSerializer>().toList(growable: false);

    formalName = Oration.searchOration(
      list: classReflector.anotations,
      defaultOration: FixedOration(message: classReflector.name),
    );
    cloner = classReflector.anotations.selectType<CustomCloner<T>>() ?? ReflectedEntityBasicCloner<T>(reflectedEntity: this);
    validator = EntityValidator(classReflector: classReflector);
    /*
    _mainConstuctor = classReflector.methods.selectItem(
      (x) => x.methodType == ReflectedMethodType.contructor && (x.fixedParameters.isEmpty || x.fixedParameters.every((x) => x.isOptional)) && (x.namedParameters.isEmpty || x.namedParameters.every((x) => !x.isRequired)),
    );*/

    final primaryKeyFields = classReflector.fields.where((x) => x.anotations.any((y) => y == primaryKey)).toList(growable: false);
    if (primaryKeyFields.isEmpty) {
      _primaryKey = null;
    } else {
      if (primaryKeyFields.length > 1) {
        log('[ReflectedEntityImplementation] The entity ${classReflector.name} has more than 1 primary key!');
      }

      _primaryKey = primaryKeyFields.first;
    }

    return voidResult;
  }

  @override
  bool checkThatObjectIsCompatible({required value}) => _tryInitialize(function: () => classReflector.checkThatObjectIsCompatible(value: value), defaultValue: false);

  @override
  bool checkThatTypeIsCompatible({required Type type}) => _tryInitialize(function: () => classReflector.checkThatTypeIsCompatible(type: type), defaultValue: false);

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => _tryInitialize(
    function: () => classReflector.checkIfObjectCanBeConverted(rawValue: rawValue, manager: manager) || customConverters.any((x) => x.checkIfObjectCanBeConverted(rawValue: rawValue, manager: manager ?? this.manager)),
    defaultValue: false,
  );

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => _tryInitialize(
    function: () => classReflector.checkIfThisTypeCanBeConverted(type: type, manager: manager ?? this.manager),
    defaultValue: false,
  );

  @override
  ReflectedEntityInterpreter<Map<String, dynamic>, T> buildMapInterpreter({required bool identifierRequired, required bool zeroIdentifiersAreAccepted, required bool requiredFieldEnable}) {
    return ReflectedEntityMapInterpreter<T>(identifierRequired: identifierRequired, zeroIdentifiersAreAccepted: zeroIdentifiersAreAccepted, requiredFieldEnable: requiredFieldEnable, entityClass: this);
  }

  @override
  CustomSerializer<Map<String, dynamic>> buildMapSerializator({required dynamic rawValue}) {
    return SerializeClassToMap(reflectedClass: classReflector, fields: changeableFields, manager: manager);
  }

  @override
  Result<ReflectedField> getPrimaryKeyField() {
    final isInit = initialize();
    if (isInit.itsFailure) return isInit.cast();

    if (_primaryKey == null) {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'Class %1 does not have a primary key', textParts: [formalName]),
      );
    } else {
      return ResultValue(content: _primaryKey!);
    }
  }

  @override
  Result<int> getPrimaryKey({required item}) {
    final isInit = initialize();
    if (isInit.itsFailure) return isInit.cast();

    final pkField = getPrimaryKeyField();
    if (pkField.itsFailure) return pkField.cast();

    final isValid = FirstCheckThatObjectCompatible(reflectedType: this, object: item, acceptNull: false, manager: manager).execute();
    if (isValid.itsFailure) return isValid.cast();

    final idResult = pkField.content.obtainValue(instance: item);
    if (idResult.itsCorrect) {
      if (idResult.contentType == int) {
        return idResult.cast<int>();
      } else {
        return NegativeResult.controller(
          code: ErrorCode.implementationFailure,
          message: FlexibleOration(message: 'Field %1 did not return a numeric value (as it is the identifier)', textParts: [name]),
        );
      }
    } else {
      return idResult.cast();
    }
  }

  @override
  Result<void> changePrimaryKey({required item, required int newID}) {
    return ReflectedEntityChangePrimaryKey(instance: item, idValue: newID, identifierRequired: true, zeroIdentifiersAreAccepted: true, entityClass: this).execute();
  }

  @override
  Result<T> convertOrClone({required rawValue, ReflectionManager? manager}) {
    final isInit = initialize();
    if (isInit.itsFailure) return isInit.cast();

    for (final conv in customConverters) {
      if (conv.checkIfObjectCanBeConverted(rawValue: rawValue)) {
        return conv.convertOrClone(rawValue: rawValue, manager: manager ?? this.manager);
      }
    }

    if (rawValue == null) {
      return createNewInstance(manager: manager ?? this.manager);
    }

    if (rawValue is T) {
      final cloneResult = cloner.cloneValue(original: rawValue, manager: manager ?? this.manager);

      if (rawValue.runtimeType != T) {
        final validationResult = validator.validateValue(value: cloneResult.content);
        if (validationResult.itsFailure) return validationResult.cast();
      }

      return cloneResult.cast();
    } else if (rawValue is Map<String, dynamic>) {
      final interpretResult = classReflector.convertOrClone(rawValue: rawValue, manager: manager ?? this.manager);
      if (interpretResult.itsFailure) return interpretResult.cast();

      final validationResult = validator.validateValue(value: interpretResult.content);
      if (validationResult.itsFailure) return validationResult.cast();

      return interpretResult.cast();
    } else {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'Entity %1 is not compatible with a value of type %2', textParts: [name, rawValue.runtimeType]),
      );
    }
  }

  @override
  Result<T> createNewInstance({ReflectionManager? manager}) {
    final isInit = initialize();
    if (isInit.itsFailure) return isInit.cast();

    if (classReflector.isInterface) {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'Entity %1 is an interface; it is not possible to create an instance', textParts: [name]),
      );
    }

    return classReflector.createNewInstance(manager: manager ?? this.manager).cast<T>();
    /*

    if (_mainConstuctor == null) {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'Entity %1 does not have a main constructor', textParts: [name]),
      );
    } else {
      final itemResult = _mainConstuctor!.invoke(instance: null, parameters: InvocationParameters.empty);
      if (itemResult.itsCorrect) {
        if (itemResult.contentType == T) {
          return itemResult.cast<T>();
        } else {
          return NegativeResult.controller(
            code: ErrorCode.wrongType,
            message: FlexibleOration(message: 'When creating the object, it was expected to be %1, but %2 was returned', textParts: [T, itemResult.contentType]),
          );
        }
      } else {
        return itemResult.cast();
      }
    }
    */
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    final isInit = initialize();
    if (isInit.itsFailure) return isInit.cast();

    for (final ser in customSerializers) {
      if (ser.thisObjectCanSerialize(rawValue: value, manager: manager ?? this.manager)) {
        return ser.serialize(value: value, manager: manager ?? this.manager);
      }
    }

    final mapSerializer = SerializeClassToMap(reflectedClass: classReflector, fields: changeableFields, manager: manager ?? this.manager);
    if (mapSerializer.thisObjectCanSerialize(rawValue: value)) {
      return mapSerializer.serialize(value: value, manager: manager ?? this.manager);
    } else {
      final convertedResult = convertOrClone(rawValue: value, manager: manager);
      if (convertedResult.itsFailure) return convertedResult.cast();

      if (!checkThatObjectIsCompatible(value: convertedResult.content)) {
        return NegativeResult.controller(
          code: ErrorCode.abnormalOperation,
          message: FlexibleOration(
            message: 'An attempt was made to convert an object of type %1 to %2 for serialization, but it returned an object of type %3',
            textParts: [value.runtimeType, T, convertedResult.content.runtimeType],
          ),
        );
      }

      return serialize(value: convertedResult.content, manager: manager);
    }
  }

  @override
  ReflectedEntity makeAnotherReflector({List<CustomConverter> preferentCustomConverters = const [], List<CustomSerializer> preferentCustomSerializers = const []}) {
    // TODO: implement makeAnotherReflector
    throw UnimplementedError();
  }

  @override
  void performObjectDiscard() {}

  @override
  Result<List<T>> buildEmptyList() {
    final isInit = initialize();
    if (isInit.itsFailure) return isInit.cast();

    return ResultValue(content: <T>[]);
  }
}
