import 'package:maxi_framework/maxi_framework.dart';

abstract interface class Serializer<S, I> {
  Result<S> serializeObject({required dynamic item});

  Result<T> interpret<T>({required S rawValue});

  Result<dynamic> interpretUsingType({required S rawValue, required Type type});

  Result<List<T>> interpretAsList<T>({required S rawValue});

  Result<List> interpretAsListUsingType({required S rawValue, required Type type});
}
