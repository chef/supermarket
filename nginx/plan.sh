pkg_name=supermarket-nginx
pkg_origin=chef
pkg_version="1.19.3.1"
pkg_maintainer="The Chef Maintainers <humans@chef.io>"
pkg_license=("Apache-2.0")
pkg_deps=(core/openresty)
pkg_svc_user="root"
pkg_svc_group="root"
pkg_svc_run="nginx -c $pkg_svc_config_path/nginx.conf"

pkg_binds=(
  [rails]="port http-port https-port force-ssl fqdn fqdn-sanitized"
)

do_build() {
  return 0
}

do_install() {
  return 0
}
