#!/bin/bash
set -e

cd "$(dirname "$0")"
export PYTHONPATH="$PYTHONPATH:$(pwd)/../models/research:$(pwd)/../models/research/slim"

if [ ! -e "../models/research/object_detection/protos/train_pb2.py" ]; then
	pushd "../models/research"
	protoc object_detection/protos/*.proto --python_out=.
	popd
fi

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-m mode] [-a architecture] [-h hparams] [-e experiment_id] [-c checkpoint]

	-h          display this help and exit
	-m          mode: should be either `train` or `export`
	-p          key value pairs of hyperparameters as json string
	-e			experiment id. Used as path inside data folder to run current experiment
	-c          applicable when mode is export, used to specify checkpoint to use for export
EOF
}

ARCHITECTURE="ssd_mobilenet_v1_coco"
EXPERIMENT_ID="0"
HPARAMS=""
DATA_DIR="../data"
LABEL_MAP_PATH="../data/label_map.pbtxt"
CHECKPOINT_FILE="model.ckpt"

MODE="train"
OPTIND=1

while getopts m:a:h:e:c:p: opt; do
	case $opt in
		m)  MODE=$OPTARG
			;;
		a)  ARCHITECTURE=$OPTARG
			;;
		p)  HPARAMS=$OPTARG
			;;
		e)  EXPERIMENT_ID=$OPTARG
			;;
		c)  CHECKPOINT_FILE=$OPTARG
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

echo "MODE: $MODE"
echo "ARCHITECTURE: $ARCHITECTURE"
echo "EXPERIMENT ID: $EXPERIMENT_ID"
echo "HPARAMS: $HPARAMS"

TRAIN_DIR="$DATA_DIR/$EXPERIMENT_ID"

if [ $MODE == "train" ]
then
	# Create label map file from dataset
	python3 ./python/create_label_map.py \
		--data_dir $DATA_DIR \
		--label_map_path $LABEL_MAP_PATH

	# Create tf records from dataset
	python3 ./python/create_data_tf_record.py \
		--data_dir $DATA_DIR \
		--output_dir $DATA_DIR \
		--label_map_path $LABEL_MAP_PATH

	if [ ! -z "$HPARAMS" -a "$HPARAMS" != " " ]; then
        # Create config file
		python3 ./python/update_config.py \
			--architecture $ARCHITECTURE \
			--experiment_id $EXPERIMENT_ID \
			--label_map_path $LABEL_MAP_PATH \
			--data_dir $DATA_DIR \
			--hparams $HPARAMS
	else
		# Create config file
		python3 ./python/update_config.py \
			--architecture $ARCHITECTURE \
			--experiment_id $EXPERIMENT_ID \
			--label_map_path $LABEL_MAP_PATH \
			--data_dir $DATA_DIR
	fi

	mkdir -p "$TRAIN_DIR/eval"
	
	# Start eval on cpu
	nohup bash -c "sleep 30; 
	env CUDA_VISIBLE_DEVICES=-1 python3 ../models/research/object_detection/eval.py \
		--checkpoint_dir $TRAIN_DIR \
		--eval_dir \"$TRAIN_DIR/eval\" \
		--pipeline_config_path \"$TRAIN_DIR/pipeline.config\"" &

	# Start tensorboard at port 8000
	nohup tensorboard --port 8000 --logdir=$TRAIN_DIR &

	# Start training
	python3 ../models/research/object_detection/train.py \
		--train_dir $TRAIN_DIR \
		--pipeline_config_path "$TRAIN_DIR/pipeline.config"

elif [ $MODE = "export" ]
then
	# Export last trained model in experiment
	python3 ../models/research/object_detection/export_inference_graph.py \
		--trained_checkpoint_prefix "$TRAIN_DIR/$CHECKPOINT_FILE" \
		--output_directory $TRAIN_DIR \
		--pipeline_config_path "$TRAIN_DIR/pipeline.config"
fi
