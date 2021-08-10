# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.

# NOTE - Changed the serializer from :hybrid to :json as the rails
# has been upgraded to version:5 around 4 years back.
# Changing this now as the chances of preexisting cookies which are more than 4 years old is very less.
# In worst case the cookie will not be supported and the user will be asked to signin again.
# If that's an issue we will revert it back to :hybrid
Rails.application.config.action_dispatch.cookies_serializer = :json
