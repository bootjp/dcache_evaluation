// Command text is a chromedp example demonstrating how to extract text from a
// specific element.
package main

import (
	crand "crypto/rand"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"math"
	"math/big"
	"math/rand"
	"net/http"
	"os"
	"sync"
	"time"
)

func main() {
	seed, _ := crand.Int(crand.Reader, big.NewInt(math.MaxInt64))
	rand.Seed(seed.Int64())

	path := os.Args[1]
	t, err := parse(path)
	if err != nil {
		log.Fatalln(err)
	}

	wg := &sync.WaitGroup{}
	for _, s := range t {
		wg.Add(1)
		go func(s Target) {
			err = fetch("https://" + s.Domain)
			if err != nil {
				err = fetch("http://" + s.Domain)
				if err != nil {
					wg.Done()
					return
				}
				fmt.Println("http://" + s.Domain)
				wg.Done()
				return
			}
			fmt.Println("https://" + s.Domain)
			wg.Done()
		}(s)
	}
	wg.Wait()
}

type Target struct {
	Domain string `json:"domain"`
}

func parse(path string) ([]Target, error) {

	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	b, err := ioutil.ReadAll(f)
	if err != nil {
		return nil, err
	}

	var t []Target

	err = json.Unmarshal(b, &t)
	if err != nil {
		return nil, err
	}

	return t, nil
}

var tr = &http.Transport{
	MaxIdleConns:    10,
	IdleConnTimeout: 3 * time.Second,
}

func fetch(url string) error {
	client := &http.Client{Transport: tr}
	_, err := client.Get(url)
	return err
}
