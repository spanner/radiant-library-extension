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
    Asset.send :include, LibraryAsset                                  # add a keywords method for likeness with pages
    Page.send :include, LibraryTags                                    # and a load of new page tags for selecting tags and displaying tagged objects
    LibraryPage                                                        # page type that reads tags/from/url and prepares paginated lists of matching pages and assets
    SiteController.send :include, LibrarySiteController                # intervene to catch tag[]= parameters too
  end
  
  def deactivate
    # admin.tabs.remove "Library"
  end
  
end
