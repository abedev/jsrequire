import utest.Assert;

import Lodash.*;

class Main {
  static function main() {
    var runner = new utest.Runner();
    runner.addCase(new Main());
    utest.ui.Report.create(runner);
    runner.run();
  }

  public function new() {}

  public function testRequire() {
    Assert.equals("1", pluck([{ value : "1" }], "value"));
  }
}