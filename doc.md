# Mini doc to use easyRLS

## Install Matlab programs

First, you can clone the code by doing 

    git clone https://github.com/LaboJeanPerrin/NeuroTools.git

it will create a folder 'Neurotools' in the current directory. Then, because easyRLS is not the master branch yet, go in the Neurotools directory (`cd Neurotools`) and switch to the 'easyRLS' branch :

    git checkout easyRLS

Once you have the right code, open the `script.m` in 'Matlab/Utils'. In Matlab, do "add with subfolders" for the 'Neurotools/Matlab' folder.

## Run the code section after section

### Change current folder

Replace the `cd` command argument by your project's folder containing the 'Data' directory. The architecture of 'Data' has to be 'Data/yyyy-mm-dd/Run xx/'.

### Get focus

The 'get focus' section loads the parameters and create a config file.

### Create binary from tif

`tifToMmap` creates a 'raw.bin' binary file directly from the tif images. This file can be accessed with memory mapping in matlab thanks to the class `Mmap` and the info in the 'raw.mat' file. It can also be accessed from imageJ with the bioformats plugin by writing the appropriate NRRD header.

