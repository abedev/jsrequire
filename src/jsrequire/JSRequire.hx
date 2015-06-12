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
        var hasPackageJson = ensurePackageJson(null != createPackageJson && createPackageJson);
        var installedDependencies = getDependencies(hasPackageJson);
        for(module in modules) {
          if(!Reflect.hasField(installedDependencies, module))
            installNpmModule(module, hasPackageJson);
        }
      }

      return;
    });
  }

  static function ensurePackageJson(generate : Bool) {
    if(sys.FileSystem.exists("package.json")) return true;
    if(generate) {
      Sys.command('npm', ['init', '.']);
    }
    return sys.FileSystem.exists("package.json");
  }

  static function getDependencies(hasPackageJson : Bool) : Dynamic<String> {
    if(hasPackageJson) {
      return getDependenciesFromPackageJson();
    } else {
      return getDependenciesFromNodeModules();
    }
  }

  static function getDependenciesFromPackageJson() : Dynamic<String> {
    var content = sys.io.File.getContent("package.json"),
        json = try haxe.Json.parse(content) catch(e : Dynamic) {
          return throw 'Unable to parse package.json: \n\n$content\n\n$e';
        },
        dependencies : Dynamic<String> = json.dependencies;
    return null != dependencies ? dependencies : {};
  }

  static function getDependenciesFromNodeModules() : Dynamic<String> {
    var dir = "node_modules";
    if(!sys.FileSystem.exists(dir))
      return {};
    var ob = {};
    for(file in sys.FileSystem.readDirectory(dir)) {
      if(file == "." || file == "..") continue;
      Reflect.setField(ob, file, "*");
    }
    return ob;
  }

  static function installNpmModule(module : String, hasPackageJson : Bool)
    if(hasPackageJson)
      Sys.command('npm', ['install', '--save', module]);
    else
      Sys.command('npm', ['install', module]);
}
