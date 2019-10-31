function [dirs, tags, gets] = architecture(rootdir, sdr)
% returns the file hierarchy
% sdr is fullfile study/date/run

% --- Architecture

dirs = containers.Map; % directories
tags = containers.Map; % tags
gets = struct(); % functions

% Root folder
dirs('Root') = fullfile(rootdir);

% Run folder
dirs('Run') = fullfile(dirs('Root'), 'Data', sdr);
    tags('Config')      = fullfile(dirs('Run'), 'Config.mat');
    tags('Parameters')  = fullfile(dirs('Run'), 'Parameters.txt');
    dirs('Images')      = fullfile(dirs('Run'), 'Images');
        tags('dcimg')       = fullfile(dirs('Images'), 'rec00001');
    dirs('Behaviour')   = fullfile(dirs('Run'), 'Behaviour');
    dirs('Stimulus')    = fullfile(dirs('Run'), 'Stimulus');
    dirs('Analysis')    = fullfile(dirs('Run'), 'Analysis');
        % stacks
        dirs('graystack')     = fullfile(dirs('Analysis'), 'graystack.stack');
            tags('graystack')     = fullfile(dirs('graystack'), 'graystack');
            tags('graystackROI')     = fullfile(dirs('graystack'), 'graystackROI');
        dirs('refStack')     = fullfile(dirs('Analysis'), 'refStack.stack');
            tags('refStack')      = fullfile(dirs('refStack'), 'refStack');
        dirs('rawRAS')        = fullfile(dirs('Analysis'), 'rawRAS.stack');
            tags('rawRAS')        = fullfile(dirs('rawRAS'), 'rawRAS');
        dirs('corrected')     = fullfile(dirs('Analysis'), 'corrected.stack');
            tags('corrected')     = fullfile(dirs('corrected'), 'corrected');
        % folders
        dirs('Background')    = fullfile(dirs('Analysis'), 'Background');
            tags('background')     = fullfile(dirs('Background'), 'background.mat');
        dirs('Drift')         = fullfile(dirs('Analysis'), 'Drift');
        dirs('Mask')          = fullfile(dirs('Analysis'), 'Mask');
            tags('mask')          = fullfile(dirs('Mask'), 'mask.mat');
        dirs('Registration')  = fullfile(dirs('Analysis'), 'Registration');
        dirs('Regression')    = fullfile(dirs('Analysis'), 'Regression');
        dirs('Segmentation')  = fullfile(dirs('Analysis'), 'Segmentation');
        dirs('Baseline')      = fullfile(dirs('Analysis'), 'Baseline');
            dirs('BaselineNeuron') = fullfile(dirs('Baseline'), 'neuron');
            dirs('BaselinePixel')  = fullfile(dirs('Baseline'), 'pixel');
        dirs('DFF')           = fullfile(dirs('Analysis'), 'DFF');
            dirs('DFFNeuron')      = fullfile(dirs('DFF'), 'neuron');
            dirs('DFFPixel')       = fullfile(dirs('DFF'), 'pixel');
        % pmp = PhaseMapPixel, pmn = PhaseMapNeuron to prevent collision
        dirs('PhaseMap')      = fullfile(dirs('Analysis'), 'PhaseMap');
            dirs('PhaseMapSignal') = fullfile(dirs('PhaseMap'), 'signal');
                dirs('PhaseMapSignalPixel')      = fullfile(dirs('PhaseMapSignal'), 'pixel');
                    fillArch('PhaseMapSignalPixel',...
                        'pmpsig',... 'phasemap on signal
                        {'amplitude', 'phase', 'deltaphi', 'realpart', 'imaginary'});
                dirs('PhaseMapSignalNeuron')     = fullfile(dirs('PhaseMapSignal'), 'neuron');
                    fillArch('PhaseMapSignalNeuron',...
                        'pmnsig',...
                        {'amplitude', 'phase', 'deltaphi', 'realpart', 'imaginary'});
            dirs('PhaseMapDFF') = fullfile(dirs('PhaseMap'), 'dff');
                dirs('PhaseMapDFFPixel')      = fullfile(dirs('PhaseMapDFF'), 'pixel');
                    fillArch('PhaseMapDFFPixel',...
                        'pmpdff',...
                        {'amplitude', 'phase', 'deltaphi', 'realpart', 'imaginary'});
                dirs('PhaseMapDFFNeuron')     = fullfile(dirs('PhaseMapDFF'), 'neuron');
                    fillArch('PhaseMapDFFNeuron',...
                        'pmndff',...
                        {'amplitude', 'phase', 'deltaphi', 'realpart', 'imaginary'});
        dirs('HDF5')          = fullfile(dirs('Analysis'), 'HDF5');
    dirs('Garbage')     = fullfile(dirs('Run'), 'Garbage'); % unsorted files

% Programs folder
dirs('Programs') = fullfile(dirs('Root'), 'Programs');
    dirs('easyRLS') = fullfile(dirs('Programs'), 'easyRLS');
        dirs('caTools') = fullfile(dirs('easyRLS'), fullfile('Tools','caTools'));
    dirs('NeuroTools') = fullfile(dirs('Programs'), 'NeuroTools');
    
% RefBrains folder
dirs('RefBrains') = fullfile(dirs('Root'), 'RefBrains');

% averaged phasemaps
dirs('AveragedPhaseMaps') = fullfile(dirs('Root'), 'Data', 'AveragedPhaseMaps');


% functions
% the goal of these functions is to get names depending of focus parameters
% that can change after focus definition
gets.refBrainName = @refBrainName;
gets.refPath = @refPath;
gets.regPath = @regPath;
gets.transPath = @transPath;
gets.autoTransName = @autoTransName;



% function
    function fillArch(parent, prefix, labels)
        % this function create a list of tags following the pattern
        
        for l = labels
            fulltag = [ prefix '_' l{:} ];
            dirs(fulltag) = fullfile(dirs(parent), [l{:} '.stack']);
                tags(fulltag)       = fullfile(dirs(fulltag), l{:});
        end
    end

end

function out = refBrainName(F)
% shorten the reBrainName (removes the extension)
    sp = split(F.Analysis.RefBrain, '.');
    out = sp{1};
end

function out = refPath(F)
% give the path of the reference brain
    out = fullfile(F.dir('RefBrains'), F.Analysis.RefBrain);
end

function out = regPath(F)
    out = fullfile(F.dir('Registration'), refBrainName(F));
end

function out = transPath(F, transformation, mov)
    out = fullfile(regPath(F), string([autoTransName(F, transformation, mov) '.xform']));
end

function [transformation, reformatedName] = autoTransName(F, transformation, mov)
% --- DRAFT --- returns automatic name for transformation
% this function treats 'affine' and 'warp' as default cases
    switch transformation % detect default cases
        case 'affine' % search affine
            transformation = [ 'AFFINE_' mov '_TO_' refBrainName(F) ];
            reformatedName = [ 'AFFINE_' mov '_ON_' refBrainName(F) ];
        case 'warp' % search non-rigid
            transformation = [ 'WARP_' mov '_TO_' refBrainName(F) ];
            reformatedName = [ 'WARP_' mov '_ON_' refBrainName(F) ];
        otherwise % personal transformation
            % transformation does not change
            reformatedName = [ 'reformated-with_' transformation ];                
    end
end
