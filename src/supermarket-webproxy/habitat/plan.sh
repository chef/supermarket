pkg_name=supermarket-webproxy
pkg_origin=tcate
pkg_version="$(cat $PLAN_CONTEXT/../../../VERSION)"
pkg_maintainer="The Chef Server Maintainers <support@chef.io>"
pkg_license=('Apache-2.0')
pkg_deps=(
  core/curl
  core/libossp-uuid
  chef-server/openresty-noroot
)
pkg_build_deps=()
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)
pkg_exposes=(port ssl-port)
pkg_exports=(
    [port]=http.port
    [ssl-port]=https.port
)
pkg_description="Openresty configuration for supermarket server"
pkg_upstream_url="https://docs.chef.io/supermarket.html#private-supermarket"
pkg_svc_run="openresty -c ${pkg_svc_config_path}/nginx.conf -p ${pkg_svc_var_path}"

do_download() {
  return 0
}

do_unpack() {
  return 0
}

do_build() {
  return 0
}

do_install() {
  return 0
}

do_strip() {
  return 0
}


## NOT RIGHT
do_after() {
    return 0
}
