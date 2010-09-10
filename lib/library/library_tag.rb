module Library
  module Tag

    def assets
      Asset.from_tags([self])
    end
    
    Asset.known_types.each do |type|
      define_method type.to_s.pluralize.intern do
        Asset.send("#{type.to_s.pluralize}".intern).from_tags([self])
      end
    end
    
  end
end
