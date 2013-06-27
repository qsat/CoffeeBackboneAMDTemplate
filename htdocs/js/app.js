(function() {
  define(['jquery', 'underscore', 'backbone'], function($, _, Backbone) {
    var Deferred, Router, pageobj, r;
    Deferred = $.Deferred;
    pageobj = {
      enter: function() {
        var d,
          _this = this;
        console.log("entering", this.name);
        d = new Deferred();
        d.name = this.name + "enter";
        setTimeout((function() {
          return d.resolve();
        }), 800);
        d.done(function() {
          return console.log("entered", _this.name);
        });
        return d.fail(function() {
          return console.log("interrupt enter", _this.name);
        });
      },
      leave: function() {
        var d,
          _this = this;
        console.log("leaving", this.name);
        d = new Deferred();
        d.name = this.name + "leave";
        setTimeout((function() {
          return d.resolve();
        }), 800);
        d.done(function() {
          return console.log("leaved", _this.name);
        });
        return d.fail(function() {
          return console.log("interrupt leave", _this.name);
        });
      },
      destroy: function() {}
    };
    Router = Backbone.Router.extend({
      defs: [],
      routes: {
        '': 'index',
        'post/': 'list',
        'post/:id': 'show'
      },
      index: function() {
        console.log("========== url changed :: INDEX");
        return this.activate(_.extend({
          name: "index"
        }, pageobj));
      },
      list: function() {
        console.log("========== url changed :: LIST");
        return this.activate(_.extend({
          name: "list"
        }, pageobj));
      },
      show: function() {
        console.log("========== url changed :: SHOW");
        return this.activate(_.extend({
          name: "show"
        }, pageobj), arguments, true);
      },
      defers: function(defer) {
        this.defs.push(defer);
        return defer;
      },
      activate: function(c, args, interrupt) {
        var defer,
          _this = this;
        if (args == null) {
          args = null;
        }
        if (interrupt == null) {
          interrupt = false;
        }
        if (interrupt) {
          this.interrupt();
        }
        this.prevDefer = this.prevDefer || new Deferred().resolve();
        defer = this.prevDefer.pipe(function() {
          var _ref;
          return _this.defers((_ref = _this.prevObj) != null ? _ref.leave() : void 0);
        }).pipe(function() {
          var _ref;
          return _this.defers((_ref = _this.prevObj) != null ? _ref.destroy() : void 0);
        }).pipe(function() {
          _this.prevObj = null;
          return _this.defers(c.enter.apply(c, args));
        });
        if (!defer) {
          defer = this.defers(c.enter());
        }
        return this.prevDefer = defer.pipe(function() {
          _this.prevObj = c;
          return console.log("** " + c.name + " activate comlete");
        });
      },
      interrupt: function() {
        this.defs = _.filter(this.defs, function(i) {
          return (i != null ? typeof i.state === "function" ? i.state() : void 0 : void 0) === 'pending';
        });
        console.log("interrupt call", this.defs.map(function(i) {
          return i.name + ' ' + i.state();
        }));
        _.each(this.defs, function(j) {
          return j.reject();
        });
        return this.prevDefer = null;
      }
    });
    r = new Router();
    Backbone.history.start({
      pushState: false
    });
    setTimeout((function() {
      return r.navigate("/post/", true);
    }), 1000);
    setTimeout((function() {
      return r.navigate("/post/1", true);
    }), 2000);
    setTimeout((function() {
      return r.navigate("/", true);
    }), 4000);
    return r;
  });

}).call(this);
