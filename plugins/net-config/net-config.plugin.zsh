#!/bin/zsh
alias lslisten="netstat -lnptu"

create_zone() {
    local zonename=$1
    iptables -N Zone${zonename}Input
    iptables -N Zone${zonename}Forward
    iptables -t nat -N Zone${zonename}Postrouting
}

add_to_zone() {
    local zonename=$1; shift
    local iface=
    for iface in $@; do
        iptables -A INPUT -i $iface -j Zone${zonename}Input
        iptables -A FORWARD -i $iface -j Zone${zonename}Forward
        iptables -t nat -A POSTROUTING -o $iface -j Zone${zonename}Postrouting
    done
}

portmap() {
    local wanaddr=$1; local wanport=$2; local lanaddr=$3; local lanport=$4; local protocol=$5
    local waniface=$(netstat -ie | grep -B1 $wanaddr | head -n 1 | awk '{print $1;}')
    [[ -z "$waniface" || -z "$wanaddr" || -z "$wanport" || -z "$lanaddr" || -z "$lanport" || -z "$protocol" ]] && return
    iptables -A PortmapFilterForward -i "$waniface" -d $lanaddr -p $protocol -m $protocol --dport "$lanport" -j ACCEPT
    iptables -t nat -A PortmapNatPrerouting -d $wanaddr -p $protocol -m $protocol --dport $wanport -j DNAT --to $lanaddr:$lanport
    local laniface=$(ip route get $lanaddr | head -n 1 | awk '{ print $3; }')
    local lanmask=$(sipcalc $laniface -i | grep "Network mask" | head -n 1 | awk '{print $4;}')
    local lannet=$(netmask $lanaddr/$lanmask | awk '{print $1;}')
    iptables -t nat -A PortmapNatPostrouting -s $lannet -d $lanaddr -j SNAT --to-source "$wanaddr"
}

tcpmap() {
    portmap $1 $2 $3 $4 tcp
}

udpmap() {
    portmap $1 $2 $3 $4 udp
}

dportmap() {
    local wanaddr=$1; local wanport=$2; local lanaddr=$3; local lanport=$4; local protocol=$5
    local waniface=$(netstat -ie | grep -B1 $wanaddr | head -n 1 | awk '{print $1;}')
    [[ -z "$waniface" || -z "$wanaddr" || -z "$wanport" || -z "$lanaddr" || -z "$lanport" || -z "$protocol" ]] && return
    iptables -D PortmapFilterForward -i "$waniface" -d $lanaddr -p $protocol -m $protocol --dport "$lanport" -j ACCEPT
    iptables -t nat -D PortmapNatPrerouting -d $wanaddr -p $protocol -m $protocol --dport $wanport -j DNAT --to $lanaddr:$lanport
    local laniface=$(ip route get $lanaddr | head -n 1 | awk '{ print $3; }')
    local lanmask=$(sipcalc $laniface -i | grep "Network mask" | head -n 1 | awk '{print $4;}')
    local lannet=$(netmask $lanaddr/$lanmask | awk '{print $1;}')
    iptables -t nat -D PortmapNatPostrouting -s $lannet -d $lanaddr -j SNAT --to-source "$wanaddr"
}

dtcpmap() {
    dportmap $1 $2 $3 $4 tcp
}

dudpmap() {
    dportmap $1 $2 $3 $4 udp
}

dnat() {
    local waniface=$1
    local wanaddr=$2
    local lanaddr=$3
    [[ -z "$waniface" || -z "$wanaddr" || -z "$lanaddr" ]] && return
    iptables -A PortmapFilterForward -i "$waniface" -d $lanaddr -j ACCEPT
    iptables -t nat -A PortmapNatPrerouting -d $wanaddr -j DNAT --to-destination $lanaddr
}

snat() {
    local waniface=$1
    local lanaddr=$2
    local wanaddr=$3
    [[ -z "$waniface" || -z "$wanaddr" || -z "$lanaddr" ]] && return
    iptables -t nat -A PortmapNatPostrouting -o "$waniface" -s $lanaddr -j SNAT --to-source $wanaddr
}

o2onat() {
    # 1:1映射，我们在后面会讨论
    local waniface=$1
    local wanaddr=$2
    local lanaddr=$3
    dnat $waniface $wanaddr $lanaddr
    snat $waniface $lanaddr $wanaddr
}

setup_nat_chains() {
    while read table builtin_chain user_chain; do
        if iptables -t $table -n --list "$user_chain" >/dev/null 2>&1; then
            iptables -t $table -F $user_chain
            iptables -t $table -D $builtin_chain -j $user_chain >/dev/null 2>&1 || :
            iptables -t $table -X $user_chain
        fi
        iptables -t $table -N $user_chain
        iptables -t $table -A $builtin_chain -j $user_chain
    done <<EOF
    filter FORWARD     PortmapFilterForward
    nat    PREROUTING  PortmapNatPrerouting
    nat    POSTROUTING PortmapNatPostrouting
EOF
}

function addtunnel()
{
    local iface_name=$1
    local local_ip=$2
    local remote_ip=$3
    local local_gnet_ip=$4
    local remote_gnet_ip=$5
    local remote_gnet_subnet=$6

    local iface_file="/etc/network/interfaces.d/gre-${iface_name}"

    cat << EOF | tee ${iface_file}
    auto ${iface_name}
    iface ${iface_name} inet static
    address ${local_gnet_ip}
    netmask 255.255.240.0
    pre-up ip tunnel add ${iface_name} mode gre remote ${remote_ip} local ${local_ip} ttl 255
    up ifconfig ${iface_name} multicast
    up ip route replace ${remote_gnet_subnet} via ${remote_gnet_ip} dev ${iface_name} table gnet
    pointopoint ${remote_gnet_ip}
    post-down ip tunnel del ${iface_name}
EOF

}

function addgnet()
{
    sed -i "1iip rule add preference 500 to 100.64.0.0/10 lookup gnet\n" /etc/rc.local
    echo "\n500     gnet" >> /etc/iproute2/rt_tables
}

function addroutefromlist() {
    local iplist=$1
    local via=$2
    local dev=$3
    local table=$4
    cat $iplist | awk "{ printf(\"route replace %s via $via dev $dev table $table\n\",\$1)}" | ip --batch -
}

function nsexec() {
    if [[ -z $NS ]]; then
        local NS=$1
        shift
    fi
    ip netns exec $NS "$@"
}

function nsip() {
    if [[ -z $NS ]]; then
        local NS=$1
        shift
    fi
    ip netns exec $NS ip "$@"
}

