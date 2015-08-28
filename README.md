# jsrequire
Simplifies managing NPM libraries in haxe projects

## Quick Start

Add the following to your hxml:

```
--macro jsrequire.JSRequire.npmInstall(false)
```

Dependencies defined with `@:jsRequire('libname')` will be automatically installed if omitted. The `false` flag states that
a `package.json` file is not required. Change it to `true` if you have one or you want to create one when the compile process
is started.
