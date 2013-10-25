module OmniAuth
  module Policies
    class GitHub
      include OmniAuth::Policy

      key :github

      # @see OmniAuth::Policy#first_name
      def first_name
        split_name.first
      end

      # @see OmniAuth::Policy#last_name
      def last_name
        split_name.last
      end

      # @see OmniAuth::Policy#email
      def email
        auth['info']['email']
      end

      # @see OmniAuth::Policy#username
      def username
        auth['info']['nickname']
      end

      # @see OmniAuth::Policy#image_url
      def image_url
        auth['info']['image']
      end

      # @see OmniAuth::Policy#uid
      def uid
        auth['uid']
      end

      # @see OmniAuth::Policy#oauth_token
      def oauth_token
        auth['credentials']['token']
      end
    end
  end
end
