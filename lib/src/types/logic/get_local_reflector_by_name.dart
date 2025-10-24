import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class GetLocalReflectorByName implements SyncFunctionality<ReflectedType?> {
  final String name;

  final List anotations;

  const GetLocalReflectorByName({required this.name, this.anotations = const []});

  @override
  Result<ReflectedType?> execute() {
    String lowName = name.toLowerCase();

    if (lowName == ReflectedLocalFixedOration.typeSerialization) {
      return ResultValue(content: ReflectedLocalFixedOration(anotations: anotations));
    }

    if (lowName == ReflectedLocalFlexibleOration.typeSerialization) {
      return ResultValue(content: ReflectedLocalFlexibleOration(anotations: anotations));
    }

    if (lowName == ReflectedLocalOration.typeSerialization) {
      return ResultValue(content: ReflectedLocalOration(anotations: anotations));
    }

    //////////////////////////

    if (lowName == ReflectedLocalControlledFailure.typeSerialization) {
      return ResultValue(content: ReflectedLocalControlledFailure(anotations: anotations));
    }

    if (lowName == ReflectedLocalInvalidProperty.typeSerialization) {
      return ResultValue(content: ReflectedLocalInvalidProperty(anotations: anotations));
    }

    if (lowName == ReflectedLocalErrorData.typeSerialization) {
      return ResultValue(content: ReflectedLocalErrorData(anotations: anotations));
    }

    //////////////////////////
    
    
  }
}
