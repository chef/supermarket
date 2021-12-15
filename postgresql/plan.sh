# shellcheck disable=SC2164
pkg_name=supermarket-postgresql
pkg_version=9.6.21
pkg_origin="chef"
pkg_maintainer="The Chef Maintainers <humans@chef.io>"
pkg_description="PostgreSQL is a powerful, open source object-relational database system."
pkg_upstream_url="https://www.postgresql.org/"
pkg_license=('Apache-2.0')
pkg_deps=(core/postgresql/"${pkg_version}" core/busybox-static)
pkg_svc_user="root"
pkg_svc_group="root"

pkg_exports=(
  [port]=port
  [username]=superuser.name
  [password]=superuser.password
)

do_build() {
  return 0
}

do_install() {
  return 0
}
