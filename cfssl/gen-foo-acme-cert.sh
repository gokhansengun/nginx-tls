#!/bin/bash -eu

## STEP 1: Generate a certificate and private key for foo.acme.com
## STEP 2: Sign foo.acme.com cert by the intermediate CA's private Key
docker run --rm -v $(pwd):/pad \
    -w /pad \
    cfssl/cfssl:1.2.0 \
    gencert \
    -ca ca/intermediate-ca.pem \
    -ca-key ca/intermediate-ca-key.pem \
    -config config/int-to-client-config.json \
    csr/foo-acme-com-csr.json > /tmp/foo-acme-out.json

cat /tmp/foo-acme-out.json | \
docker run -i --rm -v $(pwd):/pad \
    -w /pad/issued-certs \
    --entrypoint=cfssljson cfssl/cfssl:1.2.0 \
    -bare foo.acme.com

# Concat Intermediate CA's cert to foo.acme.com's
cat ./issued-certs/foo.acme.com.pem > /tmp/foo-acme-com.pem
cat ./ca/intermediate-ca.pem >> /tmp/foo-acme-com.pem
cat ./ca/root-ca.pem >> /tmp/foo-acme-com.pem

mv /tmp/foo-acme-com.pem ./issued-certs/foo.acme.com.pem

# remove the intermediate output file
rm -rf /tmp/foo-acme-out.json
