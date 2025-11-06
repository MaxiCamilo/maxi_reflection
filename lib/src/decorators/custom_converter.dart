import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class CustomConverter<T> {
  bool checkIfObjectCanBeConverted({required dynamic rawValue, ReflectionManager? manager});

  Result<T> convertOrClone({required dynamic rawValue, ReflectionManager? manager});
}
