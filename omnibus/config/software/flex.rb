name "flex"
default_version "2.6.4"  # Adjust version if needed

license "BSD"
license_file "https://github.com/westes/flex/blob/master/COPYING"

version("2.6.4") do
  source url: "https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz",
         sha256: "e87aae82b8fbf081c7d5c366ec8d73e5c5e9c040b4a0eae2f35df2bd9a9a7df0"
end

relative_path "flex-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  command "make -j$(nproc)", env: env
  command "make install", env: env
end
