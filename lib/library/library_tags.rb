module Library
  module LibraryTags
    include Radiant::Taggable
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TagHelper
  
    class TagError < StandardError; end

    ############### Retrieving lists of tags

    %W{all top page requested coincident}.each do |these|
    
      ################# tag-selection prefixes determine the tag list to be displayed. Exceptions are raised by the list-getters if specific requirements not met.

      desc %{
        Gathers the set of #{these} tags.
        Not usually called directly, but if you want to you can:
        
        *Usage:* 
        <pre><code><r:#{these}_tags><r:tags:cloud /></r:#{these}_tags></code></pre>
      
        is the same as 
      
        <pre><code><r:#{these}_tags:cloud /></code></pre>
      
        but might give you more control.
      }
      tag "#{these}_tags" do |tag|
        tag.locals.tags = send("_get_#{these}_tags".intern, tag)
        tag.expand
      end
    
      ################# conditional tags just check presence of designated tags

      desc %{
        Contents are rendered only if the set of #{these} tags is not empty.

        *Usage:* 
        <pre><code><r:if_#{these}_tags>...</r:if_#{these}_tags></code></pre>
      }    
      tag "if_#{these}_tags" do |tag|
        tag.locals.tags = send("_get_#{these}_tags".intern, tag)
        tag.expand if tag.locals.tags.any?
      end
    
      desc %{
        Contents are rendered only if the set of #{these} tags is empty.

        *Usage:* 
        <pre><code><r:unless_#{these}_tags>...</r:unless_#{these}_tags></code></pre>
      }    
      tag "unless_#{these}_tags" do |tag|
        tag.locals.tags = send("_get_#{these}_tags".intern, tag)
        tag.expand unless tag.locals.tags.any?
      end

      ################# display suffixes pass on to the relevant tags:* method

      desc %{
        Loops through all the #{these} tags.

        *Usage:* 
        <pre><code><r:#{these}_tags:each>...</r:#{these}_tags:each></code></pre>
      }
      tag "#{these}_tags:each" do |tag|
        tag.render('tags:each', tag.attr.dup)
      end

      desc %{
        Returns a list of all the #{these} tags.

        *Usage:* 
        <pre><code><r:#{these}_tags:list /></code></pre>
      }
      tag "#{these}_tags:list" do |tag|
        tag.render('tags:list', tag.attr.dup)
      end

      desc %{
        Returns a cloud of all the #{these} tags.

        *Usage:* 
        <pre><code><r:#{these}_tags:cloud /></code></pre>
      }
      tag "#{these}_tags:cloud" do |tag|
        tag.render('tags:cloud', tag.attr.dup)
      end

      desc %{
        Summarises in a sentence the list of #{these} tags.
      
        *Usage:* 
        <pre><code><r:#{these}_tags:summary /></code></pre>
      }    
      tag "#{these}_tags:summary" do |tag|
        tag.render('tags:summary', tag.attr.dup)
      end
    end

    ############### Retrieving pages and assets from a supplied list of tags
                  # at the moment these are only defined for requested_tags
                  # because it's much more streamlined that way.
                  # and because tags:* already gives you most of this functionality for page assets


    desc %{
      Lists all the pages tagged with the requested tags, in descending order of overlap.

      *Usage:* 
      <pre><code><r:requested_tags:pages:each>...</r:requested_tags:pages:each></code></pre>
    }
    tag "requested_tags:pages" do |tag|
      tag.locals.pages = tag.locals.page.tagged_pages
      tag.expand
    end
    tag "requested_tags:pages:each" do |tag|
      tag.render('page_list', tag.attr.dup, &tag.block) 
    end

    desc %{
      Renders the contained elements only if there are any pages associated with the requested tags.

      *Usage:* 
      <pre><code><r:requested_tags:if_pages>...</r:requested_tags:if_pages></code></pre>
    }
    tag "requested_tags:if_pages" do |tag|
      tag.locals.pages = tag.locals.page.tagged_pages
      tag.expand if tag.locals.pages.any?
    end

    desc %{
      Renders the contained elements only if there are no pages associated with the requested tags.

      *Usage:* 
      <pre><code><r:requested_tags:unless_pages>...</r:requested_tags:unless_pages></code></pre>
    }
    tag "requested_tags:unless_pages" do |tag|
      tag.locals.pages = tag.locals.page.tagged_pages
      tag.expand unless tag.locals.pages.any?
    end

    desc %{
      Lists all the assets tagged with any of the set of the requested tags, in descending order of overlap.

      *Usage:* 
      <pre><code><r:requested_tags:assets:each>...</r:requested_tags:assets:each></code></pre>
    }
    tag "requested_tags:assets" do |tag|
      tag.locals.assets = tag.locals.page.tagged_assets
      tag.expand
    end
    tag "requested_tags:assets:each" do |tag|
      tag.render('asset_list', tag.attr.dup, &tag.block)
    end

    desc %{
      Renders the contained elements only if there are any assets associated with the set of the requested tags.

      *Usage:* 
      <pre><code><r:requested_tags:if_assets>...</r:requested_tags:if_assets></code></pre>
    }
    tag "requested_tags:if_assets" do |tag|
      tag.locals.assets = tag.locals.page.tagged_assets
      tag.expand if tag.locals.assets.any?
    end

    desc %{
      Renders the contained elements only if there are no assets associated with the set of the requested tags.

      *Usage:* 
      <pre><code><r:requested_tags:unless_assets>...</r:requested_tags:unless_assets></code></pre>
    }
    tag "requested_tags:unless_assets" do |tag|
      tag.locals.assets = tag.locals.page.tagged_assets
      tag.expand unless tag.locals.assets.any?
    end

    ############### Specifying asset types

    Asset.known_types.each do |type|

      desc %{
        Lists all the #{type} assets tagged with all of the set of requested tags.

        *Usage:* 
        <pre><code><r:requested_tags:#{type.to_s.pluralize}:each>...</r:requested_tags:#{type.to_s.pluralize}:each></code></pre>
      }
      tag "requested_tags:#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = tag.locals.page.send("tagged_#{type.to_s.pluralize}".intern)
        tag.expand
      end
      tag "requested_tags:#{type.to_s.pluralize}:each" do |tag|
        tag.render('asset_list', tag.attr.dup, &tag.block)
      end

      desc %{
        Renders the contained elements only if there are any #{type} assets associated with the set of requested tags.

        *Usage:* 
        <pre><code><r:requested_tags:if_#{type.to_s.pluralize}>...</r:requested_tags:if_#{type.to_s.pluralize}></code></pre>
      }
      tag "requested_tags:if_#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = tag.locals.page.send("tagged_#{type.to_s.pluralize}".intern)
        tag.expand if tag.locals.assets.any?
      end

      desc %{
        Renders the contained elements only if there are no #{type} assets associated with the requested tags.

        *Usage:* 
        <pre><code><r:requested_:unless_assets>...</r:requested_:unless_assets></code></pre>
      }
      tag "requested_tags:unless_#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = tag.locals.page.send("tagged_#{type.to_s.pluralize}".intern)
        tag.expand unless tag.locals.assets.any?
      end

      desc %{
        Lists all the non-#{type} assets tagged with any of the set of the requested tags, in descending order of overlap.

        *Usage:* 
        <pre><code><r:requested_tags:non_#{type.to_s.pluralize}:each>...</r:requested_tags:non_#{type.to_s.pluralize}:each></code></pre>
      }
      tag "requested_tags:non_#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = tag.locals.page.send("tagged_non_#{type.to_s.pluralize}".intern)
        tag.expand
      end
      tag "tags:non_#{type.to_s.pluralize}:each" do |tag|
        tag.render('asset_list', tag.attr.dup, &tag.block)
      end

      desc %{
        Renders the contained elements only if there are any non-#{type} assets associated with the set of the requested tags.

        *Usage:* 
        <pre><code><r:requested_tags:if_non_#{type.to_s.pluralize}>...</r:requested_tags:if_non_#{type.to_s.pluralize}></code></pre>
      }
      tag "requested_tags:if_non_#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = tag.locals.page.send("tagged_non_#{type.to_s.pluralize}".intern)
        tag.expand if tag.locals.assets.any?
      end

      desc %{
        Renders the contained elements only if there are no non-#{type} assets associated with the set of the requested tags.

        *Usage:* 
        <pre><code><r:requested_tags:unless_non_#{type.to_s.pluralize}>...</r:requested_tags:unless_non_#{type.to_s.pluralize}></code></pre>
      }
      tag "requested_tags:unless_non_#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = tag.locals.page.send("tagged_non_#{type.to_s.pluralize}".intern)
        tag.expand unless tag.locals.assets.any?
      end
    end

    ############### retrieving tags from asset sets

    Asset.known_types.each do |type|
      desc %{
        Gathers all the tags attached to #{type.to_s.pluralize}.
        Can be used to make a cloud or chooser in the usual way.

        *Usage:* 
        <pre><code><r:#{type}_tags><r:tags:cloud /></r:#{type}_tags></code></pre>
      }
      tag "#{type}_tags" do |tag|
        tag.locals.tags = Tag.attached_to(Asset.not_furniture.send(type.to_s.pluralize.intern)).most_popular
        tag.expand
      end

      desc %{
        Loops through all the #{type} tags.

        *Usage:* 
        <pre><code><r:#{type}_tags:each>...</r:#{type}_tags:each></code></pre>
      }
      tag "#{type}_tags:each" do |tag|
        tag.render('tags:each', tag.attr.dup)
      end

      desc %{
        Returns a list of all the #{type} tags.

        *Usage:* 
        <pre><code><r:#{type}_tags:list /></code></pre>
      }
      tag "#{type}_tags:list" do |tag|
        tag.render('tags:list', tag.attr.dup)
      end

      desc %{
        Returns a cloud of all the #{type} tags.

        *Usage:* 
        <pre><code><r:#{type}_tags:cloud /></code></pre>
      }
      tag "#{type}_tags:cloud" do |tag|
        tag.render('tags:cloud', tag.attr.dup)
      end

      desc %{
        Summarises in a sentence the list of #{type} tags.
      
        *Usage:* 
        <pre><code><r:#{type}_tags:summary /></code></pre>
      }    
      tag "#{type}_tags:summary" do |tag|
        tag.render('tags:summary', tag.attr.dup)
      end
    end

    ############### asset equivalents of existing page tags
                  # (i would like to use the Tagged_models array to dry this but there are some extension load order issues to work through)
                  # the main use for these tags is to pull related images and documents into pages
  
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
      Renders the contained elements only if there are no pages associated with the current set of tags.

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
  
    # tags for one asset
  
    desc %{
      Cycles through all tags attached to present asset.
    
      *Usage:* 
      <pre><code><r:assets:tags><r:tag:title /></r:assets:tags></code></pre>
    }    
    tag 'assets:tags' do |tag|
      raise TagError, "asset must be defined for asset:tags tag" unless tag.locals.asset
      tag.locals.tags = tag.locals.asset.tags
      tag.expand
    end
    tag 'assets:tags:each' do |tag|
      tag.render('tags:each', tag.attr.dup, &tag.block)
    end

    desc %{
      Lists all the assets similar to this asset (based on its tagging), in descending order of relatedness.
    
      *Usage:* 
      <pre><code><r:related_assets:each>...</r:related_assets:each></code></pre>
    }
    tag 'related_assets' do |tag|
      raise TagError, "asset must be defined for related_assets tag" unless tag.locals.asset
      tag.locals.assets = tag.locals.asset.related_assets
      tag.expand
    end
    tag 'related_assets:each' do |tag|
      tag.render('assets:each', tag.attr.dup, &tag.block)
    end

    # assets from one tag

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
      Renders the contained elements only if there are no pages associated with the current tag.

      *Usage:* 
      <pre><code><r:tag:unless_assets>...</r:tag:unless_assets></code></pre>
    }
    tag "tag:unless_assets" do |tag|
      raise TagError, "tag must be defined for tag:unless_assets tag" unless tag.locals.tag
      tag.locals.assets = tag.locals.tag.assets
      tag.expand unless tag.locals.assets.any?
    end

    # useful things on library pages

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

    desc %{
      This is essentially a filtering form: it returns a cloud of the selected tags, linked so that you can remove them, 
      and a cloud of related (ie subsetting) tags, linked so that you can add them. It only works on a LibraryPage. 
    
      You can limit the size of the available-tags list in the usual way. The default limit is 40. 

      Other parameters are passed through to the link tags.
    
      *Usage:* 
      <pre><code><r:tag_chooser limit="20" /></code></pre>
    }    
    tag 'tag_chooser' do |tag|
      options = tag.attr.dup
      result = []
      requested_tags = _get_requested_tags(tag)
      if requested_tags.any?
        result << %{<p>Broaden your search by removing a tag:</p>}
        result << tag.render("requested_tags:cloud", options.merge({'unlink' => true, 'listclass' => 'cloud remove_tags'}))
        result << %{<p>Refine your search by adding another tag:</p>}
        result << tag.render("coincident_tags:cloud", options.merge({'unlink' => false, 'listclass' => 'cloud add_tags'}))
      else
        result << %{<p>Narrow your search by choosing a tag</p>}
        result << tag.render("all_tags:cloud", options)
      end
      result
    end
  
    desc %{ 
      Presents a tag cloud built from the current set of assets. If none is defined, we show a cloud for the whole asset set.
    
      See r:tag_cloud for formatting and linking parameters. By default we show the top 100 most used tags.
    
      *Usage:*
      <pre><code><r:assets:tag_cloud /></code></pre>
    }
    tag 'assets:tag_cloud' do |tag|
      options = tag.attr.dup
      assets = if tag.locals.assets
        tag.locals.assets
      elsif taglist = options.delete('tags')
        _assets_for_tags(taglist)
      else
        Asset.all
      end
      limit = options.delete('limit') || 100
      if assets.any?
        tag.locals.tags = Tag.banded(Tag.attached_to(assets).most_popular(limit))
        tag.render('tags:cloud', options)
      end
    end

  private
  
    def _asset_finder(tag)
      if (tag.locals.tags)
        Asset.from_all_tags(tag.locals.tags).not_furniture
      else
        Asset.not_furniture
      end
    end

    def _get_all_tags(tag)
      Tag.all
    end

    def _get_top_tags(tag)
      limit = tag.attr.delete('limit') || 1000
      Tag.most_popular(limit)
    end

    def _get_page_tags(tag)
      raise TagError, "page_tags needs a page" unless tag.locals.page
      tag.locals.page.attached_tags
    end

    def _get_requested_tags(tag)
      raise TagError, "requested_tags tags can only be used on a LibraryPage" unless tag.locals.page && tag.locals.page.is_a?(LibraryPage)
      tag.locals.page.requested_tags
    end

    def _get_coincident_tags(tag)
      raise TagError, "coincident_tags tag can only be used on a LibraryPage" unless tag.locals.page && tag.locals.page.is_a?(LibraryPage)
      tags = tag.locals.page.requested_tags
      if tags.any?
        Tag.coincident_with(tags)
      else
        Tag.all
      end
    end
  end
end


