name "icu"
default_version "73.2"  # Set desired ICU version

license "ICU"
license_file "https://github.com/unicode-org/icu/blob/main/icu4c/LICENSE"

version("73.2") do
  source url: "https://github.com/unicode-org/icu/releases/download/release-73-2/icu4c-73_2-src.tgz",
         sha256: "818a80712ed3caacd9b652305e01afc7fa167e6f2e94996da44b90c2ab604ce1"
end

relative_path "icu/source"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  command "make -j$(nproc)", env: env
  command "make install", env: env
end
