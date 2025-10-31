import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

class ReflectedPrimitiveDatetime implements ReflectedType {
  static final DateTime _initial = DateTime.fromMillisecondsSinceEpoch(0);
  @override
  final List anotations;

  const ReflectedPrimitiveDatetime({this.anotations = const []});

  @override
  String get name => 'DateTime';

  @override
  bool get acceptsNull => false;

  @override
  bool get hasDefaultValue => true;

  @override
  Type get dartType => DateTime;

  @override
  ReflectedTypeMode get reflectionMode => ReflectedTypeMode.primitive;

  @override
  bool isObjectCompatible({required value}) => value is String;

  @override
  bool isTypeCompatible({required Type type}) => type == String;

  @override
  bool thisTypeCanConvert({required Type type, ReflectionManager? manager}) => const [DateTime, int, String, double, num].contains(type);

  @override
  bool thisObjectCanConvert({required rawValue, ReflectionManager? manager}) => rawValue != null && thisTypeCanConvert( type: rawValue.runtimeType);

  @override
  Result createNewInstance({ReflectionManager? manager}) {
    return ResultValue(content: _initial);
  }

  @override
  Result convertOrClone({required rawValue, bool isLocal = true, ReflectionManager? manager}) {
    if (rawValue == null) {
      return NegativeResult.controller(
        code: ErrorCode.nullValue,
        message: FixedOration(message: 'Null values are not accepted'),
      );
    }

    if (rawValue is DateTime) {
      return ResultValue(content: isLocal ? rawValue.toLocal() : rawValue.toUtc());
    }

    if (rawValue is num) {
      final numDate = volatileFunction(
        error: (ex, st) => NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FixedOration(message: 'It\'s not possible to convert the numeric value to a date'),
        ),
        function: () => DateTime.fromMillisecondsSinceEpoch(rawValue.toInt(), isUtc: true),
      );
      if (numDate.itsFailure) return numDate;
      final content = numDate.content as DateTime;
      return ResultValue(content: isLocal ? content.toLocal() : content.toUtc());
    }

    if (rawValue is String) {
      final stringDate = volatileFunction(
        error: (ex, st) => NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FixedOration(message: 'It\'s not possible to convert the text value to a date (Does not comply with the Iso8601 format)'),
        ),
        function: () => DateTime.parse(rawValue),
      );
      if (stringDate.itsFailure) return stringDate;
      final content = stringDate.content as DateTime;
      return ResultValue(content: isLocal ? content.toLocal() : content.toUtc());
    }

    return NegativeResult.controller(
      code: ErrorCode.wrongType,
      message: FlexibleOration(message: 'Cannot convert value of type %1 to a date and time', textParts: [rawValue.runtimeType]),
    );
  }

  @override
  Result serialize({required value, ReflectionManager? manager}) {
    if (value is DateTime) {
      return ResultValue(content: value.toUtc().millisecondsSinceEpoch);
    } else {
      final convert = convertOrClone(rawValue: value);
      if (convert.itsFailure) return convert;
      final content = convert.content as DateTime;
      return ResultValue(content: content.toUtc().millisecondsSinceEpoch);
    }
  }
}
