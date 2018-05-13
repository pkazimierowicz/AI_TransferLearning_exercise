## Requirements
* Requirements:
    * ~8G free RAM
    * python3
    * python-tensorflow
    * protobuf (3+)
    * matplotlib
    * curl
    * eog

If you're on Ubuntu 18.04, just run this:

```bash
sudo apt install -y git curl eog python3 python3-pip protobuf-compiler
sudo pip3 install lxml matplotlib
sudo pip3 install tensorflow # or tensorflow-gpu if you have CUDA capable GPU and drivers
```

## Quick start

####Clone the repository and `TensorFlow/models` submodule repository:
```
$ git clone https://github.com/pkazimierowicz/AI_TransferLearning_exercise.git
$ cd AI_TransferLearning_exercise
$ git submodule update --init
```

#### Download sample data:
```
$ data/download_sample.sh
```

This will put the sample images in `data/imaages` and the annotation xml files from labelImg in `data/annotations`


#### Try to label the images for your own with labelImg:
Start with installing labelImg:
```
pip install labelImg
```
Then run `labelImg`, open directory `data/images` and mark objects on the photos.
Move the resulting `*.xml` files into `data/annotations` directory.


### Now run the training:
```
$ scripts/learn.sh -m train -p '{"batch_size":8,"learning_rate":0.003,"train_steps":10000}'
```

### Export the trained model 'checkpoint', after the training has completed:
```
$ scripts/learn.sh -m export -c model.ckpt-10000
```

### Let the neural network label and annotate the images:
```
$ scripts/detect.sh data/images/*.jpg
```

### Inspect the results:
```
$ eog data/images/*.jpg
```
