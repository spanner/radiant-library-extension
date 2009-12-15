# Library

This is a gallery/library displayer. It combines [paperclipped](http://github.com/spanner/paperclipped) (for images and documents) and [taggable](http://github.com/spanner/radiant-taggable-extension) to offer faceted tag-based retrieval of everything through a single page. I use it for image libraries, document downloads, and on big sites just for page-retrieval. Anything that is tagged can be offered through this interface.

## Status 

Fairly mature and in use in the world. I've consolidated radius tags that used to be in several places and added some pagination control. It's fairly simple, but the interface is still settling down.

## Requirements

* Radiant 0.8.1
* [paperclipped](http://github.com/spanner/paperclipped) (currently, requires our fork) and [taggable](http://github.com/spanner/radiant-taggable-extension) extensions

The sample gallery provided uses mootools because I like it.
It's all done unobtrusively - all we put on the page is lists - so you could easily replace it with a slimbox or some other library.

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
	
and the right tags will be retrieved, if they exist, and made available to the page, where you can display them using the luxurious assortment of tags described below.

## Radius tags

This extension adds a lot more radius tags to those already defined by taggable. For all the page tags and tag pages there are asset equivalents, and we add a lot more for retrieving sets of tags and for retrieving pages and assets from those sets.

### Tag sets

* **requested_tags** is the list of tags found in the request url (and can only be used on a library page)
* **coincident_tags** is the list of tags that occur alongside all of the requested tags and can therefore be used to to narrow the result set further
* **all_tags** is just a list of all the available tags
* **top_tags** is a list of the most popular tags, with incidence and cloud bands
* **page_tags** is the list of tags attached to the present page (and essentially the same as just calling r:tags, but sometimes useful)

Each of these sets can be displayed as a list, cloud or sentence in the usual ways with eg:

	<r:requested_tags:list />
	<r:coincident_tags:cloud />
	<r:page_tags:summary />

and each of them has conditional versions:

	<r:if_requested_tags><r:coincident_tags:cloud /></r:if_requested_tags>
	<r:unless_requested_tags><r:all_tags:cloud /></r:unless_requested_tags>

### Requested tags

The main point of a library page is to display pages and assets based on requested tags, and there are a lot of radius tags for that purpose:

* `requested_tags:pages:each`
* `requested_tags:assets:each`
* `requested_tags:images:each`
* `requested_tags:non_images:each`
* `requested_tags:if_images`
* `requested_tags:if_videos`

and all the permutations those suggest. Within them you can present pages and assets in the usual ways.

### Coincident tags

Given a set of requested tags, the `coincident_tags` list is the set of tags which can be used to further narrow the result set. It's used to present a faceted search. Eg:

* Page 1: charmed, strange, purple
* Page 2: charmed, strange, green
* Page 3: charmed, green
* Page 4: charmed, normal, green

If the viewer requests 'charmed', she will see a list of all four pages. The coincident tags are those tags which co-occur with all the requested tags, which in this case is 'strange, purple, green, normal', and their usefulness is that any of them can be used to narrow the result set. If she adds 'strange' to her requested tags list, probably by clicking on it in a cloud, then the result set shrinks to pages 1 and 2, and the coincident tag set shrinks to 'purple' and 'green', either of which could be used to narrow the set down to a single result. Here's a simple faceted image search:

	<r:if_requested_tags>
		<p>Images associated with <r:requested_tags:summary />.</p>
		<r:requested_tags:images:each><r:asset:link /></r:requested_tags:images:each>
		<r:coincident_tags:cloud />
	<r:if_requested_tags>
	<r:unless_requested_tags>
		<r:image_tags:cloud />
	</r:unless_requested_tags>

and there's an interface shortcut to make common use more readable:

	<r:requested_tags:summary />
	<r:requested_tags:images:each>...</r:requested_tags:images:each>
	<r:tag_chooser />

All this is helped along a bit by `r:requested_tags_summary`, which puts a link around each tag that will remove it from the requested set.

### Tag assets and asset tags

All the page tags have asset equivalents:

	<r:tags:assets:each tags="foo, bar">...</r:tags:assets:each>
	<r:related_assets:each>...</r:related_assets:each>

and for any `*asset*` tag you can substitute an asset type (or negated type), so these also work:

	<r:related_images:each>...</r:related_images:each>
	<r:tags:non_audios:each>...</r:tags:non_audios:each>

You can use all the usual page and asset tags, and also:

	<r:crumbed_link />
	
which I find useful in a list where page names are ambiguous.


## Author and copyright

* William Ross, for spanner. will at spanner.org
* Copyright 2009 spanner ltd
* released under the same terms as Rails and/or Radiant