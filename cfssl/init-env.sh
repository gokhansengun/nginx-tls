#!/bin/bash -eu

# Cleanup just in case not removed at the last run
rm -rf ./ca/*
rm -rf ./issued-certs/*

mkdir -p ./ca
mkdir -p ./issued-certs
