var activations = [];

var activate = function (scope) {
  if (!scope) scope = document;
  activations.each(function (fun) { fun.run(scope); });
};

window.addEvent('domready', function(){
  activate();
});

var fadeNotices = function () {
  $$('div.notice, div.error').fade('out');
};

activations.push(function (scope) {
  fadeNotices.delay(3000);
});





// some useful extensions

var top_z = null;
var topZ = function () {
  if (top_z) return top_z;
  $$('*').each(function (element) {
    z = parseInt(element.getStyle('z-index'), 10);
    if (z > top_z) top_z = z;
  });
  return top_z;
};

Element.implement({
  bringForward: function () {
    top_z = topZ() + 1;
    this.setStyle('z-index', top_z);
  }
});

var unevent = function (e) {
  if (e) {
    new Event(e).stop();
    if (e.target) e.target.blur();
  }
};









// and some functionality that I seem to use a lot

var Bouncer = new Class({
  initialize: function (element) { 
    this.container = element;
    this.delay_before_hiding = 750;
    this.shower = null;
    this.hider = null;
    this.timer = null;
    this.when_hiding = {};
    this.when_showing = {};
    this.setShownAndHiddenStates();
    this.setTriggers();
    this.afterInitialize();
    this.visible = false;
  },
  setShownAndHiddenStates: function () {
    this.when_hiding = {'opacity' : 0};
    this.when_showing = {'opacity' : 1};
  },
  setTriggers: function () {
    this.container.addEvent('mouseenter', this.show.bindWithEvent(this));
    this.container.addEvent('mouseleave', this.hideSoon.bindWithEvent(this));
  },
  lazyGetShower: function () { if (!this.shower) this.getShower(); return this.shower; },
  getShower: function () { this.shower = new Fx.Morph(this.container, {duration: this.durationIn(), transition: this.transitionIn(), onComplete : this.afterShowing.bind(this)}); },
  lazyGetHider: function () { if (!this.hider) this.getHider(); return this.hider; },
  getHider: function () { this.hider = new Fx.Morph(this.container, {duration: this.durationOut(), transition: this.transitionOut(), onComplete : this.afterHiding.bind(this)}); },
  transitionIn: function () { return Fx.Transitions.Cubic.easeOut; },
  transitionOut: function () { return Fx.Transitions.Cubic.easeOut; },
  durationIn: function () { return 'short'; },
  durationOut: function () { return 'long'; },
  show: function (e) {
    unevent(e);
    this.interrupt();
    this.beforeShowing();
    if (this.lazyGetShower()) this.lazyGetShower().start(this.when_showing);
  },
  hide: function (e) {
    unevent(e);
    this.interrupt();
    this.beforeHiding();
    if (this.lazyGetHider()) this.lazyGetHider().start(this.when_hiding);
  },
  hideSoon: function (e) {
    unevent(e);
    this.timer = this.hide.bind(this).delay(this.delay_before_hiding);
  },
  interrupt: function () {
    $clear(this.timer);
    if (this.hider) this.hider.cancel();
    if (this.shower) this.shower.cancel();
  },
  afterInitialize: function () {},
  beforeShowing: function () { this.container.bringForward(); this.visible = true; },
  afterShowing: function () { },
  beforeHiding: function () { },
  afterHiding: function () { this.visible = false;  }
});
