# dcache_evaluation

```
pssh -h ~/dcache_evaluation -i --timeout=0 'sudo docker run -d --restart=always -v$(pwd)/Corefile:/Corefile -p53:53 -p53:53/udp -p9253:9253 ghcr.io/bootjp/dcache_evaluation:latest'
pssh -h ~/dcache_evaluation -i --timeout=0 'sudo docker pull ghcr.io/bootjp/dcache_evaluation:latest'
pssh -h ~/dcache_evaluation -i --timeout=0 'sudo docker rm -f $(sudo docker ps -aqf "publish=53")'

# clear cache
pssh -O StrictHostKeyChecking=no -h ~/dcache_evaluation -i --timeout=0 'sudo docker restart  $(sudo docker ps -aqf "publish=53")'

# run benchmark
pssh -O StrictHostKeyChecking=no -h ~/dcache_evaluation -i --timeout=0 "sudo docker pull ghcr.io/bootjp/top1000load:latest"

pssh -h ~/dcache_evaluation -i --timeout=0 "sudo docker run --rm -e REDIS_HOST=10.146.0.10:6379 --net=host --cap-add=SYS_ADMIN ghcr.io/bootjp/top1000load:latest"

pssh -h ~/dcache_evaluation -i -o out/metrics --timeout=30 "curl -s localhost:9253/metrics | grep -v ^# "
pssh -h ~/dcache_evaluation -i -o out/logs --timeout=30 'docker logs  $(sudo docker ps -aqf "publish=53")'

sudo docker run -d --name dcache --log-driver=gcplogs --restart=always -p53:53 -p53:53/udp -p9253:9253 ghcr.io/bootjp/dcache_evaluation:latest


```
