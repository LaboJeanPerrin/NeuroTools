Utils contains the main script and functions to manage data

script 		is the main script
selectROI 	allows to manually set the ROI
autoROI 	gets the ROI from an other stack by applying an image regression
maskToIndex 	returns indices corresponding to mask


the main script is divided in the following parts, each one can be executed separately and provide visualisation tools

(10 minutes)
1- conversion from tif to bin
2- drift computation
3- applying drift

(1h)
4- computing running quantile
5- computing dff
