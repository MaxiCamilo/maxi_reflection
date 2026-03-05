# Maxi Reflection

A robust and thread-safe runtime reflection library for Dart that provides comprehensive metadata support, enabling dynamic class introspection, invocation, data manipulation, and serialization.

## Overview

Maxi Reflection is a production-ready reflection library designed to overcome the limitations of Dart's native reflection capabilities. While Dart provides `dart:mirrors` (which is inactive and unstable) and other community packages like `reflection` (which suffers from multithreading issues), Maxi Reflection offers a stable, thread-safe alternative with powerful features for modern Dart applications.

## Why Maxi Reflection?

### Problems with Existing Solutions

- **dart:mirrors**: Dart's native reflection library is marked as inactive, unstable, and not supported in Flutter or Dart compiled to JavaScript
- **Other reflection packages**: Existing alternatives have critical issues, particularly with multithreading support, making them unsuitable for concurrent applications
- **Limited functionality**: Most solutions don't provide comprehensive serialization and validation capabilities

### Maxi Reflection Advantages

✅ **Thread-safe**: Designed from the ground up to work seamlessly in multithreaded environments  
✅ **Stable API**: Production-ready with a consistent interface  
✅ **Comprehensive metadata**: Full access to class structure, fields, methods, and decorators at runtime  
✅ **Dynamic invocation**: Call methods and modify fields dynamically  
✅ **Built-in serialization**: JSON serialization with custom converter support  
✅ **Automatic validation**: Validate entities with decorator-based rules  
✅ **Type-safe**: Leverages Dart's type system while providing dynamic capabilities  
✅ **Flutter compatible**: Works perfectly with Flutter and all Dart compilation targets  

## Features

### Core Capabilities

- **Class Introspection**: Examine class structure, fields, methods, and annotations at runtime
- **Dynamic Method Invocation**: Call methods with flexible parameter handling
- **Field Access & Modification**: Read and write field values dynamically
- **Entity Reflection**: Specialized support for data entities with primary keys and validation
- **Custom Converters**: Define custom type conversion logic
- **Custom Serializers**: Create custom serialization strategies
- **Automatic Validation**: Validate entity fields with decorators
- **Enum Support**: Full reflection support for enumerations
- **Type System Integration**: Seamless integration with Dart's type system

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  maxi_reflection:
    path: ../maxi_reflection  # Adjust path as needed
```

Or install from git:

```yaml
dependencies:
  maxi_reflection:
    git:
      url: https://github.com/your-org/maxi_reflection.git
      ref: main
```

## Quick Start

### 1. Define Your Entity

```dart
import 'package:maxi_reflection/maxi_reflection.dart';

class User {
  @primaryKey
  int id = 0;
  
  @requiredField
  String name = '';
  
  @requiredField
  String email = '';
  
  int age = 0;

  String greet(String personName, {bool formal = false}) {
    if (formal) {
      return 'Good day, $personName. I am $name.';
    }
    return 'Hi $personName! I\'m $name.';
  }

  User();
}
```

### 2. Create a Reflector

```dart
class UserReflector extends ReflectedClassImplementation<User> {
  UserReflector({required super.manager}) : super(
    typeName: 'User',
    packagePrefix: 'myapp',
  );

  @override
  Result createNewInstance({ReflectionManager? manager}) {
    return ResultValue(content: User());
  }

  @override
  List<ReflectedField> buildNativeFields({required ReflectionManager manager}) {
    return [
      ReflectedFieldInstance<User, int>(
        name: 'id',
        anotations: [primaryKey],
        reflectedType: const ReflectedPrimitiveInt(),
        setter: (User? instance, int value) => instance!.id = value,
        getter: (User? instance) => instance!.id,
        isFinal: false,
        isStatic: false,
        isLate: false,
      ),
      ReflectedFieldInstance<User, String>(
        name: 'name',
        anotations: [requiredField],
        reflectedType: const ReflectedPrimitiveString(),
        setter: (User? instance, String value) => instance!.name = value,
        getter: (User? instance) => instance!.name,
        isFinal: false,
        isStatic: false,
        isLate: false,
      ),
      // ... more fields
    ];
  }

