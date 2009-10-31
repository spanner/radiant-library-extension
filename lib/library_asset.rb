module LibraryAsset      # for inclusion into Asset

  # not much to see here: just keeping compatibility with page tags
  # so as to present the same interface
  
  def self.included(base)

    base.class_eval {
      extend TaggablePage::ClassMethods
      include TaggablePage::InstanceMethods
    }
  end

  module ClassMethods
  end


  module InstanceMethods

    def keywords 
      self.attached_tags.map {|t| t.title}.join(', ')
    end
    
    def keywords=(somewords="")
      self.attached_tags = Tag.from_list(somewords)
    end
    
    def keywords_before_type_cast   # necessary for form_helper
      keywords
    end

  end
end