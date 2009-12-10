# Getting Started

Here's some boilerplate to begin with. There's quite a lot of conditionality on the results page - hence the snippet, to dry it out a bit - but that's only because I have it set up to display everything if no tags are selected. If you would prefer to start with an empty page, you can omit all the `unless_requested_tags` and most of the `if_requested_tags` blocks.

The platform javascript uses mootools and an extendable initializer that I've found useful in various contexts. In this context it doesn't actually do much apart from zoom a clicked image, so it's easily replaced with a lightbox or whatever else you fancy.

## Layout

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
	  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
	<html>
	  <head>
	    <title><r:title /></title>
	    <link rel="stylesheet" href="/stylesheets/platform/library.css" type="text/css" media="all" />
	    <script type="text/javascript" charset="utf-8" src="/javascripts/mootools.js"></script>
	    <script type="text/javascript" charset="utf-8" src="/javascripts/mootools-more.js"></script>
	    <script type="text/javascript" charset="utf-8" src="/javascripts/platform/core.js"></script>
	    <script type="text/javascript" charset="utf-8" src="/javascripts/platform/library.js"></script>
	  </head>
	  <body>
	    <div id="container">
	      <div id="header">
	        <h1><r:title /></h1>
	      </div>
	      <div id="page">
	        <div id="sidebar"><r:content part="sidebar" /></div>
	        <div id="content"><r:content /></div>
	      </div>
	    </div>
	  </body>
	</html>

## Snippet

	<ul class="imagelist">
	  <r:assets:all_images:each>
	    <li><r:assets:link size="large"><img id="asset_<r:assets:id />" src="<r:assets:url size="thumbnail" />" width="42" height="42" alt="<r:assets:title />" title="<r:assets:caption />"></r:assets:link></li>
	  </r:assets:all_images:each>
	</ul>
	<r:assets:pagination entry_name="image" with_summary="true" />

## Library Page

	<div id="sidebar">
	  <p>
	    Refine your search by
	    <r:if_requested_tags>adding more tags.</r:if_requested_tags>
	    <r:unless_requested_tags>choosing a tag.</r:unless_requested_tags>
	    Larger tags match more items:
	  </p>

	  <r:if_requested_tags>
	    <r:if_coincident_tags>
	      <r:coincident_tags:cloud />
	    </r:if_coincident_tags>
	    <r:unless_coincident_tags>
	      <p class="administrative">No more tags.</p>
	    </r:unless_coincident_tags>
	  </r:if_requested_tags>

	  <r:unless_requested_tags>
	    <r:image_tags:cloud />
	  </r:unless_requested_tags>
	</div>

	<r:unless_requested_tags>
	  <r:assets:all_images>
	    <r:snippet name="_library_items" />
	  </r:assets:all_images>
	</r:unless_requested_tags>

	<r:if_requested_tags>

	  <p>Images associated with <r:requested_tags:summary /> (click a tag name to remove it and broaden your search).</p>

	  <r:requested_tags:if_images>
	    <r:requested_tags:images>
	      <r:snippet name="_library_items" />
	    </r:requested_tags:images>
	  </r:requested_tags:if_images>

	  <r:requested_tags:unless_images>
	    <p>No images!</p>
	  </r:requested_tags:unless_images>

	</r:if_requested_tags>
