/// Enum representing the different todo filter types.
enum FilterType {
  all('all'),
  active('active'),
  completed('completed');

  final String value;

  const FilterType(this.value);
}
