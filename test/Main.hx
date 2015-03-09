import utest.Assert;

import Lodash.*;

class Main {
  static function main() {
    Assert.equals("1", pluck([{ value : "1" }], "value"));
  }
}