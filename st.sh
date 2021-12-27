#!/usr/bin/env bash
set -ex

if [ $# != 2 ]; then
  echo "add type and data path"
  exit 1;
fi

trap finally ERR
trap finally EXIT
trap finally SIGINT

function finally {
  echo 'finally: 処理を終了します。'
  gcloud compute instances stop queue
  gcloud compute instances stop redis
  gcloud compute instances stop dns-cache
  gcloud compute instance-groups managed resize coredns-cache-stub --size 0
  gcloud compute instance-groups managed resize coredns-group --size 0
  gcloud compute instance-groups managed resize coredns-redis --size 0
  gcloud compute instance-groups managed resize dcache-group --size 0
}

group=""
case "$1" in
  "forward")
    group="coredns-cache-stub"
    gcloud compute instances start dns-cache
  ;;
  "coredns")
    group="coredns-group";;
  "redis")
    group="coredns-redis"
    gcloud compute instances start queue
    gcloud compute instances start redis
  ;;
  "dcache")
    group="dcache-group"
    gcloud compute instances start queue
    gcloud compute instances start redis
    ;;
  *)
    exit 1;;
esac


gcloud compute instance-groups managed resize $group --size 20

sleep 60

(gcloud compute instance-groups list-instances $group --uri | xargs -I '{}' gcloud compute instances describe '{}'   --flatten networkInterfaces[].accessConfigs[] --format 'csv[no-heading](networkInterfaces.accessConfigs.natIP)') > ~/dcache_evaluation

cat ~/dcache_evaluation


date
./ev.sh $1 $2
date

#for i in `seq 1 200`; do
#   ./ev.sh "$1" "$2"
#done

gcloud compute instance-groups managed resize $group --size 0
gcloud compute instances stop queue
gcloud compute instances stop redis
gcloud compute instances stop dns-cache
