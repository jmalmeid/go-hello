// Writing a basic HTTP server is easy using the
// `net/http` package.
package main

import (
	"fmt"
	"net/http"
	"os"
	"time"

	config "github.com/gookit/config/v2"
	yaml "github.com/gookit/config/v2/yaml"
)

// A fundamental concept in `net/http` servers is
// *handlers*. A handler is an object implementing the
// `http.Handler` interface. A common way to write
// a handler is by using the `http.HandlerFunc` adapter
// on functions with the appropriate signature.
func now(w http.ResponseWriter, req *http.Request) {

	// Functions serving as handlers take a
	// `http.ResponseWriter` and a `http.Request` as
	// arguments. The response writer is used to fill in the
	// HTTP response. Here our simple response is just show current time in
	// New-York, Berlin, Tokyo in HTML format
	now := time.Now()
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprintf(w, "<html><body>")
	fmt.Fprintf(w, "<h1>The current time in New-York, Berlin, Tokyo is:</h1>\n")
	loc, _ := time.LoadLocation("America/New_York")
	fmt.Fprintf(w, "<h2>New York: %s\n", now.In(loc).Format(config.String("time.format")))
	loc, _ = time.LoadLocation("Europe/Berlin")
	fmt.Fprintf(w, "<h2>Berlin : %s\n", now.In(loc).Format(config.String("time.format")))
	loc, _ = time.LoadLocation("Asia/Tokyo")
	fmt.Fprintf(w, "<h2>Tokyo : %s\n", now.In(loc).Format(config.String("time.format")))
	fmt.Fprintf(w, "</body></html>")

}

func health(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, "ok")
}

func main() {

	// Verify arguments
	if len(os.Args) != 2 {
		fmt.Println("Usage: ./go-hello-http <configfile>")
		os.Exit(1)
	}

	config.WithOptions(config.ParseEnv)

	// add driver for support yaml content
	config.AddDriver(yaml.Driver)

	err := config.LoadFiles(os.Args[1])
	if err != nil {
		panic(err)
	}

	// We register our handlers on server routes using the
	// `http.HandleFunc` convenience function. It sets up
	// the *default router* in the `net/http` package and
	// takes a function as an argument.
	http.HandleFunc("/", now)
	http.HandleFunc("/health", health)

	// Finally, we call the `ListenAndServe` with the port
	// and a handler. `nil` tells it to use the default
	// router we've just set up.
	http.ListenAndServe(":"+config.String("port"), nil)
}
