## Requirements
* Requirements:
    * python3
    * python-tensorflow
    * protobuf (3+)
    * matplotlib
    * curl
    * eog

If you're on Ubuntu 18.04, just run this:

```bash
sudo apt install -y git curl eog python3 python3-pip
sudo pip3 install tensorflow # or tensorflow-gpu if you have CUDA capable GPU and drivers
```

## Quick start
```
$ git clone https://github.com/pkazimierowicz/AI_TransferLearning_exercise.git
$ cd AI_TransferLearning_exercise
$ git submodule update --init
$ data/download_sample.sh
$ scripts/learn.sh -m train -p '{"batch_size":8,"learning_steps":10000}'
$ scripts/learn.sh -m export -c model.ckpt-10000
$ scripts/detect.sh data/images/*.jpg
$ eog data/images/*.jpg
```
