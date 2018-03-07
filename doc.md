# Mini doc to use easyRLS

## Install Matlab programs

First, you can clone the code by doing 

    git clone https://github.com/LaboJeanPerrin/NeuroTools.git

it will create a folder 'Neurotools' in the current directory. Then, because easyRLS is not the master branch yet, go in the Neurotools directory (`cd Neurotools`) and switch to the 'easyRLS' branch :

    git checkout easyRLS

Once you have the right code, open the `script.m` in 'Matlab/Utils'. In Matlab, do "add with subfolders" for the 'Neurotools/Matlab' folder.

## Run the code section after section

The benchmarks have been performed on 'Dream' for the run 2018-01-11/Run 05 on the layers 3 to 12.

### Set working directory

Replace the `cd` command argument by your project's folder containing the 'Data' directory. The architecture of 'Data' has to be 'Data/yyyy-mm-dd/Run xx/'.

The 'get focus' section loads the parameters and create a config file.

### Create binary from tif (448 s)

`tifToMmap` creates a 'raw.bin' binary file directly from the tif images. This file can be accessed with memory mapping in matlab thanks to the class `Mmap` and the info in the 'raw.mat' file. It can also be accessed from imageJ with the bioformats plugin by writing the appropriate NRRD header.

`stackViewer` allows to view the binary stack in a matlab figure with gui control thanks to memory mapping (like virtual stack in imageJ).

### Correct drift 

`driftCompute` **(92 s)** computes the drift on the projection of the reference layers relatively to the reference layer at the given reference index.

`seeDriftCorrection` plays a movie of the drift corrected brain by computing the translation online. You can then run `driftApply` **(175 s)** to create corrected binary stack if you are satisfied with the correction. `stackViewer` allows you to view the drift corrected hyperstack.

To view the stack in imageJ, you can create a NRRD header like the following in the same folder as the vinary stack.

    NRRD0001
    # Complete NRRD file format specification at:
    # http://teem.sourceforge.net/nrrd/format.html
    type: uint16
    dimension: 4
    sizes: 1018 634 10 1500
    endian: little
    encoding: raw
    data file: ./corrected.bin

You can then drag and drop the text file to imageJ, and the bioformats plugin will create a virtual stack.

### Select the ROI for dff computation

To avoid computing the dff on useless regions (i.e. background), you can select the ROI. It will be recorded in a 'mask.mat' matlab logical matrix. `maskViewer` will let you see the contour overlay on the stack.

#### Manually

`selectROI` will prompt each layer and let you draw a polygon whose inside defines the ROI.

#### Automatically

You can use a reference stack which already has a mask and use this mask after a registration. (Now only layer by layer using 2D imregdemons, but only a few seconds).

### Computing baseline (2313 s)

To compute baseline, we use the '[runquantile](https://www.rdocumentation.org/packages/caTools/versions/1.17.1/topics/runquantile)' function of '[caTools](https://www.rdocumentation.org/packages/caTools/versions/1.17.1)', a R plugin coded in C.

To use it with matlab, you only have to run `loadlibrary` with the path of the `.so` and the `.h`. They are in 'Neurotools/Tools', an example is given in the script.

Then you can run `caToolsRunquantile` which reads the signal in the 'corrected.bin' file and creates a folder 'baseline' in the 'IP' folder. In this folder, there will be a `.bin` and a `.mat` file by layer.

/!\ THIS IS NOT A GOOD WAY TO DO

Example of time taken from layer 3 to layer 12. The time depends on the number of pixels in ROI.

    183042    Elapsed time is 129.968375 seconds.
    208560    Elapsed time is 191.647284 seconds.
    215296    Elapsed time is 197.718126 seconds.
    237943    Elapsed time is 212.829820 seconds.
    255385    Elapsed time is 278.645149 seconds.
    263575    Elapsed time is 230.729000 seconds.
    272680    Elapsed time is 236.663611 seconds.
    286021    Elapsed time is 255.703843 seconds.
    294492    Elapsed time is 255.595885 seconds.
    295021    Elapsed time is 258.743297 seconds.

### Computing DFF (647 s)

The formula for the dff computation is the following :

$$ \frac{\Delta f}{f} = \frac{\text{Signal} - \text{Baseline}}{\text{Baseline} - \text{Background}}$$

It is quite fast to compute with `dff` matlab function.

    Elapsed time is 11.994007 seconds.
    Elapsed time is 55.649569 seconds.
    Elapsed time is 72.661948 seconds.
    Elapsed time is 70.141947 seconds.
    Elapsed time is 74.381304 seconds.
    Elapsed time is 71.651774 seconds.
    Elapsed time is 70.866094 seconds.
    Elapsed time is 70.864970 seconds.
    Elapsed time is 71.309378 seconds.
    Elapsed time is 72.151579 seconds.

... ...