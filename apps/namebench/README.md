

```bash
pssh -h ~/dcache_evaluation -i --timeout=0 'sudo docker restart  $(sudo docker ps -aqf "publish=53")'
pssh -h ~/{TAEGET_HOST_FILE} -i --timeout=0 -iP -o out "sudo docker run --net=host -v/tmp:/tmp/ ghcr.io/bootjp/namebench:latest -x -O 127.0.0.1"

```