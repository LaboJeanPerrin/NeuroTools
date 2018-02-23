% script for image analysis (inspired from Routine_Analysis_RLS)
% 2018-02 Hugo Trentesaux

%% utilities
% different utilities to run when necessary
%% rename images
% i.e. : Images_5_000001 → Image0_000000
rename(param.date,param.run_number);
%% view
% view image using the active mmap 'm'
z = 3;
t = 1;
imshow(m(:,:,z,t),[300 1000])
%% stack viewer
% generate a figure with gui to navigate in the current hyperstack
stackViewer(F,m)
%%






%% go in the project directory
cd /home/ljp/Science/Projects/RLS_Hugo/
param.cwd = pwd;
% addpath(fullfile(pwd, 'Programs/Neurotools/Matlab'))
% addpath(fullfile(pwd, 'Programs/Neurotools/Matlab'))

%% get focus (load config.mat)
% get focus by giving current directory, date, and run number
param.date = '2018-01-11';
param.run_number = 5;
F = NT.Focus({param.cwd, '', param.date, param.run_number});

%% create binary file
% read tif images, write it to binary file and store Mmap object in a file
% for the given z and t
% Layer to map
param.Layers = 3:10; 
param.T = length(F.set.t); 
tic; tifToMmap(F, 'raw', {'z', param.Layers, 't', param.T}); toc

%% retrieve Mmap object
% reads the mmap object from the file
m = Mmap(F, 'raw');

%% compute drift on mmap
% compute drift using custom function (see code)
% Layers used to create the reference stack to perform the drift correction
param.RefLayers = 8:10;
% determine index of reference brain scan for drift correction
param.RefIndex = 10; 
tic; driftCompute(F,m,{...
    'RefLayers', param.RefLayers, ...
    'RefIndex', param.RefIndex, ...
    'Layers', param.Layers, ...
    }); toc

%% see if drift is well corrected
% applies imtranslate with computed values in a loop
seeDriftCorrection(F);
%% applies drift if it is ok
% applies drift correction and records mmap
tic; driftApply(F, m); toc
%% retrieve Mmap object
% reads the mmap object from the file
m = Mmap(F, 'corrected');
%% stack viewer
% view corrected hyperstack
stackViewer(F,m)
%% map to ref brain
% use imregdemons
tic; mapToReferenceBrain(F, m, m, param.RefIndex); toc
%% find ROI using reference brain mask
% use the mask predefined on the reference brain to find the mask for the
% current brain, saves autoROI as a mask.mat file
autoROI(F, F)





%% compute baseline
% naive approach is too long (170 000 x 1500 = 255 000 000)
tic; naiveBaselineLayer(F, m, 3); toc





%% select ROI manually on reference brain
% displays all the layers one after the other
selectROI(F, m, param.RefIndex)






%% % % % % % % % % % % % % % % % % % % % % % % % % % %  

% todo 
create_signal_stack_RLS_v2(Layers, binsize, F, ind_Refstack);

DFF_bg(Layers,F);


