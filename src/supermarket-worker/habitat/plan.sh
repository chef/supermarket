pkg_name=supermarket-worker
pkg_origin=chefops
pkg_version="$(cat $PLAN_CONTEXT/../../../VERSION)"
pkg_maintainer="Chef Operations <ops@chef.io>"
pkg_license=('Apache-2.0')
pkg_deps=(chefops/supermarket)
pkg_svc_user="root"
pkg_svc_run=(supermarket-worker)

do_build() {
  return 0
}

do_install() {
  return 0
}
