require 'digest/sha1'

class LibraryPagesDataset < Dataset::Base
  uses :library_tags
  
  def load
    create_page "library", :slug => "library", :class_name => 'LibraryPage', :body => 'Shhhhh.'
  end
 
end