  @override
  List<ReflectedMethod> buildNativeMethods({required ReflectionManager manager}) {
    return [
      ReflectedMethodInstance<User, String>(
        name: 'greet',
        isStatic: false,
        methodType: ReflectedMethodType.method,
        reflectedType: const ReflectedPrimitiveString(),
        fixedParameters: [
          ReflectedFixedParameter(
            name: 'personName',
            index: 0,
            isOptional: false,
            reflectedType: const ReflectedPrimitiveString(),
            anotations: [],
            defaultValue: null,
          ),
        ],
        namedParameters: [
          ReflectedNamedParameter(
            name: 'formal',
            isRequired: false,
            defaultValue: false,
            reflectedType: const ReflectedPrimitiveBool(),
            anotations: [],
          ),
        ],
        invoker: (instance, parameters) => instance!.greet(
          parameters.first<String>(), 
          formal: parameters.named<bool>('formal'),
        ),
        anotations: [],
      ),
    ];
  }
}
```

### 3. Register and Use

```dart
// Create a reflection book
class MyAppBook implements ReflectionBook {
  const MyAppBook();

  @override
  String get prefixName => 'myapp';

  @override
  List<ReflectedClass> buildClassReflectors({required ReflectionManager manager}) {
    return [UserReflector(manager: manager)];
  }

  @override
  List<ReflectedEnum> buildEnums({required ReflectionManager manager}) => [];

  @override
  List<ReflectedType> buildOtherReflectors({required ReflectionManager manager}) => [];
}

// Use reflection
void main() {
  final manager = ReflectionLibrary(books: [const MyAppBook()]);
  
  // Get entity reflector
  final reflectorResult = manager.searchEntityReflected<User>();
  final reflector = reflectorResult.content;
  
  // Create instance
  final userResult = reflector.createNewInstance();
  final user = userResult.content as User;
  
  // Set values dynamically
  final classReflector = reflector.classReflector;
  classReflector.changeValue(name: 'name', instance: user, value: 'Alice');
  classReflector.changeValue(name: 'age', instance: user, value: 30);
  
  // Invoke method dynamically
  final result = classReflector.invoke(
    instance: user,
    name: 'greet',
    parameters: InvocationParameters(positional: ['Bob'], named: {'formal': true}),
  );
  
  print(result.content); // "Good day, Bob. I am Alice."
}
```

## Core Concepts

### Reflection Manager

The `ReflectionManager` is the central registry for all reflected types. It allows you to:

- Search for entity reflectors by type
- Search for class reflectors by type or name
- Register custom reflectors
- Manage reflection books

### Reflected Types

Maxi Reflection supports various reflected types:

- **ReflectedClass**: Represents a class with fields, methods, and metadata
- **ReflectedEntity**: Specialized reflection for data entities with validation
- **ReflectedEnum**: Represents enumeration types
- **ReflectedPrimitive**: Built-in types (int, String, bool, etc.)
- **ReflectedFlexible**: Dynamic type resolution

### Reflection Books

A `ReflectionBook` is a collection of related reflectors grouped by a prefix. Books organize your reflectors into logical modules:

```dart
class MyAppBook implements ReflectionBook {
  @override
  String get prefixName => 'myapp';
  
  @override
  List<ReflectedClass> buildClassReflectors({required ReflectionManager manager}) {
    return [/* your reflectors */];
  }
  
  @override
  List<ReflectedEnum> buildEnums({required ReflectionManager manager}) {
    return [/* your enum reflectors */];
  }
  
  @override
  List<ReflectedType> buildOtherReflectors({required ReflectionManager manager}) {
    return [/* custom type reflectors */];
  }
}
```

### Decorators

Maxi Reflection provides several built-in decorators:

- `@reflect`: Marks a class for reflection
- `@primaryKey`: Identifies the primary key field of an entity
- `@requiredField`: Marks a field as required for validation
- `@customConverter`: Specifies custom type conversion logic
- `@customSerializer`: Defines custom serialization behavior
- `@customCloner`: Provides custom cloning logic

## Advanced Features

### Custom Converters

Create custom converters for complex type transformations:

```dart
class DateTimeConverter implements CustomConverter<DateTime> {
  @override
  bool checkIfObjectCanBeConverted({required dynamic rawValue, ReflectionManager? manager}) {
    return rawValue is String || rawValue is DateTime;
  }

