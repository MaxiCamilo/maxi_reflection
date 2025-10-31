import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class CustomConverter {
  bool thisObjectCanConvert({required dynamic rawValue, ReflectionManager? manager});

  Result<dynamic> convertOrClone({required dynamic rawValue, ReflectionManager? manager});
}
