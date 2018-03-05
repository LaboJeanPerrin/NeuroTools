This folder contains functions which deal with memory mapping

Mmap 			is the wrapper class for memory mapping
driftApply 		applies the drift previously computed in 'corrected' binary files
tifToMmap 		creates the 4D binary file from the Tif images
createGrayStack 	creates a 3D mmap from drift corrected images averaged along t (t=1)


Mmap allows you to access 4D stacks
the given subscripts might be (x,y,z,t) or (xy, z, t) where xy are concatenated in one dimension (with indices)
