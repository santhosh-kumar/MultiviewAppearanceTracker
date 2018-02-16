
A multi-camera tracking algorithm using matlab.

This is a matlab implementation of the paper "Multiple view discriminative appearance modeling with IMCMC for distributed tracking" published in ICDSC'13.

Usage
------------

In order to run the tracker, use the following command:

i) Set configuration SetupCameraNetwork.m

ii) Define global constants in Constants.m

iii) Finally run AnalyzeCameraNetwork.m

Dataset
------------
i) Download the sample dataset archive in a supported format from: https://www.dropbox.com/s/p2sz9wea0gdnzug/data.tar.gz?dl=0 and save it in the root folder

ii) Untar the data folder:
tar -xzf data.tar.gz

iii) The folder structure would like this:

~~~
.
├── README.md
├── data
├── data.tar.gz
├── libs
└── src
~~~

### Contact ###
[1] Santhoshkumar Sunderrajan( santhosh@ece.ucsb.edu)

Website: http://santhoshsunderrajan.com/

### Bibtex ###
If you use the code in any of your research works, please cite the following papers:
~~~
@inproceedings{sunderrajan2013multiple,
  title={Multiple view discriminative appearance modeling with IMCMC for distributed tracking},
  author={Sunderrajan, Santhoshkumar and Manjunath, BS},
  booktitle={Distributed Smart Cameras (ICDSC), 2013 Seventh International Conference on},
  pages={1--7},
  year={2013},
  organization={IEEE}
}
~~~

### Disclaimer ###
I may have used some good codes from various sources, please feel free to notify me if you find a piece of code that I need to acknowledge.
