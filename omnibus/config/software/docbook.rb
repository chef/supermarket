name "docbook"
default_version "4.5"

dependency "libxml2"
dependency "libxslt"

source url: "https://www.oasis-open.org/docbook/xml/4.5/docbook-xml-4.5.zip",
       sha256: "4e4e037a2b83c98c6c94818390d4bdd3f6e10f6ec62dd79188594e26190dc7b4"

# relative_path "docbook-4.5"

build do
  mkdir "#{install_dir}/embedded/share/xml/docbook-4.5"

  # command "unzip -o #{project_dir}/docbook-xml-4.5.zip -d #{install_dir}/embedded/share/xml/"
end
