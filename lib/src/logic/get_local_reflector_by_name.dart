import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';
import 'package:maxi_reflection/maxi_reflection_ext.dart';

class GetLocalReflectorByName implements SyncFunctionality<ReflectedType?> {
  final String name;
  final ReflectionManager? manager;

  final List anotations;

  const GetLocalReflectorByName({required this.name, this.manager, this.anotations = const []});

  @override
  Result<ReflectedType?> execute() {
    String lowName = name.toLowerCase();

    if (lowName == ReflectedLocalFixedOration.typeSerialization || lowName == 'FixedOration') {
      return ResultValue(content: ReflectedLocalFixedOration(anotations: anotations));
    }

    if (lowName == ReflectedLocalFlexibleOration.typeSerialization || lowName == 'FlexibleOration') {
      return ResultValue(content: ReflectedLocalFlexibleOration(anotations: anotations));
    }

    if (lowName == ReflectedLocalOration.typeSerialization || lowName == 'Oration') {
      return ResultValue(content: ReflectedLocalOration(anotations: anotations));
    }

    //////////////////////////

    if (lowName == ReflectedLocalControlledFailure.typeSerialization || lowName == 'ControlledFailure') {
      return ResultValue(content: ReflectedLocalControlledFailure(anotations: anotations));
    }

    if (lowName == ReflectedLocalInvalidProperty.typeSerialization || lowName == 'InvalidProperty') {
      return ResultValue(content: ReflectedLocalInvalidProperty(anotations: anotations));
    }

    if (lowName == ReflectedLocalErrorData.typeSerialization || lowName == 'ErrorData') {
      //ErrorData
      return ResultValue(content: ReflectedLocalErrorData(anotations: anotations));
    }

    //////////////////////////

    if (lowName == ReflectedLocalResult.typeSerialization || lowName == 'Result' || lowName.startsWith('Result<')) {
      return ResultValue(content: ReflectedLocalDynamicResult(anotations: anotations));
    }

    /////////////////////////

    return ResultValue(content: null);
  }
}
