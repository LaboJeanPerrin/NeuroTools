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
param.run_number = 6;
F = NT.Focus({param.cwd, param.date, param.run_number});
%% create binary file from Tif
param.Layers = 3:12; 
tifToMmap(F, {'z', param.Layers});
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
%% if it is convincing, create signal stacks (quite long, how ?)
createSignalStacks(F, param.Layers);
%% once signal stacks are created, load library to compute baseline
[~,~] = loadlibrary('/home/ljp/Science/Projects/RLS_Hugo/Tools/caTools.so',...
                    '/home/ljp/Science/Projects/RLS_Hugo/Tools/caTools.h');
%% compute baseline on signal stack using caTools library
caToolsRunquantile(F, param.Layers);








% script for image analysis (inspired from Routine_Analysis_RLS)
% 2018-02 Hugo Trentesaux

%% utilities
% different utilities to run when necessary
%% rename images
% i.e. : Images_5_000001 → Image0_000000
rename(param.date,param.run_number);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 



%% compute background
%
createGrayStack(F, m)




%% % % % % % % % % % % % % % % % % % % % % % % % % % %  

% todo 

DFF_bg(Layers,F);


