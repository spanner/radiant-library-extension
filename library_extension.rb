require_dependency 'application_controller'

class LibraryExtension < Radiant::Extension
  version "2.0"
  description "Combines paperclipped and taggable to create a general purpose faceted library"
  url "http://radiant.spanner.org/library"
    
  def activate
    Asset.send :is_taggable                                            # make assets taggable
    Asset.send :include, Library::TaggedAsset                          # add a keywords method for likeness with pages
    Tag.send :include, Library::LibraryTag                             # adds assets and asset-type methods to Tag
    LibraryPage                                                        # page type that reads tags/from/url and prepares paginated lists of matching pages and assets
    SiteController.send :include, Library::SiteController              # intervene to catch tag[]= parameters too
    Page.send :include, Library::MoreAssetTags                         # defines a few more r:assets:* radius tags
    Page.send :include, Library::MoreTagTags                           # defines a few more r:tag:* radius tags
    
    admin.tag.show.add :main, "/admin/tags/show_assets", :after => "show_pages"
  end
  
  def deactivate
    admin.tabs.remove "Library" unless respond_to?(:tab)
  end
  
end
