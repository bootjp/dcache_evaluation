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
  gcloud compute instance-groups managed resize --zone asia-northeast1-b forward --size 0
  gcloud compute instance-groups managed resize --zone asia-northeast1-b coredns --size 0
  gcloud compute instance-groups managed resize --zone asia-northeast1-b redis --size 0
  gcloud compute instance-groups managed resize --zone asia-northeast1-b dcache-2 --size 0
}

group=""
case "$1" in
  "forward")
    group="--zone asia-northeast1-b forward"
    gcloud compute instances start dns-cache
    gcloud compute instances start queue
  ;;
  "coredns")
    group="--zone asia-northeast1-b coredns"
    gcloud compute instances start queue
  ;;

  "redis")
    group="--zone asia-northeast1-b redis"
    gcloud compute instances start queue
    gcloud compute instances start redis
  ;;
  "dcache")
    group="--zone asia-northeast1-b dcache-2"

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

for i in `seq 1 10`; do
   ./evaluation.sh "$1" "$2"
done
