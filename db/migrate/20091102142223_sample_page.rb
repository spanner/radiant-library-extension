class SamplePage < ActiveRecord::Migration
  def self.up
    
    library_layout = Layout.create :name => '_Library', :content => <<-EO
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
    EO

    library_snippet = Snippet.create :name => '_library_items', :content => <<-EO
<ul class="imagelist">
  <r:assets:all_images:each>
    <li><r:assets:link size="large"><img id="asset_<r:assets:id />" src="<r:assets:url size="thumbnail" />" width="42" height="42" alt="<r:assets:title />" title="<r:assets:caption />"></r:assets:link></li>
  </r:assets:all_images:each>
</ul>
<r:assets:pagination entry_name="image" with_summary="true" />
    EO

    library_page = Page.create :title => '_Library', :class_name => 'LibraryPage', :slug => 'sample_library', :breadcrumb => 'Library', :layout => library_layout, :parent => Page.find_by_parent_id(nil)

    library_page.parts.create :name => 'body', :content => <<-EO
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
    EO

    library_page.parts.create :name => 'sidebar', :content => <<-EO
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
    EO
  
    Radiant::Config['library.per_page'] = '20'
  end

  def self.down
  end
end
