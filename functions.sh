# Check if folder $1 exists
checkdir() { [[ ! -d "$1" ]] && { echo "ERROR: missing $1 dir!"; exit 1; } }

# Check if file $1 exists
checkiso() { [[ ! -e "$1" ]] && { echo "ERROR: missing $1 file!"; exit 1; } }

# Wait until VM with name $1 powers down
wait_vm_quit() {
    echo "Waiting $1 to power-off"
    while [ `vboxmanage list runningvms | grep "$1" | wc -l` == "1" ]; do
        echo -n "."
        sleep 5
    done
    echo "...and it's gone"
}

# Render template $1
render_template() {
  eval "echo \"$(cat $1)\""
}

shout() {
    echo
    echo "========================================================================"
    echo $1
    echo "========================================================================"
    echo
}
