require_dependency 'application_controller'

class LibraryExtension < Radiant::Extension
  version "1.0"
  description "Combines paperclipped and taggable to create a general purpose library page"
  url "http://radiant.spanner.org/library"
  
  extension_config do |config|
    config.extension 'paperclipped'
    config.extension 'taggable'
  end
  
  def activate
    Asset.send :is_taggable                                            # make assets taggable
    Asset.send :include, Library::TaggedAsset                          # add a keywords method for likeness with pages
    LibraryPage                                                        # page type that reads tags/from/url and prepares paginated lists of matching pages and assets
    SiteController.send :include, Library::SiteController              # intervene to catch tag[]= parameters too
    Page.send :include, Library::MoreAssetTags
  end
  
  def deactivate
    # admin.tabs.remove "Library"
  end
  
end
