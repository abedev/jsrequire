package jsrequire;

import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Type;
import haxe.macro.ExprTools;

class JSRequire {
  macro public static function npmInstall(?createPackageJson : Bool) {
    installNpmDependencies(createPackageJson);
    return macro null;
  }

  public static function installNpmDependencies(?createPackageJson : Bool) {
    Context.onGenerate(function(types : Array<Type>) {
      var modules = [];
      for(type in types) switch type {
        case TInst(t, _):
          var s = t.toString();
          // skip node natives
          if(s.substring(0, 8) == "js.node.")
            continue;
          var meta = t.get().meta;
          if(!meta.has(":jsRequire"))
            continue;
          var module = ExprTools.toString(meta.extract(":jsRequire")[0].params[0]);
          if(module.substring(0, 1) != '"')
            Context.error('Class definition contains an invalid module value', t.get().pos);
          modules.push(module.substring(1, module.length - 1));
        case _:
      }
      if(modules.length > 0) {
        ensurePackageJson(null != createPackageJson && createPackageJson);
        var installedDependencies = getDependencies();
        for(module in modules) {
          if(!Reflect.hasField(installedDependencies, module))
            installNpmModule(module);
        }
      }

      return;
    });
  }

  static function ensurePackageJson(generate : Bool) {
    if(sys.FileSystem.exists("package.json")) return;
    if(generate) {
      Sys.command('npm', ['init', '.']);
    }
    if(!sys.FileSystem.exists("package.json")) {
      Context.error("This project does not contain the file `package.json` please generate one manually or using `npm init .`", Context.currentPos());
    }
  }

  static function getDependencies() : Dynamic<String> {
    var json = haxe.Json.parse(sys.io.File.getContent("package.json")),
        dependencies : Dynamic<String> = json.dependencies;
    return null != dependencies ? dependencies : {};
  }

  static function installNpmModule(module : String)
    Sys.command('npm', ['install', '--save', module]);
}