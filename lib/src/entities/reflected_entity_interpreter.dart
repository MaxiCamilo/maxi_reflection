import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectedEntityInterpreter<T,R> {
  Result<R> interpretValue({required T values, dynamic template, bool validate = true, ReflectionManager? manager});
}
