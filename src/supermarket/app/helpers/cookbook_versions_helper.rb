module CookbookVersionsHelper
  include MarkdownHelper

  #
  # Encapsulates the logic required to return an updated_at timestamp for an
  # Atom feed, while handling possibly empty collections
  #
  # @param collection [Array<Object>] some collection to be checked
  #
  # @return [ActiveSupport::TimeWithZone] the most recent updated_at, or right
  # now
  #
  def safe_updated_at(collection)
    if collection.present?
      collection.max_by(&:updated_at).updated_at
    else
      Time.zone.now
    end
  end

  #
  # Returns an abbreviated Changelog or a description if no Changelog is
  # available for the given CookbookVersion, suitable for showing in an Atom
  # feed.
  #
  # @param cookbook_version [CookbookVersion]
  #
  # @return [String] the Changelog and/or description
  #
  def cookbook_atom_content(cookbook_version)
    if cookbook_version.changelog.present?
      changelog = render_document(
        cookbook_version.changelog, cookbook_version.changelog_extension
      )
      changelog_link = link_to(
        'View Full Changelog',
        cookbook_version_url(
          cookbook_version.cookbook,
          cookbook_version,
          anchor: 'changelog'
        )
      )
      <<-EOS
        <p>#{cookbook_version.description}</p>
        #{HTML_Truncator.truncate(changelog, 30, ellipsis: '')}
        <p>#{changelog_link}</p>
      EOS
    else
      cookbook_version.description
    end
  end
  #
  # Returns the given README +content+ as it should be rendered. If the given
  # +extension+ indicates the README is formatted as Markdown, the +content+ is
  # rendered as such.
  #
  # @param content [String] the Document content
  # @param extension [String] the Document extension
  #
  # @return [String] the Document content ready to be rendered
  #
  def render_document(content, extension)
    if %w(md mdown markdown).include?(extension.downcase)
      render_markdown(content)
    else
      content
    end
  end
end
