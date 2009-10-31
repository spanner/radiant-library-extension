# Library

This is a gallery/library displayer. It combines paperclipped (for images and documents) and taggable to offer faceted tag-based retrieval of everything through a single page. I use it for image libraries, document downloads, and on big sites just for page-retrieval. Anything that is tagged can be offered through this interface.

## Status 

New but simple. The work is done in the taggable extension: all we really do here is apply that to assets and add some radius tags for showing galleries.

Most of the code here comes from the now-defunct `paperclipped_taggable`, but I've consolidated radius tags that used to be in several places and added some pagination control.

## Requirements

* Radiant 0.8.1
* [paperclipped](https://github.com/spanner/paperclipped) (currently, requires our fork) and [taggable](https://github.com/spanner/radiant-taggable-extension) extensions

The sample gallery provided uses mootools because I like it.
It's all done unobtrusively - all we put on the page is lists - so you could easily replace it with a slimbox or some other library.

## Installation

As usual:

	git submodule add git://github.com/spanner/radiant-library-extension.git vendor/extensions/library
	rake radiant:extensions:library:update
	
## Configuration

You need to make sure that paperclipped and taggable load before this does. Multi_site too, if you're using that. This is the sequence I have:

	config.extensions = [ :share_layouts, :multi_site, :taggable, :reader, :reader_group, :paperclipped, :all ]
  
## Examples

The migrations will create a sample library page for you.

## Library pages

The **LibraryPage** page type is a handy way of catching tag parameters and displaying lists of related items: any path following the address of the page is taken as a slash-separated list of tags, so with a tag page at /archive you can call addresses like:

	/archive/lasagne/chips/pudding
	
and the right tags will be retrieved, if they exist, and made available to the page, where you can display them using the luxurious assortment of tags described below.

## Radius tags

This extension adds a lot more radius tags to those already defined by taggable. For all the page tags and tag pages there are asset equivalents, and we add a complex system of retrieving and displaying matched items that works like this:

	<r:choose_some_tags:do_something>

These only work on LibraryPages and they always have two parts: the first part specifies a set of tags and the second part specifies an action on them.

### tag sets

* **requested_tags** is the list of tags found in the request url
* **coincident_tags** is the list of tags that occur alongside all of the requested tags and can therefore be used to to narrow the result set further

These three sets are also useable on normal pages:

* **all_tags** is just a list of all the available tags
* **top_tags** is a list of the most popular tags, with incidence and cloud bands
* **page_tags** is the list of tags attached to the present page

Each of them has a conditional version:

* eg **if_coincident_tags** expands only if there are any tags that can be used to narrow down the current result set.

To each you can append conditions:

* `if_pages` expands if we can find any pages tagged with all of these tags. Similarly `if_assets`
* `unless_pages` and 'unless_assets' are the reverse.

or display instructions:

* **...:each** will loop through the set in the usual way
* **...:summary** will give a sentence summarising the set
* **...:list** will show an unordered list of tag links
* **...:cloud** will show a tag cloud with banding based on global tag application

	<r:all_tags:list />
	<r:requested_tags:summary />
	<r:coincident_tags:cloud />
	<r:top_tags:list limit="10" />

or lists of associated items:

* **...:pages:each** loops through the set of tagged pages
* **...:if_pages** expands if there are any tagged pages 
* **...:unless_pages** expands if there are none

### Assets

All the page tags have asset equivalents:

	<r:requested_tags:pages:each>...</r:requested_tags:pages:each>
	<r:requested_tags:assets:each>...</r:requested_tags:assets:each>

and for any `*asset*` tag you can substitute an asset type (or negated type), so these also work:

	<r:requested_tags:images:each>...</r:requested_tags:images:each>
	<r:requested_tags:non_images:each>...</r:requested_tags:non_images:each>
	<r:requested_tags:audios:each>...</r:requested_tags:audios:each>

within that you can use all the usual page and asset tags, and also:

	<r:crumbed_link />
	
which I find useful where page names are ambiguous.

There is also a useful shortcut for use on a LibraryPage:

* **tag_chooser** displays a handy form 
	
The form lists and links correctly all the tags you might want to add to or remove from the present query. It gives a nice faceted search and at some point I'm going to combine it with a free-text index.

## Author and copyright

* William Ross, for spanner. will at spanner.org
* Copyright 2009 spanner ltd
* released under the same terms as Rails and/or Radiant