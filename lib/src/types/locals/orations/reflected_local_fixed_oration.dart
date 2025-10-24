import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedLocalFixedOration implements ReflectedType {
  static const String typeSerialization = 'Maxi.Text.Fix';

  @override
  final List anotations;

  const ReflectedLocalFixedOration({required this.anotations});

  @override
  bool get acceptsNull => false;

  @override
  Type get dartType => FixedOration;

  @override
  bool get hasDefaultValue => true;

  @override
  String get name => typeSerialization;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.maxiClass;

  @override
  Result createNewInstance() => ResultValue(content: const FixedOration(message: ''));

  @override
  bool isObjectCompatible({required value}) => value is FixedOration;

  @override
  bool isTypeCompatible({required Type type}) => type == FixedOration;

  @override
  bool thisTypeCanConvert({required Type type}) => const [FixedOration, FlexibleOration, Oration, Map<String, dynamic>].contains(type);

  @override
  bool thisObjectCanConvert({required rawValue}) => rawValue != null && (rawValue is Oration || thisTypeCanConvert(type: rawValue.runtimeType));

  @override
  Result serialize({required value}) {
    if (value! is Oration) {
      final convertedValue = convertOrClone(rawValue: value);
      if (convertedValue.itsFailure) return convertedValue;

      value = convertedValue.content;
    }

    final text = value as Oration;

    final mapText = <String, dynamic>{'message': text.message, ReflectedType.prefixType: typeSerialization};
    if (text.tokenID.isNotEmpty) {
      mapText['tokenID'] = text.tokenID;
    }

    if (text.contextText.isNotEmpty) {
      mapText['contextText'] = text.contextText;
    }

    return ResultValue(content: mapText);
  }

  @override
  Result convertOrClone({required rawValue}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (rawValue is Oration) {
      return ResultValue(content: FixedOration.clone(rawValue));
    }

    if (rawValue is! Map<String, dynamic>) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FixedOration(message: 'This value cannot be converted to a translatable text'),
      );
    }

    final message = rawValue.getRequiredValueWithSpecificType<String>(key: 'message');
    if (message.itsFailure) return message.cast();

    final tokenID = rawValue.getRequiredValueWithSpecificType<String>(key: 'tokenID', defaultValue: '');
    if (tokenID.itsFailure) return tokenID.cast();

    final contextText = rawValue.getRequiredValueWithSpecificType<String>(key: 'contextText', defaultValue: '');
    if (contextText.itsFailure) return contextText.cast();

    return ResultValue(
      content: FixedOration(message: message.content, tokenID: tokenID.content, contextText: contextText.content),
    );
  }
}
