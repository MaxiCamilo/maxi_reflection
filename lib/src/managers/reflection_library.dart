import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectionLibrary with DisposableMixin, InitializableMixin implements ReflectionManager {
  final List<ReflectionBook> books;

  final Set<ReflectedType> _reflectedTypes = {};
  final Set<ReflectedClass> _reflectedClasses = {};
  final Set<ReflectedEnum> _reflectedEnums = {};
  final Set<ReflectedType> _customReflectors = {};

  final List<ReflectedEntity> _entityReflectors = [];

  ReflectionLibrary({required this.books});

  @override
  List<ReflectedType> get customReflectors => _customReflectors.toList(growable: false);

  @override
  List<ReflectedEnum> get reflectedEnums => _reflectedEnums.toList(growable: false);

  @override
  List<ReflectedType> get reflectedTypes => _reflectedTypes.toList(growable: false);

  @override
  bool addCustomReflector(ReflectedType newReflector) {
    return !_customReflectors.add(newReflector);
  }

  @override
  Result<void> performInitialization() {
    for (final book in books) {
      final generatedOtherReflectors = book.buildOtherReflectors(manager: this);
      _reflectedTypes.addAll(generatedOtherReflectors);

      final generatedClassReflectors = book.buildClassReflectors(manager: this);
      _reflectedTypes.addAll(generatedClassReflectors);
      _reflectedClasses.addAll(generatedClassReflectors);

      final generatedEnums = book.buildEnums(manager: this);
      _reflectedEnums.addAll(generatedEnums);
    }

    return voidResult;
  }

  @override
  Result<ReflectedEntity?> trySearchEntityReflected(Type type) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    final lookupEntityReflector = _entityReflectors.whereType<ReflectedEntity>().selectItem((x) => x.dartType == type);
    if (lookupEntityReflector != null) {
      return ResultValue(content: lookupEntityReflector);
    }

    final hasClass = _reflectedClasses.selectItem((x) => x.dartType == type);
    if (hasClass == null) {
      return const ResultValue(content: null);
    }

    final newEntityEngine = hasClass.buildEntityReflector(manager: this);
    if (newEntityEngine.itsFailure) return newEntityEngine.cast();

    _entityReflectors.add(newEntityEngine.content);
    return newEntityEngine;
  }

  @override
  Result<ReflectedEntity<T>> searchEntityReflected<T>() {
    final newEntityReflector = trySearchEntityReflected(T);
    if (newEntityReflector.itsFailure) return newEntityReflector.cast();
    if (newEntityReflector.content == null) {
      return NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FlexibleOration(message: 'Class reflector for %1 not found', textParts: [T]),
      );
    }

    return newEntityReflector.cast<ReflectedEntity<T>>();
  }

  @override
  Result<ReflectedType?> trySearchTypeByName(String name) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    final hasCustom = _customReflectors.selectItem((x) => x.name == name);
    if (hasCustom != null) return ResultValue(content: hasCustom);

    final hasEnum = _reflectedEnums.selectItem((x) => x.name == name);
    if (hasEnum != null) return ResultValue(content: hasEnum);

    final hasEntity = _entityReflectors.selectItem((x) => x.name == name || x.classReflector.typeSignature == name);
    if (hasEntity != null) return ResultValue(content: hasEntity);

    final hasClass = _reflectedClasses.selectItem((x) => x.name == name || x.typeSignature == name);
    if (hasClass != null) {
      final newEntityResult = hasClass.buildEntityReflector(manager: this);
      if (newEntityResult.itsCorrect) {
        _entityReflectors.add(newEntityResult.content);
      }

      return newEntityResult;
    }

    final hasType = _reflectedTypes.selectItem((x) => x.name == name);
    if (hasType != null) return ResultValue(content: hasType);

    return const ResultValue(content: null);
  }

  @override
  Result<ReflectedType?> trySearchTypeByType(Type type) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    final hasCustom = _customReflectors.selectItem((x) => x.dartType == type);
    if (hasCustom != null) return ResultValue(content: hasCustom);

    final hasEnum = _reflectedEnums.selectItem((x) => x.dartType == type);
    if (hasEnum != null) return ResultValue(content: hasEnum);

    final hasEntity = _entityReflectors.selectItem((x) => x.checkThatTypeIsCompatible(type: type));
    if (hasEntity != null) return ResultValue(content: hasEntity);

    final hasClass = _reflectedClasses.selectItem((x) => x.checkThatTypeIsCompatible(type: type));
    if (hasClass != null) {
      final newEntityResult = hasClass.buildEntityReflector(manager: this);
      if (newEntityResult.itsCorrect) {
        _entityReflectors.add(newEntityResult.content);
      }

      return newEntityResult;
    }

    final hasType = _reflectedTypes.selectItem((x) => x.dartType == type);
    if (hasType != null) return ResultValue(content: hasType);

    return const ResultValue(content: null);
  }

  @override
  Result<ReflectedClass?> trySearchClassByName(String name) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    return ResultValue(content: _reflectedClasses.selectItem((x) => x.typeSignature == name));
  }

  @override
  Result<ReflectedClass?> trySearchClassByType(Type type) {
    final initStatus = initialize();
    if (initStatus.itsFailure) return initStatus.cast();

    return ResultValue(content: _reflectedClasses.selectItem((x) => x.dartType == type));
  }

  @override
  void performObjectDiscard() {
    _reflectedTypes.clear();
    _reflectedEnums.clear();
    _customReflectors.clear();
    _entityReflectors.clear();
  }
}
