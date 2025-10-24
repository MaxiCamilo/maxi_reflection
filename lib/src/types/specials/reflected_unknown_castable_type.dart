import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedUnknownCastableType<T> implements ReflectedType {
  @override
  final List anotations;

  const ReflectedUnknownCastableType({required this.anotations});

  @override
  bool get acceptsNull => false;

  @override
  Type get dartType => T;

  @override
  bool get hasDefaultValue => false;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.unkown;

  @override
  String get name => T.toString();

  @override
  bool isObjectCompatible({required value}) => value is T;

  @override
  bool isTypeCompatible({required Type type}) => type == T;

  @override
  bool thisObjectCanConvert({required rawValue}) => false;

  @override
  bool thisTypeCanConvert({required Type type}) => false;

  @override
  Result createNewInstance() => NegativeResult.controller(
    code: ErrorCode.implementationFailure,
    message: FlexibleOration(message: 'It\'s not possible to create a new instance of %1, because it was not reflected', textParts: [dartType]),
  );

  @override
  Result serialize({required value}) => NegativeResult.controller(
    code: ErrorCode.implementationFailure,
    message: FlexibleOration(message: 'It\'s not possible to serialize the value of type %1, because it wasn\'t reflected', textParts: [dartType]),
  );

  @override
  Result convertOrClone({required rawValue}) => NegativeResult.controller(
    code: ErrorCode.implementationFailure,
    message: FlexibleOration(message: 'It\'s not possible to convert or clone the value of type %1, because it wasn\'t reflected', textParts: [dartType]),
  );
}
