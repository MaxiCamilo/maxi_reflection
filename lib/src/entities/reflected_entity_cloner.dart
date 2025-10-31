import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_reflection/maxi_reflection.dart';

abstract interface class ReflectedEntityCloner<T> {
  Result<T> cloneValue({required T original, ReflectionManager? manager});
}
