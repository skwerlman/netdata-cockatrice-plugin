# cockatrice netdata plugin
# (C) 2018 skwerlman <skw@tetrarch.co>
# MIT/EXPAT

cockatrice_update_every=15
cockatrice_priority=10000

cockatrice_database_user=
cockatrice_database_password=
cockatrice_database_table=
cockatrice_database_prefix=

cockatrice_id_server=
cockatrice_timest=
cockatrice_uptime=
cockatrice_users_count=
cockatrice_games_count=
cockatrice_rx_bytes=
cockatrice_tx_bytes=

cockatrice_get() {
	local nl='
'
	local data=$(mysql -u $cockatrice_database_user -p$cockatrice_database_password $cockatrice_database_table -e "select * from ${cockatrice_database_prefix}_uptime order by timest desc limit 1;" 2>/tmp/netdata-cockatrice-errors)
	local resp=$?
	if [ $resp -ne 0 ] ; then
		error "call to mysql returned $resp"
		error $(</tmp/netdata-cockatrice-errors)
		return 1
	fi
	#error $(</tmp/netdata-cockatrice-errors)
	local data=${data##*"$nl"}
	local oifs=$IFS
	IFS="	" # a tab
	local data=($data)
	IFS=$oifs
	cockatrice_id_server=${data[0]}
	cockatrice_timest=${data[1]}
	cockatrice_uptime=${data[2]}
	cockatrice_users_count=${data[3]}
	cockatrice_mods_count=${data[4]}
	cockatrice_mods_list=${data[5]}
	cockatrice_games_count=${data[6]}
	cockatrice_rx_bytes=${data[7]}
	cockatrice_tx_bytes=${data[8]}
	return 0
}

cockatrice_check() {
	[[ ${cockatrice_database_user:?} ]] || (error "manual configuration required: you have to set cockatrice_database_user in cockatrice.conf to start the Cockatrice plugin." && return 1)
	[[ ${cockatrice_database_password:?} ]] || (error "manual configuration required: you have to set cockatrice_database_password in cockatrice.conf to start the Cockatrice plugin." && return 1)
	[[ ${cockatrice_database_table:?} ]] || (error "manual configuration required: you have to set cockatrice_database_table in cockatrice.conf to start the Cockatrice plugin." && return 1)
	[[ ${cockatrice_database_prefix:?} ]] || (error "manual configuration required: you have to set cockatrice_database_prefix in cockatrice.conf to start the Cockatrice plugin." && return 1)
	cockatrice_get || return 1
	return 0
}

cockatrice_create() {
	cat <<EOF
CHART cockatrice.uptime '' "uptime" "seconds" "Uptime" cockatrice line $((cockatrice_priority)) $cockatrice_update_every
DIMENSION uptime '' absolute 1 1
CHART cockatrice.stats '' "statistics" '' "Statistics" cockatrice line $((cockatrice_priority + 1)) $cockatrice_update_every
DIMENSION users '' absolute 1 1
DIMENSION mods '' absolute 1 1
DIMENSION games '' absolute 1 1
CHART cockatrice.network '' "network" 'bytes/s' 'Network Usage' cockatrice line $((cockatrice_priority + 1)) $cockatrice_update_every
DIMENSION rxbytes "received" absolute 1 15
DIMENSION txbytes "sent" absolute 1 15
EOF
	return 0
}

cockatrice_update() {
	cockatrice_get || return 1
	cat <<VALUESEOF
BEGIN cockatrice.uptime $1
SET uptime = $cockatrice_uptime
END
BEGIN cockatrice.stats $1
SET users = $cockatrice_users_count
SET mods = $cockatrice_mods_count
SET games = $cockatrice_games_count
END
BEGIN cockatrice.network $1
SET rxbytes = $cockatrice_rx_bytes
SET txbytes = $cockatrice_tx_bytes
END
VALUESEOF
	return 0
}
