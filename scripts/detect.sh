#!/bin/bash
set -e

BASEDIR="$(dirname "$0")"
export PYTHONPATH="$PYTHONPATH:$BASEDIR/../models/research:$BASEDIR/../models/research/slim"

if [ ! -e "$BASEDIR/../models/research/object_detection/protos/train_pb2.py" ]; then
	pushd "$BASEDIR/../models/research"
	protoc object_detection/protos/*.proto --python_out=.
	popd
fi

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-e experiment_id] [image-1.jpg] [image-2.jpg] ...

	-h          display this help and exit
	-e			experiment id. Used as path inside data folder to run current experiment
EOF
}

EXPERIMENT_ID="0"
DATA_DIR="$BASEDIR/../data"
LABEL_MAP_PATH="$BASEDIR/../data/label_map.pbtxt"
OPTIND=1

while getopts h:e: opt; do
	case $opt in
		e)  EXPERIMENT_ID=$OPTARG
			;;
		h)
			show_help >&2
			exit 1
			;;
		*)
  			show_help >&2
			exit 1
			;;
	esac
done

echo "EXPERIMENT ID: $EXPERIMENT_ID"

TRAIN_DIR="$DATA_DIR/$EXPERIMENT_ID"

python3 $BASEDIR/python/ObjectDetectionPredict.py --model "$TRAIN_DIR/frozen_inference_graph.pb" --labels "$DATA_DIR/label_map.pbtxt" --images "$@"
