# Check if folder $1 exists and echo $2 if not
directory_exists() { [[ ! -d "$1" ]] && { echo "$2"; exit 1; } }

# Check if file $1 exists and echo $2 if not
file_exists() { [[ ! -e "$1" ]] && { echo "$2"; exit 1; } }

# Check if $1 runs and returns with 0 status
is_runnable() { $1 >/dev/null 2>&1 || { echo "$2"; exit 1; } }

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

# From: http://stackoverflow.com/a/21189044/843067
#
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
