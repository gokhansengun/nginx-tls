#!/bin/bash -eu

## STEP 1: Generate the Root CA cert and private key
docker run --rm -v $(pwd):/pad \
    -w /pad \
    cfssl/cfssl:1.2.0 \
    genkey \
    -initca csr/root-ca-csr.json > /tmp/root-ca-out.json

cat /tmp/root-ca-out.json | \
docker run -i --rm -v $(pwd):/pad \
    -w /pad/ca \
    --entrypoint=cfssljson cfssl/cfssl:1.2.0 \
    -bare root-ca
  
# remove the intermediate output file
rm -rf /tmp/root-ca-out.json

## STEP 2: Generate Intermediate CA cert and private key
docker run --rm -v $(pwd):/pad \
    -w /pad \
    cfssl/cfssl:1.2.0 \
    genkey \
    -initca csr/intermediate-ca-csr.json > /tmp/intermediate-ca-out.json


cat /tmp/intermediate-ca-out.json |
docker run -i --rm -v $(pwd):/pad \
    -w /pad/ca \
    --entrypoint=cfssljson cfssl/cfssl:1.2.0 \
    -bare intermediate-ca
    
# remove the intermediate output file
rm -rf /tmp/intermediate-ca-out.json

## STEP 3: Sign the Intermediate CA with Root CA's Private Key
docker run --rm -v $(pwd):/pad \
    -w /pad \
    cfssl/cfssl:1.2.0 \
    sign \
    -hostname acme.com \
    -ca ca/root-ca.pem \
    -ca-key ca/root-ca-key.pem \
    -config config/root-to-int-config.json \
    ca/intermediate-ca.csr > /tmp/intermediate-ca-sign-out.json

cat /tmp/intermediate-ca-sign-out.json | \
docker run -i --rm -v $(pwd):/pad \
    -w /pad/ca \
    --entrypoint=cfssljson cfssl/cfssl:1.2.0 \
    -bare intermediate-ca

# remove the intermediate output file
rm -rf /tmp/intermediate-ca-sign-out.json