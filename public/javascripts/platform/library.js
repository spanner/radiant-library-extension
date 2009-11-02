var ImageList = new Class({
  initialize: function (element) { 
    this.container = element;
    this.contents = [];
    this.container.getElements('li').each(function (li) { this.contents.push(new ImageListItem(li, this)); }, this);
  },
  itemAfter: function (item) {
    var pos = this.contents.indexOf(item);
    after = (pos == -1 || pos == this.contents.length-1) ? this.contents[0] : this.contents[pos+1];
    return after;
  },
  itemBefore: function (item) {
    var pos = this.contents.indexOf(item);
    var before = null;
    before = (pos == -1 || pos == 0) ? this.contents[this.contents.length-1] : this.contents[pos-1];
    return before;
  }
});

var ImageListItem = new Class({
  initialize: function (element, list) { 
    this.ready = false;
    this.list = list;
    this.container = element;
    this.image = this.container.getElement('img');
    this.link = this.container.getElement('a');
    this.title = this.image.get('alt');
    this.caption = this.image.get('title');
    this.src = this.image.get('src');
    this.asset_id = this.image.get('id').replace('asset_', '');
    this.zoom = new Asset.image(this.link.get('href'), {onload: this.makeReady.bind(this)});
    this.image.set('title', null);
    this.captioner = null;
    this.zoomer = null;
    this.container.addEvent('mouseover', this.showCaption.bindWithEvent(this));
    this.container.addEvent('mouseout', this.hideCaption.bindWithEvent(this));
    this.image.fade(0.7);
  },
  showCaption: function (e) {
    unevent(e);
    this.getCaptioner().show();
  },
  hideCaption: function (e) {
    unevent(e);
    captioner.hideSoon();
  },
  getCaptioner: function () {
    return captioner.adopt(this);
  },
  showZoom: function (e) {
    unevent(e);
    this.getZoomer().show();
  },
  getZoomer: function () {
    return zoomer.adopt(this);
  },
  makeReady: function () {
    this.image.fade(1);
    this.link.addEvent('click', this.showZoom.bindWithEvent(this));
    this.ready = true;
  },
  nextItem: function () {
    return this.list.itemAfter(this);
  },
  previousItem: function () {
    return this.list.itemBefore(this);
  }
});

var Captioner = new Class({
  Extends: Bouncer,
  initialize: function (item) {
    this.item = item;
    this.parent(new Element('div', {'class' : 'captioner'}));
    this.title = new Element('h4').inject(this.container);
    this.caption = new Element('p').inject(this.container);
    this.container.inject(document.body);
    this.delay_before_hiding = 250;
  },
  setShownAndHiddenStates: function () {
    this.when_hiding = {'opacity' : 0};
    this.when_showing = {'opacity' : 1};
  },
  adopt: function (item) {
    this.item = item;
    return this;
  },
  display: function (item) {
    this.adopt(item);
    this.show();
  },
  setTriggers: function () {
    this.container.addEvent('mouseenter', this.hideSoon.bindWithEvent(this));
    this.container.addEvent('click', this.hide.bindWithEvent(this));
  },
  beforeShowing: function () {
    this.container.set('tween', {'duration' : 'short'});
    this.place();
    this.fill();
  },
  place: function () {
    var itemat = this.item.image.getCoordinates();
    this.container.setStyles({
      left: itemat['left'],
      top: itemat['top'] + itemat['height'] + 6,
      width: itemat['width'],
      height: itemat['height'] + 4
    });
  },
  fill: function () {
    this.title.set('text', this.item.title);
    this.caption.set('text', this.item.caption);
  }
});

