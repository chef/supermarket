module CookbookVersionsHelper
  #
  # Constructs the full URL for the given +CookbookVersion+
  #
  # @todo construct an S3 URL if we're using S3 for tarball storage
  #
  # @param cookbook_version [CookbookVersion]
  #
  # @return [String] the tarball URL
  #
  def tarball_url(cookbook_version)
    URI.join(request.url, cookbook_version.tarball.url).to_s
  end
end
