define [
  'jquery'
  'underscore'
  'backbone'
  ],
  ($, _, Backbone)->
    Deferred = $.Deferred

    pageobj =
      enter: ->
        console.log "entering", @name
        d = new Deferred()
        d.name = @name + "enter"
        setTimeout (-> d.resolve()), 800
        d.done => console.log "entered", @name
        d.fail => console.log "interrupt enter", @name
      leave: ->
        console.log "leaving", @name
        d = new Deferred()
        d.name = @name + "leave"
        setTimeout (-> d.resolve()), 800
        d.done => console.log "leaved", @name
        d.fail => console.log "interrupt leave", @name
      destroy: ->

    Router = Backbone.Router.extend
      defs: []
      routes:
        '': 'index'
        'post/': 'list'
        'post/:id': 'show'

      index: ->
        console.log "========== url changed :: INDEX"
        @activate _.extend( {name: "index"}, pageobj )

      list: ->
        console.log "========== url changed :: LIST"
        @activate _.extend( {name: "list"}, pageobj )

      show:->
        console.log "========== url changed :: SHOW"
        @activate _.extend( {name: "show"}, pageobj ), arguments, true

      defers: (defer)->
        @defs.push defer
        defer

      activate: (c, args = null, interrupt = false) ->
        @interrupt() if interrupt

        @prevDefer = @prevDefer or new Deferred().resolve()

        defer = @prevDefer.pipe =>
            @defers @prevObj?.leave()
          .pipe =>
            @defers @prevObj?.destroy()
          .pipe =>
            @prevObj = null
            @defers c.enter.apply c, args

        if not defer
          defer = @defers c.enter()

        @prevDefer = defer.pipe =>
          @prevObj = c
          console.log "** #{c.name} activate comlete"

      interrupt: ->
        @defs = _.filter @defs, (i)-> i?.state?() is 'pending'
        console.log "interrupt call", @defs.map (i)-> i.name + ' ' + i.state()
        _.each @defs, (j) -> j.reject()
        @prevDefer = null


     r = new Router()

     Backbone.history.start pushState: false

     setTimeout (-> r.navigate "/post/", true), 1000
     setTimeout (-> r.navigate "/post/1", true), 2000
     setTimeout (-> r.navigate "/", true), 4000

     return r

