/// Where a catalog recipe row came from (JSON asset, local user draft, or cloud).
abstract class RecipeSource {
  static const asset = 'asset';
  static const user = 'user';
  static const remote = 'remote';
}
