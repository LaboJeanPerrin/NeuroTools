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
load('/home/ljp/Science/Projects/RLS_Hugo/Data/2018-01-11/Run 06/Files/IP/graystack.mmap.mat', 'mmap')
imshow(mmap.Data.raw(:,:,3), [300 800]);
img = NT.Image(double(mmap.Data.raw(:,:,3)));
img.background()
%% Background
% le background est mal calculé sur des images moyennées !
bg = NaN(1,13);
for z=1:13
    img = NT.Image(double(mmap.Data.raw(:,:,z)));
    bg(z) = img.background();
end



%% get reference brain focus
% same getfocus but for reference brain
param.run_number = 5;
Fref = NT.Focus({param.cwd, '', param.date, param.run_number});
%% get corrected reference mmap stack
%
mref = Mmap(Fref, 'corrected');
%% select ROI manually on reference brain
% displays all the layers one after the other
selectROI(Fref, m, param.RefIndex)


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


%% go in the project directory
cd /home/ljp/Science/Projects/RLS_Hugo/
param.cwd = pwd;
% addpath(fullfile(pwd, 'Programs/Neurotools/Matlab'))
% addpath(fullfile(pwd, 'Programs/Neurotools/Matlab'))

%% get focus (load config.mat)
% get focus by giving current directory, date, and run number
param.date = '2018-01-11';
param.run_number = 6;
F = NT.Focus({param.cwd, '', param.date, param.run_number});

%% create binary file from Tif
% read tif images, write it to binary file and store Mmap object in a file
% for the given z and t
% Layer to map
param.Layers = 3:15; 
fprintf('Wait about %d seconds\n', floor(length(param.Layers)*length(param.T)/30));
tic; tifToMmap(F, 'raw', {'z', param.Layers}); toc

%% retrieve Mmap object
% reads the mmap object from the file
m = Mmap(F, 'raw');

%% compute drift on mmap
% compute drift using custom function (see code)
% Layers used to create the reference stack to perform the drift correction
param.RefLayers = 8:10;
% determine index of reference brain scan for drift correction
param.RefIndex = 10; 
fprintf('Wait about %d seconds\n', floor(length(param.T)/10));
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
fprintf('Wait about %d seconds\n', floor(length(param.Layers)*length(param.T)/80));
tic; driftApply(F, m); toc;
%% retrieve Mmap object
% reads the mmap object from the file
m = Mmap(F, 'corrected');
%% stack viewer
% view corrected hyperstack
stackViewer(F,m)
%% map to ref brain
% use imregdemons
tic; mapToReferenceBrain(F, m, mref, param.RefIndex); toc;
%% find ROI using reference brain mask
% use the mask predefined on the reference brain to find the mask for the
% current brain, saves autoROI as a mask.mat file
autoROI(F, Fref)
%% check if guessed ROI is ok
% like hyperstack
maskViewer(F, m)
%% create signal stacks
% needed for computing baseline ?
tic; createSignalStacks(F, m); toc
%% load library to compute baseline
%
[notfound,warnings]=loadlibrary('/home/ljp/Science/Projects/RLS_Hugo/Tools/caTools.so', '/home/ljp/Science/Projects/RLS_Hugo/Tools/caTools.h');
% libfunctions('caTools')
% libfunctions caTools -full
% [doublePtr, doublePtr, int32Ptr, int32Ptr, doublePtr, int32Ptr, int32Ptr] runquantile(doublePtr, doublePtr, int32Ptr, int32Ptr, doublePtr, int32Ptr, int32Ptr)
% OUT = calllib('caTools', 'runquantile', IN, OUT, 1500, 100, 0.1, 1, 1);
%% compute baseline on signal stack using caTools library
%
caToolsRunquantile(F);
%% compute background
%
createGrayStack(F, m)














%% % % % % % % % % % % % % % % % % % % % % % % % % % %  

% todo 
create_signal_stack_RLS_v2(Layers, binsize, F, ind_Refstack);

DFF_bg(Layers,F);


