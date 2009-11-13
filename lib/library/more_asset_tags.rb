module Library
  module MoreAssetTags
    include Radiant::Taggable
  
    class TagError < StandardError; end

    [:copyright].each do |method|
      desc %{
        Expands if the asset has a #{method} notice.
        The 'title' attribute is required on this tag or the parent tag.
      }
      tag "assets:if_#{method.to_s}" do |tag|
        options = tag.attr.dup
        asset = find_asset(tag, options)
        tag.expand if asset.respond_to?(method) && asset.send(method)
      end
      
      desc %{
        Expands unless the asset has a #{method} notice.
        The 'title' attribute is required on this tag or the parent tag.
      }
      tag "assets:unless_#{method.to_s}" do |tag|
        options = tag.attr.dup
        asset = find_asset(tag, options)
        tag.expand unless asset.respond_to?(method) && asset.send(method)
      end

      desc %{
        Renders the `#{method.to_s}' attribute of the asset.
        The 'title' attribute is required on this tag or the parent tag.
      }
      tag "assets:#{method.to_s}" do |tag|
        options = tag.attr.dup
        asset = find_asset(tag, options)
        asset.send(method) rescue nil
      end
    end

    #### listing all (not just page-attached) assets

    desc %{
      Loops through all the available (non-furniture) assets. Only works on a library page, where it is automatically paginated.
      (Use r:assets:each if you want all the assets attached to the present page.)

      *Usage:* 
      <pre><code><r:assets:all>...</r:assets:all></code></pre>
    }
    tag "assets:all" do |tag|
      tag.locals.assets = tag.locals.page.send("all_assets")
      tag.render('asset_list', tag.attr.dup, &tag.block)
    end

    Asset.known_types.each do |type|

      #### conditional on presence or absence of assets of type...
      
      desc %{
        Expands if any #{type} assets are attached to the page.
        Note the pluralization: r:assets:if_image tests whether a particular asset is an image file.
        r:assets:if_images tests whether any images are present.

        *Usage:* 
        <pre><code><r:assets:if_#{type.to_s.pluralize}>...</r:assets:if_#{type.to_s.pluralize}></code></pre>
      }
      tag "assets:if_#{type.to_s.pluralize}" do |tag|
        raise TagError, "page must be defined for assets:if_#{type.to_s.pluralize} tag" unless tag.locals.page
        assets = tag.locals.page.assets.send(type.to_s.pluralize.intern)
        tag.expand if assets.any?
      end

      desc %{
        Expands if no #{type} assets are attached to the page.
        Note the pluralization: r:assets:unless_image tests whether a particular asset is an image file.
        r:assets:unless_images tests whether any images are present.

        *Usage:* 
        <pre><code><r:assets:unless_#{type.to_s.pluralize}>...</r:assets:unless_#{type.to_s.pluralize}></code></pre>
      }
      tag "assets:unless_#{type.to_s.pluralize}" do |tag|
        raise TagError, "page must be defined for assets:unless_#{type.to_s.pluralize} tag" unless tag.locals.page
        assets = tag.locals.page.assets.send(type.to_s.pluralize.intern)
        tag.expand unless assets.any?
      end
      
      desc %{
        Expands if any non-#{type} assets are attached to the page.
        Note the pluralization: r:assets:if_non_image tests whether a particular asset is not an image file.
        r:assets:if_non_images tests whether any non-images are present.

        *Usage:* 
        <pre><code><r:assets:if_non_#{type.to_s.pluralize}>...</r:assets:if_non_#{type.to_s.pluralize}></code></pre>
      }
      tag "assets:if_non_#{type.to_s.pluralize}" do |tag|
        raise TagError, "page must be defined for assets:if_non_#{type.to_s.pluralize} tag" unless tag.locals.page
        assets = tag.locals.page.assets.send("non_#{type.to_s.pluralize}".intern)
        tag.expand if assets.any?
      end

      desc %{
        Expands if no non-#{type} assets are attached to the page.
        Note the pluralization: r:assets:unless_non_image tests whether a particular asset is not an image file.
        r:assets:unless_non_images tests whether any non-images are present.

        *Usage:* 
        <pre><code><r:assets:unless_non_#{type.to_s.pluralize}>...</r:assets:unless_non_#{type.to_s.pluralize}></code></pre>
      }
      tag "assets:unless_non_#{type.to_s.pluralize}" do |tag|
        raise TagError, "page must be defined for assets:unless_non_#{type.to_s.pluralize} tag" unless tag.locals.page
        assets = tag.locals.page.assets.send("non_#{type.to_s.pluralize}".intern)
        tag.expand unless assets.any?
      end

      #### page-attached assets by type

      tag "assets:#{type.to_s.pluralize}" do |tag|
        raise TagError, "page must be defined for assets:#{type} tags" unless tag.locals.page
        tag.locals.assets = tag.locals.page.assets.send(type.to_s.pluralize.intern)
        tag.expand
      end

      desc %{
        Loops through all the attached assets of type #{type}.

        *Usage:* 
        <pre><code><r:assets:#{type.to_s.pluralize}:each>...</r:assets:#{type.to_s.pluralize}:each></code></pre>
      }
      tag "assets:#{type.to_s.pluralize}:each" do |tag|
        tag.render('asset_list', tag.attr.dup, &tag.block)
      end

      desc %{
        Displays the first attached asset of type #{type}.

        *Usage:* 
        <pre><code><r:assets:first_#{type}>...</r:assets:first_#{type}></code></pre>
      }
      tag "assets:first_#{type}" do |tag|
        raise TagError, "page must be defined for assets:first_#{type} tag" unless tag.locals.page
        assets = tag.locals.page.assets.send(type.to_s.pluralize.intern)
        if assets.any?
          tag.locals.asset = assets.first
          tag.expand
        end
      end

      desc %{
        Displays the second attached asset of type #{type}. This is occasionaly useful in rollovers but usually a sign that you're overdoing it :)

        *Usage:* 
        <pre><code><r:assets:second_#{type.to_s}>...</r:assets:second_#{type.to_s}></code></pre>
      }
      tag "assets:second_#{type.to_s}" do |tag|
        raise TagError, "page must be defined for assets:second_#{type} tag" unless tag.locals.page
        assets = tag.locals.page.assets.send(type.to_s.pluralize.intern)
        if assets.length > 1
          assets.shift
          tag.locals.asset = assets.first
          tag.expand
        end
      end

      #### collections of assets by type

      desc %{
        Loops through all the assets of type #{type}.
        (Use r:assets:#{type.to_s.pluralize}:each if you want all the #{type} assets attached to the present page.)

        *Usage:* 
        <pre><code><r:assets:all_#{type.to_s.pluralize}:each>...</r:assets:all_#{type.to_s.pluralize}:each></code></pre>
      }
      tag "assets:all_#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = tag.locals.page.send("all_#{type.to_s.pluralize}")
        tag.expand
      end
      tag "assets:all_#{type.to_s.pluralize}:each" do |tag|
        tag.render('asset_list', tag.attr.dup, &tag.block)
      end

      desc %{
        Loops through all the assets **not** of type #{type}.
        (Use r:assets:#{type.to_s.pluralize}:each if you want all the #{type} assets attached to the present page.)

        *Usage:* 
        <pre><code><r:assets:all_non_#{type.to_s.pluralize}:each>...</r:assets:all_non_#{type.to_s.pluralize}:each></code></pre>
      }
      tag "assets:all_non_#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = tag.locals.page.send("all_non_#{type.to_s.pluralize}")
        tag.expand
      end
      tag "assets:all_non_#{type.to_s.pluralize}:each" do |tag|
        tag.render('asset_list', tag.attr.dup, &tag.block)
      end

      #### Individual asset tags

      desc %{
        Renders the contained elements only if the asset is of the specified type.

        *Usage:* 
        <pre><code><r:assets:if_#{type}>...</r:assets:if_#{type}></code></pre>
      }
      tag "assets:if_#{type}" do |tag|
        tag.expand if tag.locals.asset.send("#{type}?".intern)
      end

      desc %{
        Renders the contained elements only if the asset is not of the specified type.

        *Usage:* 
        <pre><code><r:assets:unless_#{type}>...</r:assets:unless_#{type}></code></pre>
      }
      tag "assets:unless_#{type}" do |tag|
        tag.expand unless tag.locals.asset.send("#{type}?".intern)
      end

    end
    
    #### and some conveniences
    
    desc %{
      Renders an illustration block for the asset, with image and caption.

      *Usage:* 
      <pre><code><r:assets:image [title="asset_title"] [size="icon|thumbnail"]></code></pre>
    }    
    tag "assets:illustration" do |tag|
      options = tag.attr.dup
      options[:size] ||= 'illustration'
      tag.locals.asset = find_asset(tag, options)
      if tag.locals.asset.image?
        result = %{<div class="illustration">}
        result << tag.render('assets:image', options)
        result << %{<p class="caption">#{tag.render('assets:caption', options)}</p>}
        result << "</div>"
        result
      end
    end
    
    # simple, general purpose asset lister, useful because the assets:each tag sets tags.local.assets
    # and often we would rather set the collection first and then call the lister

    desc %{
      This is a general purpose asset lister. It wouldn't normally be accessed directly but a lot of other tags make use of it. 
      Unlike r:assets:each it assumes that we already have a collection of assets to work with.
    }
    tag 'asset_list' do |tag|
      raise TagError, "no assets for asset_list" unless tag.locals.assets
      result = []
      tag.locals.assets.each do |asset|
        tag.locals.asset = asset
        result << tag.expand
      end 
      result
    end
  end
end

