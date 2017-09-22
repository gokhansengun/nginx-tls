# Starter Sample to run Nginx with TLS Support

## Introduction

This repo is just a starting point to serve web pages with Nginx using TLS.

## Certificate and Private Key Generation

Generation of the certificates and the private key will be detailed later but the artifacts are included in the repo.

`certs` folder includes the following:

- The root CA's certificate named `acme.com.crt`
- The intermediate CA's certificate named `foo.acme.com.crt`
- The intermediate CA's private key named `foo.acme.com.key`

## Trusting the Root CA

In order to see the green padlock in the browser's address bar, the computer needs to trust either the Root CA or the intermediate CA.

According to the platform you are running on, Root CA should be trusted.

## Edit Host File

As you can see the certificates are issues for `acme.com` domain and the Nginx site will be run under `foo.acme.com`. Therefore depending on your system add below entry to your hosts file.

On a Mac, it would be like editing `/etc/hosts` file and adding below line.

```
127.0.0.1   foo.acme.com
```

## Running the Nginx Container

Open a terminal and navigate to the root folder of the remo and issue the following command.

```
docker run --rm -p 443:443 \
	-v $(pwd)/certs:/etc/nginx/certs \
	-v $(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf \
	nginx:1.10
```

## Testing

Open a web browser and navigate to the `https://foo.acme.com` page. You should see no errors and warnings like below.

![nginx tls view](https://github.com/gokhansengun/nginx-tls/raw/master/images/site-green-padlock.png "Nginx TLS View")

## Note

Please note that this is a test setup. Normally, we should be issueing another certificate and private key from the intermediate certificate and use it in the web server but we skipped that for the brevity.