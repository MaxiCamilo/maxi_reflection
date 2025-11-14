import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';
import 'package:test/test.dart';

enum _SuperEnum { first, second, third }

class _SuperEntity {
  static String secretField = ':3';
  static String secretMethod() => ':0';

  @primaryKey
  int identifier = 0;
  String name = '';
  int age = 0;

  String greet(String personName, {bool isWelcome = false}) {
    print('Hi $personName! I am $name');
    if (isWelcome) {
      print('You are welcome');
    } else {
      print('Now please go');
    }

    return 'jejeje';
  }

  _SuperEntity();
}

class _SuperEntityReflector extends ReflectedClassImplementation<_SuperEntity> {
  _SuperEntityReflector({
    required super.manager,
    super.hasBaseConstructor = true,
    super.anotations = const [],
    super.extendsType,
    super.isConstClass = false,
    super.isInterface = false,
    super.packagePrefix = 'super',
    super.traits = const [],
    super.typeName = '_SuperEntity',
  });

  @override
  Result createNewInstance({ReflectionManager? manager}) {
    return ResultValue(content: _SuperEntity());
  }

  @override
  List<ReflectedField> buildNativeFields({required ReflectionManager manager}) {
    return [
      ReflectedFieldInstance<_SuperEntity, int>(
        anotations: [primaryKey],
        isFinal: false,
        isLate: false,
        isStatic: false,
        name: 'identifier',
        reflectedType: const ReflectedPrimitiveInt(),
        setter: (_SuperEntity? instance, int value) => instance!.identifier = value,
        getter: (_SuperEntity? instance) => instance!.identifier,
      ),
      ReflectedFieldInstance<_SuperEntity, String>(
        anotations: [],
        isFinal: false,
        isLate: false,
        isStatic: true,
        name: 'secretField',
        reflectedType: ReflectedFlexible(externalAnotations: anotations, manager: manager, realType: String),
        setter: (_SuperEntity? instance, String value) => _SuperEntity.secretField = value,
        getter: (_SuperEntity? instance) => _SuperEntity.secretField,
      ),
    ];
  }

  @override
  List<ReflectedMethod> buildNativeMethods({required ReflectionManager manager}) {
    return [
      ReflectedMethodInstance<_SuperEntity, String>(
        anotations: anotations,
        name: 'greet',
        isStatic: false,
        methodType: ReflectedMethodType.method,
        fixedParameters: [
          ReflectedFixedParameter(
            anotations: [],
            reflectedType: ReflectedFlexible(externalAnotations: const [], manager: manager, realType: String),
            name: 'personName',
            index: 0,
            isOptional: false,
            defaultValue: null,
          ),
        ],
        namedParameters: [
          ReflectedNamedParameter(
            anotations: const [],
            reflectedType: ReflectedFlexible(externalAnotations: const [], manager: manager, realType: bool),
            name: 'isWelcome',
            isRequired: false,
            defaultValue: false,
          ),
        ],
        reflectedType: const ReflectedPrimitiveString(),
        invoker: (instance, parameters) => instance!.greet(parameters.firts<String>(), isWelcome: parameters.named<bool>('isWelcome')),
      ),

      ReflectedMethodInstance<_SuperEntity, String>(
        anotations: anotations,
        name: 'secretMethod',
        isStatic: true,
        methodType: ReflectedMethodType.method,
        fixedParameters: const [],
        namedParameters: const [],
        reflectedType: ReflectedFlexible(externalAnotations: anotations, manager: manager, realType: String),
        invoker: (instance, parameters) => _SuperEntity.secretMethod(),
      ),
    ];
  }
}

const _superEnum = ReflectedEnum(
  anotations: [],
  dartType: _SuperEnum,
  options: [
    ReflectedEnumOption(anotations: [], value: _SuperEnum.first),
    ReflectedEnumOption(anotations: [], value: _SuperEnum.second),
    ReflectedEnumOption(anotations: [], value: _SuperEnum.third),
  ],
);

class _SuperBook implements ReflectionBook {
  const _SuperBook();

  @override
  String get prefixName => 'super';

  @override
  List<ReflectedEnum> buildEnums({required ReflectionManager manager}) {
    return const [_superEnum];
  }

  @override
  List<ReflectedClass> buildClassReflectors({required ReflectionManager manager}) {
    return [_SuperEntityReflector(manager: manager)];
  }

  @override
  List<ReflectedType> buildOtherReflectors({required ReflectionManager manager}) {
    return [];
  }
}

void main() {
  group('Reflection Test', () {
    final reflector = ReflectionLibrary(books: const [_SuperBook()]);

    setUp(() {});

    test('Create an object and change id', () {
      final entity = reflector.searchEntityReflected<_SuperEntity>().content;
      final newObject = entity.createNewInstance().content;

      entity.classReflector.changeValue(name: 'identifier', instance: newObject, value: 21).content;

      final id = entity.classReflector.obtainValue(name: 'identifier', instance: newObject).content;
      print(id);

      entity.changePrimaryKey(item: newObject, newID: 999).content;
      print(entity.getPrimaryKey(item: newObject));
    });

    test('Call local method', () {
      final entity = reflector.searchEntityReflected<_SuperEntity>().content;
      final newObject = entity.createNewInstance().content;

      newObject.name = 'Maxi';

      final methodResult = entity.classReflector
          .invoke(
            instance: newObject,
            name: 'greet',
            parameters: InvocationParameters(fixedParameters: ['Seba']),
          )
          .content;

      print(methodResult);
    });

    test('Call static method', () {
      final entity = reflector.searchEntityReflected<_SuperEntity>().content;
      entity.classReflector.invoke(instance: null, name: 'secretMethod', parameters: InvocationParameters.emptry);
    });

    test('Call static field', () {
      final entity = reflector.searchEntityReflected<_SuperEntity>().content;

      entity.classReflector.changeValue(name: 'secretField', instance: null, value: 123456);

      print(entity.classReflector.obtainValue(instance: null, name: 'secretField').content);
    });

    test('Test enums', () {});
  });
}
