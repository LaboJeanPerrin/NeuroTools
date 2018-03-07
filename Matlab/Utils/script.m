% this script is here to guide through the use of Hugo_easyRLS branch
% Hugo Trentesaux 2018-02-23
% please make sure you have Neurotools to your path
clear
clc

%% go in the project directory
cd /home/ljp/Science/Projects/RLS_Hugo/
param.cwd = pwd;
%% get focus
param.date = '2018-01-11';
param.run_number = 5;
param.Layers = 3:12; 
F = NT.Focus({param.cwd, param.date, param.run_number});
%% create binary file from Tif
tifToMmap(F, {'z', param.Layers});
%% view hyperstack
stackViewer(F, 'raw')
%% compute drift on mmap
param.RefLayers = 8:10;
param.RefIndex = 10; 
driftCompute(F,{...
    'RefLayers', param.RefLayers, ...
    'RefIndex', param.RefIndex, ...
    'Layers', param.Layers, ...
    });
%% see if drift is well corrected
seeDriftCorrection(F);
%% applies drift if it is ok
driftApply(F);
%% view corrected hyperstack
stackViewer(F, 'corrected')

% m=Mmap(F, 'corrected'); imshow(m(:,:,3,10)',[300 800]);

%% define focus on reference stack and take its ROI if existing
%{
param.run_number = 6;
Fref = NT.Focus({param.cwd, param.date, param.run_number});
% create defMap
mapToReferenceBrain(F, Fref, param.RefIndex);
% finds ROI using reference brain mask
% use the mask predefined on the reference brain to find the mask for the
% current brain, saves autoROI as a mask.mat file
autoROI(F, Fref)
%}

%% if not, select ROI manually on reference brain
selectROI(F, param.RefIndex)
%% check if guessed ROI is ok
maskViewer(F)


%% load library to compute baseline
[~,~] = loadlibrary('/home/ljp/Science/Projects/RLS_Hugo/Programs/NeuroTools/Tools/caTools.so',...
                    '/home/ljp/Science/Projects/RLS_Hugo/Programs/NeuroTools/Tools/caTools.h');
%% compute baseline using caTools library
caToolsRunquantile(F, param.Layers);
%% view baseline
stackViewer2D(F, 'baseline', param.Layers)
%% compute gray stack and view it
createGrayStack(F)
stackViewer(F, 'IP/graystack')
%% compute background
param.background = 400;
%% compute DFF
t=tic;
dff(F, param.Layers, param.background);
toc(t)
%% view DFF
sigViewer2D(F, 'dff', param.Layers)


%% utilities
% different utilities to run when necessary
%% rename images
% i.e. : Images_5_000001 → Image0_000000
rename(param.date,param.run_number);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


%% quickscript
% this script does everything in one shot

start_time = tic;

% go in the project directory
cd /home/ljp/Science/Projects/RLS_Hugo/
param.cwd = pwd;
% get focus
param.date = '2018-01-11';
param.run_number = 6;
param.Layers = 3:12; 
F = NT.Focus({param.cwd, param.date, param.run_number});
% create binary file from Tif
tifToMmap(F, {'z', param.Layers});
% compute drift on mmap
param.RefLayers = 8:10;
param.RefIndex = 10; 
driftCompute(F,{...
    'RefLayers', param.RefLayers, ...
    'RefIndex', param.RefIndex, ...
    'Layers', param.Layers, ...
    });
% applies drift
driftApply(F);
% define focus on reference stack and take its ROI if existing

Fref = NT.Focus({param.cwd, param.date, 5});
% create defMap
mapToReferenceBrain(F, Fref, param.RefIndex);
% finds ROI using reference brain mask
% use the mask predefined on the reference brain to find the mask for the
% current brain, saves autoROI as a mask.mat file
autoROI(F, Fref)
% load library to compute baseline
[~,~] = loadlibrary('/home/ljp/Science/Projects/RLS_Hugo/Programs/NeuroTools/Tools/caTools.so',...
                    '/home/ljp/Science/Projects/RLS_Hugo/Programs/NeuroTools/Tools/caTools.h');
% compute baseline using caTools library
caToolsRunquantile(F, param.Layers);
% compute gray stack
createGrayStack(F)
% compute background
background = 400;
% compute DFF
dff(F, param.Layers, background);

toc(start_time);



