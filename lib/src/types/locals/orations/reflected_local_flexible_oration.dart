import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedLocalFlexibleOration implements ReflectedType {
  static const String typeSerialization = 'Maxi.Text.Flex';

  @override
  final List anotations;

  const ReflectedLocalFlexibleOration({required this.anotations});

  @override
  bool get acceptsNull => false;

  @override
  Type get dartType => FlexibleOration;

  @override
  bool get hasDefaultValue => true;

  @override
  String get name => typeSerialization;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.maxiClass;

  @override
  Result createNewInstance({ReflectionManager? manager}) => ResultValue(
    content: const FlexibleOration(message: '', textParts: []),
  );

  @override
  bool checkThatObjectIsCompatible({required value}) => value is FlexibleOration;

  @override
  bool checkThatTypeIsCompatible({required Type type}) => type == FlexibleOration;

  @override
  bool checkIfThisTypeCanBeConverted({required Type type, ReflectionManager? manager}) => const [FixedOration, FlexibleOration, Oration, Map<String, dynamic>].contains(type);

  @override
  bool checkIfObjectCanBeConverted({required rawValue, ReflectionManager? manager}) => rawValue != null && (rawValue is Oration || checkIfThisTypeCanBeConverted(type: rawValue.runtimeType));

  @override
  Result serialize({required value, ReflectionManager? manager}) {
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

    if (text.textParts.isNotEmpty) {
      mapText['textParts'] = text.textParts.map((x) => x.toString()).toList();
    }

    return ResultValue(content: mapText);
  }

  @override
  Result convertOrClone({required rawValue, ReflectionManager? manager}) {
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

    final rawContent = rawValue.getRequiredValueWithSpecificType<List>(key: 'contextText', defaultValue: []);
    if (rawContent.itsFailure) return rawContent.cast();
    final content = rawContent.content.map((e) => e.toString()).toList();

    return ResultValue(
      content: FlexibleOration(message: message.content, tokenID: tokenID.content, contextText: contextText.content, textParts: content),
    );
  }
}
