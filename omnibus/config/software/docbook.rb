name "docbook"
default_version "4.5"

dependency "libxml2"
dependency "libxslt"

source url: "https://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd",
       sha256: "e5616d42877c0630779143a6cada440b189538b87d07ad33c72c422af70aef78"

relative_path "docbook-4.5"

build do
  mkdir "#{install_dir}/embedded/share/xml/docbook-4.5"

  command "unzip -o #{project_dir}/docbook-xml-4.5.zip -d #{install_dir}/embedded/share/xml/"
end
