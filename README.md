# Library

This is a gallery/library displayer. It combines [paperclipped](http://github.com/spanner/paperclipped) (for images and documents) and [taggable](http://github.com/spanner/radiant-taggable-extension) to offer faceted tag-based retrieval of everything through a single page. I use it for image libraries, document downloads, and on big sites just for page-retrieval. Anything that is tagged can be offered through this interface.

## Status 

Fairly mature and in use in the world. I've just rationalised the radius tags to support what has emerged as the likely uses, so the interface is now reliable.

We're now using built-in pagination and gem-based configuration, so radiant 0.9 is required.

The requirement for our fork of paperclipped should soon disappear.

## Requirements

* Radiant 0.9
* [paperclipped](http://github.com/spanner/paperclipped) (currently, requires our fork) and [taggable](http://github.com/spanner/radiant-taggable-extension) extensions

## Installation

As usual:

	./script/extension install library

or some variation on:

    git submodule add git://github.com/spanner/radiant-library-extension.git vendor/extensions/library
    rake radiant:extensions:library:update
    rake radiant:extensions:library:migrate
    
## Configuration

You need to make sure that paperclipped and taggable load before this does, and anything that adds content types to paperclipped. This is the most awkward sequence I've had to use:

    config.extensions = [ :share_layouts, :sites, :taggable, :reader, :reader_group, :paperclipped, :paperclipped_gps, :all, :library ]
    
## Library pages

The **LibraryPage** page type is a handy cache-friendly way of catching tag parameters and displaying lists of related items: any path following the address of the page is taken as a slash-separated list of tags, so with a tag page at /archive you can call addresses like:

    /archive/lasagne/chips/pudding
    
and the right tags will be retrieved, if they exist.

## Examples

This will display a faceted image browser on a library page:

    <r:library:if_requested_tags>
      <p>Displaying pictures tagged with <r:library:requested_tags /></p>
    </r:library:if_requested_tags>
    
    <r:library:images:each paginated="true" per_page="20">
      <r:assets:link size="full"><r:assets:image size="small" /></r:assets:link>
    </r:library:images:each>

    <r:library:tags for="images" />
    
And this will automate the illustration of any page based on tag-overlap:

    <r:related_images:each limit="3">
      <r:assets:image size="standard" />
      <p class="caption"><r:assets:caption /></p>
    </r:related_images:each>

## Radius tags

This extension used to define a ridiculous confusion of tags, so I have slimmed it ruthlessly to make likely uses easy rather than to make all uses possible.

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

Within these lists you can use all the usual page and asset tags.

## Author and copyright

* William Ross, for spanner. will at spanner.org
* Copyright 2007-2010 spanner ltd
* released under the same terms as Rails and/or Radiant