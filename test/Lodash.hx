@:jsRequire("lodash-node")
extern class Lodash {
  static function pluck<T>(arr : Array<Dynamic<T>>, field : String) : T;
}