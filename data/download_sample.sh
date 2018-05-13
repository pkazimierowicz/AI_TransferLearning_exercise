#!/bin/bash

cd "$(dirname "$0")"
URL="FIXME"
curl "$URL" | tar xvz
