#!/bin/bash -e

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/chnroute.XXXXXX)

DIST_FILE_IPV4="dist/chnroute/chnroute.txt"
DIST_FILE_IPV6="dist/chnroute/chnroute-v6.txt"
DIST_FILE_CHN="dist/chnroute/chinalist.txt"
DIST_FILE_GFW="dist/chnroute/gfwlist.txt"
DIST_DIR="$(dirname $DIST_FILE_IPV4)"
DIST_NAME_IPV4="$(basename $DIST_FILE_IPV4)"
DIST_NAME_IPV6="$(basename $DIST_FILE_IPV6)"
DIST_NAME_CHN="$(basename $DIST_FILE_CHN)"
DIST_NAME_GFW="$(basename $DIST_FILE_GFW)"

APNIC_URL="https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"
IPIP_URL="https://github.com/17mon/china_ip_list/raw/master/china_ip_list.txt"
CLANG_URL="https://ispip.clang.cn/all_cn.txt"
CHUNZHEN_URL="https://github.com/metowolf/iplist/raw/master/data/special/china.txt"
CHINALIST_URL="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
GFW_URL="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt"
GFD_URL="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/greatfire.txt"
APNIC_LIST="apnic.txt"
IPIP_LIST="ipip.txt"
CLANG_LIST="clang.txt"
CHUNZHEN_LIST="chunzhen.txt"
CHINALIST_LIST="chn.txt"
GFW_LIST="gfw.txt"
GFD_LIST="gfd.txt"

function fetch_data() {
  cd $TMP_DIR

  curl -sSL -4 --connect-timeout 10 $APNIC_URL -o apnic.txt
  curl -sSL -4 --connect-timeout 10 $IPIP_URL -o ipip.txt
  curl -sSL -4 --connect-timeout 10 $CLANG_URL -o clang.txt
  curl -sSL -4 --connect-timeout 10 $CHUNZHEN_URL -o chunzhen.txt
  curl -sSL -4 --connect-timeout 10 $CHINALIST_URL -o chn.txt
  curl -sSL -4 --connect-timeout 10 $GFW_URL -o gfw.txt
  curl -sSL -4 --connect-timeout 10 $GFD_URL -o gfd.txt

  cd $CUR_DIR
}

function gen_ipv4_chnroute() {
  cd $TMP_DIR

  local apnic_tmp="apnic.tmp"
  local ipip_tmp="ipip.tmp"
  local clang_tmp="clang.tmp"
  local chunzhen_tmp="chunzhen.tmp"

  cat apnic.txt | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > $apnic_tmp
  cat ipip.txt > $ipip_tmp
  cat clang.txt > $clang_tmp
  cat chunzhen.txt > $chunzhen_tmp
  cat $apnic_tmp $ipip_tmp $clang_tmp $chunzhen_tmp | aggregate -q > $DIST_NAME_IPV4

  cd $CUR_DIR
}

function gen_ipv6_chnroute() {
  cd $TMP_DIR

  cat apnic.txt | grep ipv6 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, $5) }' > $DIST_NAME_IPV6

  cd $CUR_DIR
}

function gen_chinalist() {
  cd $TMP_DIR
  cat chn.txt | sed '/^[[:space:]]*$/d' | sed '/^#/ d' | awk '{split($0, arr, "/"); print arr[2]}' | grep "\." | awk '!x[$0]++' > $DIST_NAME_CHN
  cd $CUR_DIR
}

function gen_gfwlist() {
  cd $TMP_DIR
  cat gfw.txt gfd.txt > $DIST_NAME_GFW
  cd $CUR_DIR
}

function dist_release() {
  mkdir -p $DIST_DIR
  cp $TMP_DIR/$DIST_NAME_IPV4 $DIST_FILE_IPV4
  cp $TMP_DIR/$DIST_NAME_IPV6 $DIST_FILE_IPV6
  cp $TMP_DIR/$DIST_NAME_CHN $DIST_FILE_CHN
  cp $TMP_DIR/$DIST_NAME_GFW $DIST_FILE_GFW
}

function clean_up() {
  rm -r $TMP_DIR
  echo "[chnroute]: OK."
}

fetch_data
gen_ipv4_chnroute
gen_ipv6_chnroute
gen_chinalist
gen_gfwlist
dist_release
clean_up
curl -s https://purge.jsdelivr.net/gh/QiuSimons/Chnroute/dist/chnroute/chnroute.txt
curl -s https://purge.jsdelivr.net/gh/QiuSimons/Chnroute/dist/chnroute/chnroute-v6.txt
curl -s https://purge.jsdelivr.net/gh/QiuSimons/Chnroute/dist/chnroute/chinalist.txt
curl -s https://purge.jsdelivr.net/gh/QiuSimons/Chnroute/dist/chnroute/gfwlist.txt
