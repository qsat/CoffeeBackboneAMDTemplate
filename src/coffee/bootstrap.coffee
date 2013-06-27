requirejs.config
  baseUrl: 'js',
  paths:
    jquery: "components/jquery/jquery"
    underscore: "components/underscore/underscore"
    backbone: "components/backbone/backbone"
  shim:
    backbone:
      deps: ["underscore", "jquery"],
      exports: "Backbone",
    underscore:
      exports: "_"

 require [
   "jquery"
   "app"
   ],
   ($, App) ->
