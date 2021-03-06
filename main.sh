#!/usr/bin/env bash

source config.ini

export INIT_URL=https://raw.githubusercontent.com/bunam/zeromac/master/init/init.sh

# mini tools box
function echoer() { echo "$@" 1>&2 ; }
function die() { echoer "$@" ; exit 1 ; }
function px_str_AntiSlashNtoN() { awk '{gsub(/\\n/,"\n'${1}'")}1' ; }
function px_str_AntiSlashTtoT() { awk '{gsub(/\\t/,"\t")}1' ; }
function px_autodoc() { sed -n -e '/# main/,$p' "${1}" | grep -E "^[$(printf '\t')]+[a-z0-9]+){1} #" | sed -e "s@) # @ @g" | px_str_AntiSlashNtoN "\t\t" | px_str_AntiSlashTtoT ; }

if (command -v readlink &> /dev/null) ; then
	#shellcheck disable=SC2155
	export CUR_DIR="$( cd "$( dirname "$(readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}" )" )" && pwd )"
else
	#shellcheck disable=SC2155
	export CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source config.ini || die "Troubles to load config.ini !"

# API related
function zm_machines_list() {
	curl -sS "https://api.zeromac.com/v1/machines" \
    -H "Authorization: Token ${API_TOKEN}" 
}

function zm_machine_info() {
	curl -sS "https://api.zeromac.com/v1/machine/${1}" \
    -H "Authorization: Token ${API_TOKEN}" 
}

function zm_machine_create() {
	curl -sS "https://api.zeromac.com/v1/machines" \
    -H "Authorization: Token ${API_TOKEN}" \
    -H "Content-type: application/json" \
    --data '{
      "name": "Test Box 1",
      "type": "1cpu",
      "password": "'"$PASSWORD"'",
      "ssh_pubkey": "'"$SSH_PUB_KEY"'",
      "image": "10.14"
    }'
}

function zm_machine_delete() {
	curl -sS "https://api.zeromac.com/v1/machine/${1}" \
	-X DELETE \
    -H "Authorization: Token ${API_TOKEN}" 
}

# tooling
function machine_create() {
	retJSON=$(zm_machine_create)
	jq . <<<$retJSON
	mess=$(jq -e '.error' <<<$retJSON ) && die "Failed to create machine ! : $mess"
	id=$(jq -e --raw-output '.id' <<<$retJSON ) || die "Failed to having machine id !"
	# waiting a little for having the ip
	# TODO do a loop until having IP
	sleep 40
	machine_info "${id}"
}

function machine_init() {
	# 1 : machine id
	machine_info "${1}"
 	rsync --stats --human-readable -v -a "${CUR_DIR}" "admin@${public_ip}:"
	ssh -t admin@$public_ip 'cd zeromac ; ./init/init.sh '
}

function machine_info() {
	# 1 : machine id
	machineInfoJSON=$(zm_machine_info "${1}")
	jq . <<<$machineInfoJSON
	public_ip=$(jq -e --raw-output '.data.public_ip' <<<$machineInfoJSON ) || die "Failed to having machine public IP !"
}

function machine_delete() {
	# 1 : machine id
	retJSON=$(zm_machine_delete "${1}")
	jq . <<<$retJSON
}

function machine_list() {
	machinelistJSON=$(zm_machines_list)
	echo $machinelistJSON | jq .
}

# main
case "${1}" in

	list) # : list of created machine
		machine_list
		;;
		
	create) # : create new machine
		machine_create
		;;

	info) # <id> : info on a machine
		shift 1
		machine_info "${1}"
		;;
		
	delete) # <id> : delete a machine
		shift 1
		machine_delete "${1}"
		;;
		
	init) # <id> : run init a machine
		shift 1
		machine_init "${1}"
		;;
	*)
		echo "Use : $0"
		echo "Loaded config : config.ini"
		px_autodoc "${0}" | sort
		;;

esac
	


