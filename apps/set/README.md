

```bash
go run main.go ./top1000jp.json  > url.txt
cp url.txt command.txt
sed "s/^/LPUSH crawl_queue /g" command.txt
sed -i '1s/^/DEL crawl_queue\n/' /coredns/plugin.cfg
cat command.txt | redis-cli --pipe
```