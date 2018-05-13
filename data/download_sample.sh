#!/bin/bash

cd "$(dirname "$0")"
URL="http://pluton.kt.agh.edu.pl/~kzuk/sample-learning-images.tar.gz"
curl "$URL" | tar xvz
