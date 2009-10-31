# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class LibraryExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/library"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :library
  #   end
  # end
  
  def activate
    # admin.tabs.add "Library", "/admin/library", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Library"
  end
  
end
