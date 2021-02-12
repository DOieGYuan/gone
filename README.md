# Easy-genomic-centric-metagenomics-pipepline
## About
Integrate well-established methods to conduct genomic-centric metagenomics for researchers who are busy in wet experiments but have no time in learning bioinformatics.  
  
* This pipeline is easy to use with **only one** parameter, namely, the directory with paired-end fastq, required.  
* Single command ```source EasyGCMeta [myfolder]``` to finish all processes (raw data to publishable figures). Also, seperate modules or tools are available for specific functions. 
* All bioinformatic tools and parameters are refered to published papers and suitable for most of the situations.  
* Still flexible because all parameters cound be adjusted if you really know what you are doing.  
* More plugins including phylogenetic analysis, taxonomic classification, function annotation and ploting are under development.  
* Hope to assist your (genomic-centric) metagenomic analysis from raw sequences to publishable figures.  
## Workflow
## Installation
You have to have git installed. If not, run ```pip install git```, or if you have root permission, run ```sudo apt-get install git``` to install it.  
Then install [Anaconda](https://www.anaconda.com/) following the offical [document](https://docs.anaconda.com/anaconda/install/).
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
  
**to be continued ...(First release aim at 2021-06-03)**
