# Starter Sample to run Nginx with TLS Support

## Introduction

This repo is just a starting point to serve web pages with Nginx using TLS. It is mainly for educational purposes and far far away being production ready so please be careful!!

TLS certifices are going to be generated using [cfssl](https://github.com/cloudflare/cfssl) of Cloudflare.

## Certificate and Private Key Generation using CFSSL

`cfssl` folder has all the configuration to generate a certificate for Nginx site published to `foo.acme.com`.

Steps for generating the CAs, certificates and the private keys are below.

1. Open a terminal and move to `cfssl` folder, run `./init-env.sh` command to cleanup and initialize the folders.
2. In `cfssl` folder, run `./gen-root-and-int-ca.sh` to generate Root CA and Intermediate CA certificates and private keys. They will appear under `cfssl/ca` folder.
3. In `cfssl` folder, run `./gen-foo-acme-cert.sh` to generate a certificate and sign with the intermediate certificate for domain `foo.acme.com`, the certificate and private key (to be fed to Nginx) will appear under `cfssl/issued-certs` folder.

Below is an example run given:

```bash
➜  nginx-tls git:(master) ✗ cd cfssl
➜  cfssl git:(master) ✗ ./init-env.sh
➜  cfssl git:(master) ✗ ./gen-root-and-int-ca.sh
2018/01/01 13:07:44 [INFO] generate received request
2018/01/01 13:07:44 [INFO] received CSR
2018/01/01 13:07:44 [INFO] generating key: rsa-4096
2018/01/01 13:07:48 [INFO] encoded CSR
2018/01/01 13:07:48 [INFO] signed certificate with serial number 679137305797398349438266964075278223547092180893
2018/01/01 13:07:51 [INFO] generate received request
2018/01/01 13:07:51 [INFO] received CSR
2018/01/01 13:07:51 [INFO] generating key: rsa-4096
2018/01/01 13:07:55 [INFO] encoded CSR
2018/01/01 13:07:55 [INFO] signed certificate with serial number 571806828382796651294254523547316694515355387146
2018/01/01 13:07:58 [INFO] signed certificate with serial number 585261831146609802545074706562831189681387775313
➜  cfssl git:(master) ✗ ./gen-foo-acme-cert.sh
2018/01/01 13:08:07 [INFO] generate received request
2018/01/01 13:08:07 [INFO] received CSR
2018/01/01 13:08:07 [INFO] generating key: rsa-2048
2018/01/01 13:08:08 [INFO] encoded CSR
2018/01/01 13:08:08 [INFO] signed certificate with serial number 165288814616737824677465696238945145826100141548
2018/01/01 13:08:08 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").

➜  cfssl git:(master) ✗ tree ca
ca
├── intermediate-ca-key.pem
├── intermediate-ca.csr
├── intermediate-ca.pem
├── root-ca-key.pem
├── root-ca.csr
└── root-ca.pem

0 directories, 6 files
➜  cfssl git:(master) ✗ tree issued-certs
issued-certs
├── foo.acme.com-key.pem
├── foo.acme.com.csr
└── foo.acme.com.pem

0 directories, 3 files
```

## Trusting the Root CA

In order to see the green padlock in the browser's address bar, the computer needs to trust either the Root CA or the intermediate CA.

According to the platform you are running on, Root CA should be trusted.

If you just want to test on command line using curl or OK with the warning messages on the browser, you do NOT need to trust the Root CA.

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
	-v $(pwd)/cfssl/issued-certs:/etc/nginx/certs \
	-v $(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf \
	nginx:1.10
```

## Testing

If you trusted the Root CA of `acme.com`, opening a web browser and navigating to the `https://foo.acme.com` page, you should see no errors and warnings. The page should look like below.

![nginx tls view](https://github.com/gokhansengun/nginx-tls/raw/master/images/site-green-padlock.png "Nginx TLS View")

If you just want to see it with `curl`, use below command.

```
curl --cacert ./cfssl/ca/root-ca.pem https://foo.acme.com
```

## Note

Please note that this is a test setup. Normally, we should be issueing another certificate and private key from the intermediate certificate and use it in the web server but we skipped that for the brevity.