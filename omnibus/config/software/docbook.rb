name "docbook"
default_version "4.5"

dependency "libxml2"
dependency "libxslt"

source url: "http://deb.debian.org/debian/pool/main/d/docbook/docbook_4.5.orig.tar.gz",
       sha256: "7fed45602dc8734cc95829eec6d965750e5fdf2d3f1c1627659003939e20f419"

relative_path "docbook-4.5"

build do
  mkdir "#{install_dir}/embedded/share/xml/docbook-4.5"
  command "cp -r . #{install_dir}/embedded/share/xml/docbook-4.5"
end
