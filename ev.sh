#!/usr/bin/env bash

set -e

if [ $# != 2 ]; then
  echo "add mode"
  exit 2;
fi

echo "${PREFIX}${TARGET}"


TARGET=$1
OUT_DIR=$2
PREFIX=$(date +'%Y-%m-%d-%I-%M-%S_')

args='-O UserKnownHostsFile=/dev/null -O StrictHostKeyChecking=no'

pssh $args -h ~/dcache_evaluation -i --timeout=15 'sudo docker restart  $(sudo docker ps -aqf "publish=53")'

if [ "$1" = "forward" ]; then
  ssh dns-cache.bootjp.me 'sudo docker restart $(sudo docker ps -aqf "publish=53")'
fi

echo "set test data"
cat apps/set/command.txt | redis-cli --pipe -h queue.bootjp.me

sleep 10

set +e
echo start
pssh $args -h ~/dcache_evaluation --timeout=0 "sudo docker run --rm -e REDIS_HOST=10.146.0.93:6379 --net=host --cap-add=SYS_ADMIN ghcr.io/bootjp/top1000load:latest"

mkdir -p "$OUT_DIR/${PREFIX}${TARGET}/metrics"


pssh -O UserKnownHostsFile=/dev/null -O StrictHostKeyChecking=no -h ~/dcache_evaluation -o $OUT_DIR/${PREFIX}${TARGET}/metrics --timeout=30 "curl -s localhost:9253/metrics | grep -v ^# "

echo "metrics path $OUT_DIR/${PREFIX}${TARGET}/metrics"

echo error total
echo $(cat $OUT_DIR/${PREFIX}${TARGET}/metrics/* | grep 'coredns_forward_responses_total{rcode="SERVFAIL"' | cut -d ' ' -f 2 |  awk '{a+=$1}END{print(a)}')
echo nx domain total
echo $(cat $OUT_DIR/${PREFIX}${TARGET}/metrics/* | grep 'coredns_forward_responses_total{rcode="NXDOMAIN",' | cut -d ' ' -f 2 |  awk '{a+=$1}END{print(a)}')
echo total duration sum
total_duration=$(cat ${OUT_DIR}/${PREFIX}${TARGET}/metrics/* | grep coredns_dns_request_duration_seconds_sum | cut -d ' ' -f2 | awk '{a+=$1}END{print(a)}')
echo total request
total_req=$(cat $OUT_DIR/${PREFIX}${TARGET}/metrics/* | grep coredns_dns_requests_total | cut -d ' ' -f2 | awk '{a+=$1}END{print(a)}')
echo $total_req
echo cache hit total
cache_hit=$(cat $OUT_DIR/${PREFIX}${TARGET}/metrics/* | grep -e cache -e redisc | grep hit  | grep total |  grep -v coredns_forward_conn_cache_hits_total | cut -d ' ' -f 2 |  awk '{a+=$1}END{print(a)}')
echo $cache_hit
echo hitrate
bc -l <<< "$cache_hit/$total_req"

echo -e "total_duration\t$total_duration" >> $OUT_DIR/${TARGET}_result
echo -e "total_request\t$total_req" >> "$OUT_DIR/${TARGET}_result"
echo -e "cache_hit_total\t$cache_hit" >> "$OUT_DIR/${TARGET}_result"
echo -e "cache_hit_rate\t$(bc -l <<< "$cache_hit/$total_req")" >> "$OUT_DIR/${TARGET}_result"
echo -e "--------" >> "$OUT_DIR/${TARGET}_result"
