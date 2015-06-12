#!/bin/sh
rm jsrequire.zip 2> /dev/null
zip -r jsrequire.zip hxml src test extraParams.hxml haxelib.json LICENSE README.md -x "*/\.*"
haxelib submit jsrequire.zip
