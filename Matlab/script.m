% script for image analysis (inspired from Routine_Analysis_RLS)
% 2018-02 Hugo Trentesaux

%% utilities
% different utilities to run when necessary
%% rename images
% i.e. : Images_5_000001 → Image0_000000
rename(param.date,param.run_number);
%% view
% view image using the active mmap 'm'
z = 4;
t = 1;
imshow(egalize_histogram(F,m(:,:,z,t)))
%% stack viewer
% generate a figure with gui to navigate in the current hyperstack
stackViewer(F,m)
%%






%% go in the project directory
cd /home/ljp/Science/Projects/RLS_Hugo/
param.cwd = pwd;
% addpath(fullfile(pwd, 'Programs/Neurotools/Matlab'))
% addpath(fullfile(pwd, 'Programs/Neurotools/Matlab'))

%% Parameters
% stored in a strucutre 'p'
param.date = '2018-01-11';
param.run_number = 5;
param.Layers_stack_ref = 10:12; % Layers used to create the reference stack to perform the drift correction
param.Layers = 3:8; % Layers to analyse
param.ind_Refstack = 10; % determine index of reference brain scan for drift correction
param.binsize = 1;

%% get focus (load config.mat)
% get focus by giving current directory, date, and run number
F = NT.Focus({param.cwd, '', param.date, param.run_number});
%% create binary file
% read tif images, write it to binary file and store Mmap object in a file
tic; tifToMmap(F, 'raw2', {'z', 3, 't', 1:1000}); toc
%% retrieve Mmap object
% reads the mmap object from the file
m = Mmap(F, 'raw');
%% compute drift on mmap
% compute drift using custom function (see code)
tic; driftCompute(F,m,{}); toc




%%
tic
tmp= imread('/home/ljp/Science/Projects/RLS_Hugo/Data/2018-01-11/Run 05/Images/Images0_00000.tif');
toc
%%
clc
tic
for i=1:1000
    tmp= imread('/home/ljp/Science/Projects/RLS_Hugo/Data/2018-01-11/Run 05/Images/Images0_00000.tif');
end
toc


%% create ROI manually
% displays each layer in p.layers to manually select the ROI
clc
createContourManual(param.Layers, F, param.ind_Refstack, param.binsize);
%% computes drift correction on p.Layers_stack_ref
%
clc
tic
DriftCompute(F, param.Layers_stack_ref, param.Layers, param.ind_Refstack)
toc
%% applies drift correction (mmap paf)

...




%% % % % % % % % % % % % % % % % % % % % % % % % % % %  



% TODO convert to paf and apply drift
AntiDrift_OpenSpim_v3(Layers_stack_ref, Layers, F, ind_Refstack, 'true');

% todo 
create_signal_stack_RLS_v2(Layers, binsize, F, ind_Refstack);

DFF_bg(Layers,F);


