# GOne: perform auto-optimizing genome-centric metagenomics with one command
## About
This software integrates state-of-the-art tools to conduct genome-centric metagenomics for researchers who are unfamiliar with command line tools or have limited time in learning bioinformatics.  
## Features
* **Easy to use**: only one required parameter (the working directory).  
* **Flexible**: seperated modules for customized workflows.
* **Free from manual intervention**: all tools and parameters are selected automatically to optimize the performance and results.    
* **One-stop solution**: from raw sequences to publishable figures.  
## Prerequisite
Install [Anaconda](https://www.anaconda.com/) following the offical [document](https://docs.anaconda.com/anaconda/install/). Or,
```
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
# The latest version of the installer can be found at https://repo.anaconda.com/archive/
./Anaconda3-*-Linux-x86_64.sh
```
Then clone a local copy of the current repository
```
# Git should be installed first. If not, run
sudo apt-get install git
# Clone the repository
git clone https://github.com/DOieGYuan/easyG.git
```
## Installation
Simply run `./install_easyG.sh` to automatically install all required tools and databases.  
See details about the installtion in our [wiki](##).

## Quick start
First, build all prerequisites by simply run *build.sh* or install all the dependencies [manually]()
```
source build.sh
```
Then, run the pipeline
```
soure EasyGCMeta [myfolder]
```
Done
## Understand the fundamental output
## Supplementary functions (modules)
## Configure the pipeline
## Q&A
## Contact us
Please feel free to contact linyuan@smail.nju.edu.cn

**to be continued ...(First release aim at 2021-08-18)**
