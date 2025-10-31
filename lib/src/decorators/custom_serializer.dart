import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class CustomSerializer<T> {
  bool thisObjectCanSerialize({required dynamic rawValue, ReflectionManager? manager});

  Result<T> serialize({required dynamic value, ReflectionManager? manager});
}
