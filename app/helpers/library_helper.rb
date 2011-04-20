require 'sanitize'

module LibraryHelper

  def clean_html(text)
    Sanitize.clean(text, Sanitize::Config::RELAXED)
  end

  def strip_html(text)
    Sanitize.clean(text)
  end

  def truncate_words(text='', options={})
    return '' if text.blank?
    ellipsis = options[:ellipsis] || '&hellip;'
    limit = (options[:limit] || 64).to_i
    text = strip_html(text) if options[:strip]
    words = text.split
    ellipsis = '' unless words.size > limit
    words[0..(limit-1)].join(" ") + ellipsis
  end 

end
