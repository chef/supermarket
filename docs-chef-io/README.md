# Chef Supermarket Documentation

The Chef Supermarket Documentation is deployed on https://docs.chef.io/supermarket/ using Hugo and Netlify.

## The Fastest Way to Contribute

There are two steps to updating the Chef Supermarket documentation:

1. Update the documentation in the `chef/supermarket` repository.
1. Update the Chef Supermarket repository module in `chef/chef-web-docs`.

### Update Content in `chef/supermarket`

The fastest way to change the documentation is to edit a page on the
GitHub website using the GitHub UI.

To perform edits using the GitHub UI, click on the `[edit on GitHub]` link at
the top of the page that you want to edit. The link takes you to that topic's GitHub
page. In GitHub, click on the pencil icon and make your changes. You can preview
how they'll look right on the page ("Preview Changes" tab).

We also require contributors to include their [DCO signoff](https://github.com/chef/chef/blob/master/CONTRIBUTING.md#developer-certification-of-origin-dco)
in the comment section of every pull request, except for obvious fixes. You can
add your DCO signoff to the comments by including `Signed-off-by:`, followed by
your name and email address, like this:

`Signed-off-by: Julia Child <juliachild@chef.io>`

See our [blog post](https://blog.chef.io/introducing-developer-certificate-of-origin/)
for more information about the DCO and why we require it.

After you've added your DCO signoff, add a comment about your proposed change,
then click on the "Propose file change" button at the bottom of the page and
confirm your pull request. The CI system will do some checks and add a comment
to your PR with the results.

The Chef documentation team can normally merge pull requests within seven days.
We'll fix build errors before we merge, so you don't have to
worry about passing all the CI checks, but it might add an extra
few days. The important part is submitting your change.

### Update the Chef Supermarket Repository Module In `chef/chef-web-docs`

We use [Hugo modules](https://gohugo.io/hugo-modules/) to build Chef's documentation from multiple repositories. The documentation from those repositories are [vendored](https://gohugo.io/hugo-modules/use-modules/#vendor-your-modules) in chef-web-docs.

To update the Hugo module for documentation in `chef/supermarket`:

1. Make sure your documentation changes are merged into main in `chef/supermarket`.
2. Ask the Docs Team to update the Hugo module in the Docs-Team Slack channel, or see the [instructions](https://github.com/chef/chef-web-docs#update-hugo-modules) in chef-web-docs for updating Supermarket Hugo module and submit a PR.

## Local Development Environment

We use [Hugo](https://gohugo.io/), [Go](https://golang.org/), [NPM](https://www.npmjs.com/),
[go-swagger](https://goswagger.io/install.html), and [jq](https://stedolan.github.io/jq/).
You will need Hugo 0.61 or higher installed and running to build and view our documentation properly.

To install Hugo, NPM, and Go on Windows and macOS:

- On macOS run: `brew tap go-swagger/go-swagger && brew install go-swagger hugo node go jq`
- On Windows run: `choco install hugo nodejs golang jq`
  - See the Go-Swagger [docs to install go-swagger](https://goswagger.io/install.html)

To install Hugo on Linux, run:

- `apt install -y build-essential`
- `sudo apt-get install jq`
- `snap install node --classic --channel=12`
- `snap install hugo --channel=extended`
- See the Go-Swagger [docs](https://goswagger.io/install.html) to install go-swagger

1. (Optional) [Install cspell](https://github.com/streetsidesoftware/cspell/tree/master/packages/cspell)

    To be able to run the optional `make spellcheck` task you'll need to install `cspell`:

    ```shell
    npm install -g cspell
    ```

## Preview Chef Supermarket Documentation

There are two ways to preview the documentation in `chef/supermarket`:

- Submit a PR
- `make serve`

### Submit a PR

When you submit a PR to `chef/supermarket`, Netlify will build the documentation
and add a notification to the GitHub pull request page. You can review your
documentation changes as they would appear on docs.chef.io.

### make serve

Running `make serve` will clone a copy of `chef/chef-web-docs` into `docs-chef-io`.
That copy will be configured to build the Supermarket documentation from `docs-chef-io`
and live reload if any changes are made while the Hugo server is running.

- Run `make serve`
- go to http://localhost:1313

## Clean Your Local Environment

If you have a local copy of `chef-web-docs` cloned into `docs-chef-io`,
running `make clean_all` will delete `chef-web-docs`. Hugo will reinstall these
the next time you run `make serve`.

## Creating New Pages

Please keep all of the Chef Supermarket documentation in the `content/supermarket` directory.
To add a new Markdown file, run the following command from the `docs-chef-io` directory:

```
hugo new content/supermarket/<filename>.md
```

This will create a draft page with enough front matter to get you going.

Hugo uses [Goldmark](https://github.com/yuin/goldmark) which is a
superset of Markdown that includes GitHub styled tables, task lists, and
definition lists.

See our [Style Guide](https://docs.chef.io/style_guide/) for more information
about formatting documentation using Markdown.

## What Is Happening Behind the Scenes

The [Chef Documentation](https://docs.chef.io) site uses [Hugo modules](https://gohugo.io/hugo-modules/)
to load content directly from `chef/supermarket/docs-chef-io`. Every time
`chef/supermarket` is promoted to stable, Expeditor submits a PR to chef-web-docs to
update the version of the `chef/supermarket` repository that Hugo uses to build Chef
Supermarket documentation on the [Chef Documentation](https://docs.chef.io) site.
This is handled by the Expeditor subscriptions in the `chef/chef-web-docs` GitHub repository.

## Documentation Feedback

We love getting feedback, questions, or comments.

**Email**

Send an email to Chef-Docs@progress.com for documentation bugs,
ideas, thoughts, and suggestions. This email address is not a
support email address. If you need support, contact [Chef Support](https://www.chef.io/support/).

**GitHub issues**

Submit an issue to the [Supermarket repo](https://github.com/chef/supermarket/issues)
for "important" documentation bugs that may need visibility among a larger group,
especially in situations where a doc bug may also surface a product bug.

Submit an issue to [chef-web-docs](https://github.com/chef/chef-web-docs/issues) for
documentation feature requests and minor documentation issues.