  @override
  Result<DateTime> convertOrClone({required dynamic rawValue, ReflectionManager? manager}) {
    if (rawValue is DateTime) {
      return ResultValue(content: rawValue);
    }
    if (rawValue is String) {
      try {
        return ResultValue(content: DateTime.parse(rawValue));
      } catch (e) {
        return NegativeResult.controller(
          code: ErrorCode.conversionFailure,
          message: 'Invalid date format: $rawValue',
        );
      }
    }
    return NegativeResult.controller(
      code: ErrorCode.invalidValue,
      message: 'Cannot convert to DateTime',
    );
  }
}
```

### Custom Serializers

Define custom serialization strategies:

```dart
class UserSerializer implements CustomSerializer<Map<String, dynamic>> {
  @override
  bool checkIfObjectCanBeSerialized({required dynamic item, ReflectionManager? manager}) {
    return item is User;
  }

  @override
  Result<Map<String, dynamic>> serialize({required dynamic item, ReflectionManager? manager}) {
    final user = item as User;
    return ResultValue(content: {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'age': user.age,
    });
  }
}
```

### Entity Validation

Use the built-in validation system:

```dart
final entityReflector = manager.searchEntityReflected<User>().content;

// Entities with @requiredField decorators are automatically validated
final interpreter = entityReflector.buildMapInterpreter(
  identifierRequired: false,
  zeroIdentifiersAreAccepted: true,
  requiredFieldEnable: true,
);

final result = interpreter.interpret({
  'name': 'Alice',
  // 'email' is missing - validation will fail if marked as @requiredField
});
```

### JSON Serialization

Built-in JSON serialization support:

```dart
// Serialize an entity to JSON
final serializer = JsonSerializer(manager: manager);
final jsonResult = serializer.serialize(item: user);
final json = jsonResult.content;

// Deserialize from JSON
final deserializeResult = serializer.deserialize<User>(json);
final restoredUser = deserializeResult.content;
```

## Multithreading Support

Maxi Reflection is designed to work seamlessly in multithreaded environments:

```dart
import 'package:maxi_thread/maxi_thread.dart';

// Use reflection in a separate thread
final thread = Thread.create(() {
  final manager = ReflectionLibrary(books: [const MyAppBook()]);
  final reflector = manager.searchEntityReflected<User>().content;
  // ... perform reflection operations
});
```

## Best Practices

1. **Use Reflection Books**: Organize your reflectors into logical books by module or feature
2. **Leverage Code Generation**: Consider using `maxi_reflection_constructor` for automatic reflector generation
3. **Cache Reflectors**: Store frequently used reflectors to avoid repeated lookups
4. **Type Safety**: Use generic type parameters whenever possible for compile-time type checking
5. **Error Handling**: Always check `Result` objects for errors before accessing content
6. **Validation**: Use decorators like `@requiredField` to enforce data integrity
7. **Custom Converters**: Create custom converters for domain-specific types

## Integration with Other Maxi Packages

Maxi Reflection integrates seamlessly with other packages in the Maxi ecosystem:

- **maxi_framework**: Core utilities and error handling
- **maxi_thread**: Multithreading support
- **maxi_reflection_constructor**: Automatic code generation for reflectors
- **maxi_sql**: Database operations with automatic entity mapping
- **maxi_sqlite**: SQLite integration with reflection-based ORM

## Limitations

- Manual reflector creation can be verbose (use code generation tools)
- Reflection has a slight performance overhead compared to direct access
- Reflectors must be registered before use

## Contributing

Contributions are welcome! This is a personal library by Maximiliano Camilo, but suggestions and improvements are appreciated.

## License

See the LICENSE file for details.

## Related Packages

- [maxi_framework](../maxi_framework): Core framework with utilities
- [maxi_reflection_constructor](../maxi_reflection_constructor): Code generation for reflectors
- [maxi_thread](../maxi_thread): Multithreading support
- [maxi_sql](../maxi_sql): SQL abstraction layer
- [maxi_sqlite](../maxi_sqlite): SQLite implementation

## Examples

More examples can be found in the `test/` directory.

---

**Version**: 1.0.0  
**Author**: Maximiliano Camilo
