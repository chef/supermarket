# we use pushd/popd here, and /bin/sh of our chefes/buildkite image is not bash
# so we have to override the default shell here
SHELL=bash

preview_netlify: chef_web_docs
	cp -R content/* chef-web-docs/_vendor/github.com/chef/supermarket/docs-chef-io/content
	cp -R config.toml chef-web-docs/_vendor/github.com/chef/supermarket/docs-chef-io/config.toml
	pushd chef-web-docs && make bundle; hugo --buildFuture --gc --minify && popd

serve: chef_web_docs
	echo "replace github.com/chef/supermarket/docs-chef-io => ../" >> chef-web-docs/go.mod
	pushd chef-web-docs && make bundle; hugo server --buildDrafts --buildFuture --noHTTPCache --ignoreVendorPaths "github.com/chef/supermarket/**" && popd

chef_web_docs:
	if [ -d "chef-web-docs/" ]; then \
		pushd chef-web-docs && git reset HEAD --hard; git clean -fd; git pull --ff-only origin main; rm -rf public && popd; \
	else \
		git clone https://github.com/chef/chef-web-docs.git; \
	fi

clean_all:
	rm -rf chef-web-docs

