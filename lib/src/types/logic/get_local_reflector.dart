import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class GetLocalReflector implements SyncFunctionality<ReflectedType?> {
  final Type dartType;
  final List anotations;

  const GetLocalReflector({required this.dartType, this.anotations = const []});

  @override
  Result<ReflectedType?> execute() {
    if (dartType == FixedOration) {
      return ResultValue(content: ReflectedLocalFixedOration(anotations: anotations));
    }

    if (dartType == FlexibleOration) {
      return ResultValue(content: ReflectedLocalFlexibleOration(anotations: anotations));
    }

    if (dartType == Oration) {
      return ResultValue(content: ReflectedLocalOration(anotations: anotations));
    }

    //////////////////////////

    if (dartType == ControlledFailure) {
      return ResultValue(content: ReflectedLocalControlledFailure(anotations: anotations));
    }

    if (dartType == InvalidProperty) {
      return ResultValue(content: ReflectedLocalInvalidProperty(anotations: anotations));
    }

    if (dartType == ErrorData) {
      return ResultValue(content: ReflectedLocalErrorData(anotations: anotations));
    }

    //////////////////////////
    
    if (dartType == Result) {
      return ResultValue(content: ReflectedLocalErrorData(anotations: anotations));
    }

    //////////////////////////

    if (dartType.toString().last == '?') {
      final realTypeName = dartType.toString().removeLastCharacters(1);
      final searchByName = GetLocalReflectorByName(name: realTypeName, anotations: anotations).execute();
      if (searchByName.itsFailure || searchByName.content == null) return searchByName;
      return ResultValue(
        content: ReflectedNullable(dartType: dartType, anotations: anotations, reflectedType: searchByName.content!),
      );
    }

    return ResultValue(content: null);
  }
}
