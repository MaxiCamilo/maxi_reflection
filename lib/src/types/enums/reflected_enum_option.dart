class ReflectedEnumOption {
  final List anotations;
  final Enum value;

  int get index => value.index;
  String get name => value.name;

  const ReflectedEnumOption({required this.anotations,  required this.value});
}
