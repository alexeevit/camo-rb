# Camo-rb
Camo-rb is a ruby version of [camo](https://github.com/atmos/camo)

A camo server is a special type of image proxy that proxies non-secure images over SSL/TLS, in order to prevent mixed content warnings on secure pages. The server works in conjunction with back-end code that rewrites image URLs and signs them with an [HMAC](https://en.wikipedia.org/wiki/HMAC).

## Usage

Install Camo-rb as a ruby gem:

```
gem install camorb
```

Run it:

```
CAMORB_KEY=<some key> camorb
```

## Configuration

Use the next environment variables to configure the server:

* `CAMORB_PORT` — the port number Camo should listen on (default: `9292`) 
* `CAMORB_KEY` —  a shared key consisting of a random string, used to generate the HMAC digest (default: none)
* `CAMORB_HEADER_VIA` — the string for Camo to include in the `Via` and `User-Agent` headers it sends in requests to origin servers (default: `Camo Asset Proxy <version>`)
* `CAMORB_LOG_LEVEL` — severity of logging, available levels: debug, info, error (default: `info`)
* `CAMORB_KEEP_ALIVE` — whether or not to enable keep-alive session (default: `false`)
* `CAMORB_MAX_REDIRECTS` — the maximum number of redirects Camo will follow while fetching an image (default: `4`)
* `CAMORB_SOCKET_TIMEOUT` — the maximum number of seconds Camo will wait before giving up on fetching an image (default: `10`)
* `CAMORB_LENGTH_LIMIT` — the maximum Content-Length Camo will proxy (default: `5242880`)
* `CAMORB_TIMING_ALLOW_ORIGIN` — the string for Camo to include in the Timing-Allow-Origin header it sends in responses to clients. The header is omitted if this environment variable is not set (default: none)
* `CAMORB_HOSTNAME` — the `Camo-Host` header value that Camo will send (default: `unknown`)

## URL Formats

## Tasks to do

[ ] Allow use SSL/TLS certificates
[ ] Add logging in JSON format
[ ] Allow to customize requests and the server
[ ] Support metrics (Prometheus)
[ ] Allow to customize logging
...
