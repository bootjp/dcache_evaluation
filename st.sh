#!/usr/bin/env bash
set -ex


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


gcloud compute instance-groups managed resize dcache-group --size 20

sleep 20

(gcloud compute instance-groups list-instances dcache-group --uri | xargs -I '{}' gcloud compute instances describe '{}'   --flatten networkInterfaces[].accessConfigs[] --format 'csv[no-heading](networkInterfaces.accessConfigs.natIP)') > ~/dcache_evaluation

cat ~/dcache_evaluation

./ev.sh "$1" >> "result_$1"

gcloud compute instance-groups managed resize dcache-group --size 0

gcloud compute instances stop queue
gcloud compute instances stop redis
gcloud compute instances stop dns-cache
