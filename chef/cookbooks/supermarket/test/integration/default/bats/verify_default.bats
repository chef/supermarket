@test "the unicorn socket is created" {
  test -S /tmp/.supermarket.sock.0
}

@test "listening on port 80" {
  ss -l -p '( sport = :80 )'
}

@test "default web page is Chef Supermarket" {
  wget -O - http://localhost 2> /dev/null | grep -q '<title>Chef Supermarket</title>'
}
