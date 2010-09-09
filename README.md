# Library

This is a gallery/library displayer. It combines [paperclipped](http://github.com/spanner/paperclipped) (for images and documents) and [taggable](http://github.com/spanner/radiant-taggable-extension) to offer faceted tag-based retrieval of everything through a single page. I use it for image libraries, document downloads, and on big sites just for page-retrieval. Anything that is tagged can be offered through this interface.

## Status 

Fairly mature and in use in the world. I've consolidated radius tags that used to be in several places and added some pagination control. It's fairly simple, but the interface is still settling down.

## Requirements

* Radiant 0.8.1
* [paperclipped](http://github.com/spanner/paperclipped) (currently, requires our fork) and [taggable](http://github.com/spanner/radiant-taggable-extension) extensions

## Installation

As usual:

	git submodule add git://github.com/spanner/radiant-library-extension.git vendor/extensions/library
	rake radiant:extensions:library:update
	rake radiant:extensions:library:migrate
	
## Configuration

You need to make sure that paperclipped and taggable load before this does. Multi_site too, if you're using that, and anything that extends paperclipped. This is the sequence I have:

	config.extensions = [ :share_layouts, :multi_site, :taggable, :reader, :reader_group, :paperclipped, :all, :library ]
  
## Examples

See `EXAMPLES.md` for some sample layout and page code.

## Library pages

The **LibraryPage** page type is a handy way of catching tag parameters and displaying lists of related items: any path following the address of the page is taken as a slash-separated list of tags, so with a tag page at /archive you can call addresses like:

	/archive/lasagne/chips/pudding
	
and the right tags will be retrieved, if they exist. This offers a very easy way to make a proper faceted browser.

## Radius tags

This extension used to define a ridiculous profusion of tags, so I have slimmed it ruthlessly to make likely uses easy rather than to make unlikely uses possible.

### Library page tags

The library tags now focus on two tasks: choosing a set of tags and displaying a set of matching objects.

	<r:library:tags />
	<r:library:tags:each>...</r:library:tags:each>
	
Displays a list of the tags available. If any tags have been requested, this will show the list of coincident tags (that can be used to limit the result set further). If not it shows all the available tags. If a `for` attribute is set:

	<r:library:tags for="images" />
	<r:library:tags for="pages" />

Then we show only the set of tags attached to any object of that kind.

	<r:library:requested_tags />
	<r:library:requested_tags:each>...</r:library:requested_tags:each>
	
Displays the currently-limiting set of tags.

	<r:library:pages:each>...</r:library:pages:each>
	<r:library:assets:each>...</r:library:assets:each>
	<r:library:images:each>...</r:library:images:each>
	<r:library:videos:each>...</r:library:videos:each>

Display the list of (that kind of) objects associated with the current tag set.

### Tag assets and asset tags

All the page tags have asset equivalents:

	<r:tags:assets:each tags="foo, bar">...</r:tags:assets:each>
	<r:related_assets:each>...</r:related_assets:each>

and for any `*asset*` tag you can substitute an asset type, so this also works:

	<r:related_images:each>...</r:related_images:each>

You can use all the usual page and asset tags, and also:

	<r:crumbed_link />
	
which I find useful in a list where page names are ambiguous.


## Author and copyright

* William Ross, for spanner. will at spanner.org
* Copyright 2009 spanner ltd
* released under the same terms as Rails and/or Radiant