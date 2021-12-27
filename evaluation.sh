#!/usr/bin/env bash


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

items=(
    "coredns"
    "dcache"
#    "forward"
    "redis"
)


if [ $# != 1 ]; then
  echo "add outdir"
  exit 1;
fi

for item in "${items[@]}" ; do
  bash ./st.sh item $1
done