var Zoomer = new Class({
  Extends: Bouncer,
  setTriggers: function () { this.container.addEvent('click', this.hide.bindWithEvent(this)); },
  initialize: function (item) {
    this.parent(new Element('div', {'class' : 'zoomer'}));
    this.image = new Element('img', {'class' : 'zoomed'}).inject(this.container);
    this.caption_holder = new Element('div', {'class' : 'caption'}).inject(this.container);

    this.closer = new Element('a', {'class' : 'close', 'href' : '#'}).set('text', 'close').inject(this.caption_holder);
    this.title = new Element('h4').inject(this.caption_holder);
    this.caption = new Element('p').inject(this.caption_holder);
    this.text_links = new Element('p', {'class' : 'text_links'}).inject(this.caption_holder);
    new Element('a', {'class': 'left', 'href': '#'}).set('html', '&larr; previous').inject(this.text_links);
    new Element('a', {'class': 'download', 'href': '#'}).set('html', '&darr; download').inject(this.text_links);
    new Element('a', {'class': 'right', 'href': '#'}).set('html', 'next &rarr;').inject(this.text_links);
    
    this.link_holder = new Element('div', {'class': 'link_holder'}).inject(this.container);
    this.lefter = new Element('a', {'class': 'left', 'href': '#', 'title': 'previous'}).inject(this.link_holder);
    this.downer = new Element('a', {'class': 'download', 'href': '#', 'title': 'download'}).inject(this.link_holder);
    this.righter = new Element('a', {'class': 'right', 'href': '#', 'title': 'next'}).inject(this.link_holder);

    this.container.getElements('a.left').addEvent('click', this.showPrevious.bindWithEvent(this)); 
    this.container.getElements('a.right').addEvent('click', this.showNext.bindWithEvent(this)); 
    this.container.getElements('a.download').addEvent('click', this.download.bindWithEvent(this)); 
    this.container.getElements('a.close').addEvent('click', this.hide.bindWithEvent(this)); 

    this.container.inject(document.body);
  },
  setShownAndHiddenStates: function () { }, // place() is called before showing
  transitionIn: function () { return Fx.Transitions.Back.easeOut; },
  durationIn: function () { return 'normal'; },
  display: function (item) {
    this.item = item;
    new Fx.Tween(this.image, {duration: 'short', onComplete: this.reshow.bind(this)}).start('opacity', 0);
  },
  adopt: function (item) {
    this.item = item;
    return this;
  },
  reshow: function (argument) {
    this.show();
  },
  beforeShowing: function () {
    this.container.set('morph', {'duration' : 'long'});
    this.place();
    this.fill();
    this.container.bringForward();
    this.visible = true;
  },
  place: function () {
    var itemat = this.item.image.getCoordinates();
    this.when_hiding = {
      left: itemat.left - 8,
      top: itemat.top - 8,
      width: itemat.width,
      height: itemat.height,
      opacity: 0
    };
    if (!this.visible) this.container.setStyles(this.when_hiding);
    var space = window.getSize();
    var h = parseInt(this.item.zoom.get('height'), 10);
    var w = parseInt(this.item.zoom.get('width'), 10);
    this.when_showing = {
      left: Math.floor((space.x - w) / 2),
      top: window.getScroll().y + Math.floor((space.y - h) / 2),
      width: w,
      height: h,
      opacity: 1
    };
  },
  fill: function () {
    this.image.set('src', this.item.zoom.get('src'));
    this.image.fade('in');
    this.title.set('text', this.item.title);
    this.caption.set('text', this.item.caption);
  },
  beforeHiding: function () {
    document.body.removeEvents('click');
  },
  afterShowing: function () {
    this.link_holder.setStyle('height', this.when_showing.height);
    this.container.tween('height', this.when_showing.height + this.caption_holder.getHeight() + 8);
    document.body.addEvent('click', this.hide.bind(this));
  },
  showPrevious: function (e) {
    unevent(e);
    this.display(this.item.previousItem());
  },
  showNext: function (e) {
    unevent(e);
    this.display(this.item.nextItem());
  },
  download: function (e) {
    unevent(e);
    window.location.href = "/assets/" + this.item.asset_id;
  }
});


var zoomer = null;
var captioner = null;

activations.push(function (scope) {
  zoomer = new Zoomer();
  captioner = new Captioner();
  scope.getElements('ul.imagelist').each( function (ul) { new ImageList(ul); }); 
});
