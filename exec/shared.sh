###
# Vagrant stuff
###

vagrant_up() {
  vagrant up --provision
}

vagrant_ssh() {
  config=$(vagrant ssh-config)
  host=$(echo "$config" | grep "HostName" -m1 | cut -d' ' -f4)
  user=$(echo "$config" | grep "User" -m1 | cut -d' ' -f4)
  port=$(echo "$config" | grep "Port" -m1 | cut -d' ' -f4)
  identity_file=$(echo "$config" | grep "IdentityFile" -m1 | cut -d' ' -f4)

  ssh $user@$host \
    -p $port \
    -i $identity_file \
    -o DSAAuthentication=yes \
    -o LogLevel=FATAL \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null "$@"
}

vagrant_running() {
  vagrant status | grep 'running' 2>&1 > /dev/null
  return $?
}

vagrant_installed() {
  if command -v vagrant >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

###
# Supermarket stuff
###

in_supermarket() {
  if ! vagrant_installed; then
    echo "Vagrant is not installed! Please install Vagrant by visiting" \
         " http://downloads.vagrantup.com/." >&2
    exit 1
  fi

  if ! vagrant_running; then
    vagrant_up
  fi

  vagrant_ssh -t "(cd /supermarket && $@)"
}
