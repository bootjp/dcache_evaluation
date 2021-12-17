// Command text is a chromedp example demonstrating how to extract text from a
// specific element.
package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/chromedp/cdproto/emulation"
	"github.com/go-redis/redis/v8"

	"github.com/chromedp/chromedp"
)

func main() {
	hostname := os.Getenv("REDIS_HOST")
	if hostname == "" {
		log.Fatalln("REDIS_HOST required")
	}

	rdb := redis.NewClient(&redis.Options{
		Addr: hostname,
	})

	ctx := context.TODO()
	var err error
	for _, err = rdb.LLen(ctx, "crawl_queue").Result(); err == nil; {

		val, err := rdb.RPop(ctx, "crawl_queue").Result()
		if err != nil {
			log.Fatalln(err)
		}

		log.Println(val)
		err = fetch(val)
		if err != nil {
			log.Println(err)
		}
	}

	log.Println(err)

}

func fetch(url string) error {

	opts := []chromedp.ExecAllocatorOption{
		chromedp.UserAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36"),
		chromedp.WindowSize(1920, 1080),
		//chromedp.NoFirstRun,
		//chromedp.NoDefaultBrowserCheck,
		chromedp.Headless,
		//chromedp.DisableGPU,
	}

	ctx, cancel := chromedp.NewExecAllocator(context.Background(), opts...)
	defer cancel()

	ctx, cancel = chromedp.NewContext(context.Background())
	defer cancel()

	ctx, cancel = context.WithTimeout(ctx, 15*time.Second)
	defer cancel()

	err := chromedp.Run(ctx,
		emulation.SetUserAgentOverride("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36"),
		chromedp.Navigate(url),
	)
	if err != nil {
		return err
	}

	return nil
}
