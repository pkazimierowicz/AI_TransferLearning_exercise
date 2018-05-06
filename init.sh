#!/bin/bash

git submodule init
cp -r RaspberryPi-ObjectDetection-TensorFlow/python/ scripts/
cp RaspberryPi-ObjectDetection-TensorFlow/run.sh scripts/run.sh 

