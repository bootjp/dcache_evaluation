

```bash
pssh -h ~/dcache_evaluation -i --timeout=0 'sudo docker restart  $(sudo docker ps -aqf "publish=53")'
pssh -h ~/{TAEGET_HOST_FILE} -i --timeout=0 -iP -o out "sudo docker run --rm --net=host --cap-add=SYS_ADMIN ghcr.io/bootjp/top1000load:latest"

```