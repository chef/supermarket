require 'html/pipeline'

module MarkdownHelper
  #
  # Renders markdown as escaped HTML.
  #
  # @param text [String] markdown to be rendered
  #
  # @return [String] escaped HTML.
  #
  def render_markdown(text)
    context = {
      base_url: Supermarket::Host.full_url,
      http_url: Supermarket::Host.full_url
    }

    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter,
      HTML::Pipeline::ImageMaxWidthFilter,
      HTML::Pipeline::TableOfContentsFilter,
      HTML::Pipeline::HttpsFilter,
      LinksTargetNewWindowFilter,
      ImgProtocolRelativeFilter,
      HTML::Pipeline::MentionFilter
    ], context.merge(gfm: true)

    result = pipeline.call(text)
    result[:output].to_s.html_safe
  end

  class LinksTargetNewWindowFilter < HTML::Pipeline::HttpsFilter
    #
    # Sets every link in a document to open in a new browser window or tab
    #
    def call
      doc.search("a").each do |link|
        link["target"] = "_blank"
      end
      doc
    end
  end

  class ImgProtocolRelativeFilter < HTML::Pipeline::HttpsFilter
    #
    # Converts the scheme of every img tag http/https src attribute
    # to be a relative protocol
    #
    def call
      doc.search("img").each do |img|
        next if img['src'].nil?
        src = img['src'].strip
        if src.start_with? 'http'
          img["src"] = src.sub(/\Ahttps?:/, '')
        end
      end
      doc
    end
  end
end
