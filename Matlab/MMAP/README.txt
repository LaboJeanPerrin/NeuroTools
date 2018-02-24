This folder contains functions which deal with memory mapping

Mmap is the wrapper class for memory mapping
Mmap2D is like Mmap, but for signal stack formats
createSignalStacks creates mmap signal stacks from mmap 4D stacks
driftApply applies the drift previously computed in 'corrected' binary files
tifToMmap creates the 4D binary file from the Tif images
createGrayStack creates a 3D mmap from drift corrected images averaged along t


Mmap are 4D staks with dimensions : (x,y,z,t)
Mmap2D are 3D stacks with dimensions : (t, xy)
where xy are concatenated in one dimension (with indices)
you can obtain 4D stack by the collections of  Mmap2D
