module Library
  module MoreTagTags
    include Radiant::Taggable
  
    class TagError < StandardError; end

    ############### overriding standard taggable links

    desc %{
      Summarises in a sentence the list of tags currently active, with each one presented as a defaceting link.
    }    
    tag 'tags:unlink_list' do |tag| 
      requested = _get_requested_tags(tag)     
      if requested.any?
        requested.map { |t|
          tag.locals.tag = t
          tag.render('tag:unlink', tag.attr.dup)
        }.to_sentence
      else
        ""
      end
    end
    
    desc %{
      Makes a link that removes the current tag from the active set. Other options as for tag:link.

      *Usage:* 
      <pre><code><r:tag:unlink linkto='/library' /></code></pre>
    }
    tag 'tag:unlink' do |tag|
      raise TagError, "tag must be defined for tag:unlink tag" unless tag.locals.tag
      options = tag.attr.dup
      options['class'] ||= 'detag'
      anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
      attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
      attributes = " #{attributes}" unless attributes.empty?
      text = tag.double? ? tag.expand : tag.render('tag:name')

      if tag.locals.page.is_a?(LibraryPage)
        href = tag.locals.page.url(tag.locals.page.requested_tags - [tag.locals.tag])
      elsif page_url = (options.delete('tagpage') || Radiant::Config['tags.page'])
        href = clean_url(page_url + '/-' + tag.locals.tag.clean_title)
      else 
        href ||= Rack::Utils.escape("-#{tag.locals.tag.title}") + '/'
      end

      %{<a href="#{href}#{anchor}"#{attributes}>#{text}</a>}
    end


    ############### asset-listing equivalents of existing page tags
                  # the main use for these tags is to pull related images and documents into pages
                  # in the same way as you would pull in related pages
  
    desc %{
      Lists all the assets associated with a set of tags, in descending order of relatedness.
    
      *Usage:* 
      <pre><code><r:tags:assets:each>...</r:tags:assets:each></code></pre>
    }
    tag 'tags:assets' do |tag|
      tag.expand
    end
    tag 'tags:assets:each' do |tag|
      tag.locals.assets ||= _asset_finder(tag)
      tag.render('asset_list', tag.attr.dup, &tag.block)
    end

    desc %{
      Renders the contained elements only if there are any assets associated with the current set of tags.

      *Usage:* 
      <pre><code><r:tags:if_assets>...</r:tags:if_assets></code></pre>
    }
    tag "tags:if_assets" do |tag|
      tag.locals.assets = _assets_for_tags(tag.locals.tags)
      tag.expand if tag.locals.assets.any?
    end

    desc %{
      Renders the contained elements only if there are no assets associated with the current set of tags.

      *Usage:* 
      <pre><code><r:tags:unless_assets>...</r:tags:unless_assets></code></pre>
    }
    tag "tags:unless_assets" do |tag|
      tag.locals.assets = _assets_for_tags(tag.locals.tags)
      tag.expand unless tag.locals.assets.any?
    end
  
    desc %{
      Lists all the assets similar to this page (based on its tagging), in descending order of relatedness.
    
      *Usage:* 
      <pre><code><r:related_assets:each>...</r:related_assets:each></code></pre>
    }
    tag 'related_assets' do |tag|
      raise TagError, "page must be defined for related_assets tag" unless tag.locals.page
      tag.locals.assets = Asset.not_furniture.from_tags(tag.locals.page.attached_tags)
      tag.expand
    end
    tag 'related_assets:each' do |tag|
      tag.render('asset_list', tag.attr.dup, &tag.block)
    end
  
    Asset.known_types.each do |type|
      desc %{
        Lists all the #{type} assets similar to this page (based on its tagging), in descending order of relatedness.

        *Usage:* 
        <pre><code><r:related_#{type.to_s.pluralize}:each>...</r:related_#{type.to_s.pluralize}:each></code></pre>
      }
      tag "related_#{type.to_s.pluralize}" do |tag|
        raise TagError, "page must be defined for related_#{type.to_s.pluralize} tag" unless tag.locals.page
        tag.locals.assets = Asset.not_furniture.from_tags(tag.locals.page.attached_tags).send("#{type.to_s.pluralize}".intern)
        tag.expand
      end
      tag "related_#{type.to_s.pluralize}:each" do |tag|
        tag.render('asset_list', tag.attr.dup, &tag.block)
      end
    end

    ############### tags: tags for displaying assets when we have a tag
                  # similar tags already exist for pages

    desc %{
      Loops through the assets to which the present tag has been applied
    
      *Usage:* 
      <pre><code><r:tag:assets:each>...</r:tag:assets:each></code></pre>
    }    
    tag 'tag:assets' do |tag|
      raise TagError, "tag must be defined for tag:assets tag" unless tag.locals.tag
      tag.locals.assets = tag.locals.tag.assets
      tag.expand
    end
    tag 'tag:assets:each' do |tag|
      tag.render('assets:each', tag.attr.dup, &tag.block)
    end
  
    desc %{
      Renders the contained elements only if there are any assets associated with the current tag.

      *Usage:* 
      <pre><code><r:tag:if_assets>...</r:tag:if_assets></code></pre>
    }
    tag "tag:if_assets" do |tag|
      raise TagError, "tag must be defined for tag:if_assets tag" unless tag.locals.tag
      tag.locals.assets = tag.locals.tag.assets
      tag.expand if tag.locals.assets.any?
    end

    desc %{
      Renders the contained elements only if there are no assets associated with the current tag.

      *Usage:* 
      <pre><code><r:tag:unless_assets>...</r:tag:unless_assets></code></pre>
    }
    tag "tag:unless_assets" do |tag|
      raise TagError, "tag must be defined for tag:unless_assets tag" unless tag.locals.tag
      tag.locals.assets = tag.locals.tag.assets
      tag.expand unless tag.locals.assets.any?
    end
    
    

  private

    def _asset_finder(tag)
      if (tag.locals.tags)
        Asset.from_all_tags(tag.locals.tags).not_furniture
      else
        Asset.not_furniture
      end
    end

  end
end

