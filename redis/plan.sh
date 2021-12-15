pkg_name=redis
pkg_origin=chef
pkg_version="4.0.14"
pkg_description="Persistent key-value database, with built-in net interface"
pkg_upstream_url="http://redis.io/"
pkg_license=("Apache-2.0")
pkg_maintainer="The Chef Maintainers <humans@chef.io>"
pkg_deps=(core/redis)
pkg_svc_user="supermarket"
pkg_svc_group="supermarket"
pkg_svc_run="redis-server ${pkg_svc_config_path}/redis.config"
pkg_exports=(
  [port]=port
)
pkg_exposes=(port)

do_build() {
  return 0
}

do_install() {
  return 0
}
