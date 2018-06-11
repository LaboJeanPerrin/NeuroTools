function [dirs, tags] = architecture(rootdir, sdr)
% returns the file hierarchy
% sdr is fullfile study/date/run

% --- Architecture
            
dirs = containers.Map; % directories
tags = containers.Map; % tags

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
            dirs('PhaseMapPixel')      = fullfile(dirs('PhaseMap'), 'pixel');
                dirs('pmp_amplitude')       = fullfile(dirs('PhaseMapPixel'), 'amplitude.stack');
                    tags('pmp_amplitude')       = fullfile(dirs('pmp_amplitude'), 'amplitude');
                dirs('pmp_phase')           = fullfile(dirs('PhaseMapPixel'), 'phase.stack');
                    tags('pmp_phase')           = fullfile(dirs('pmp_phase'), 'phase');
                dirs('pmp_deltaphi')        = fullfile(dirs('PhaseMapPixel'), 'deltaphi.stack');
                    tags('pmp_deltaphi')        = fullfile(dirs('pmp_deltaphi'), 'deltaphi');
                dirs('pmp_realpart')        = fullfile(dirs('PhaseMapPixel'), 'realpart.stack');
                    tags('pmp_realpart')        = fullfile(dirs('pmp_realpart'), 'realpart');
                dirs('pmp_imaginary')       = fullfile(dirs('PhaseMapPixel'), 'imaginary.stack');
                    tags('pmp_imaginary')       = fullfile(dirs('pmp_imaginary'), 'imaginary');
            dirs('PhaseMapNeuron')     = fullfile(dirs('PhaseMap'), 'neuron');
                dirs('pmn_amplitude')       = fullfile(dirs('PhaseMapNeuron'), 'amplitude');
                    tags('pmn_amplitude')       = fullfile(dirs('pmn_amplitude'), 'amplitude.stack');
                dirs('pmn_phase')           = fullfile(dirs('PhaseMapNeuron'), 'phase');
                    tags('pmn_phase')       = fullfile(dirs('pmn_phase'), 'phase.stack');
                dirs('pmn_deltaphi')        = fullfile(dirs('PhaseMapNeuron'), 'deltaphi');
                    tags('pmn_deltaphi')       = fullfile(dirs('pmn_deltaphi'), 'deltaphi.stack');
                dirs('pmn_realpart')        = fullfile(dirs('PhaseMapNeuron'), 'realpart');
                    tags('pmn_realpart')       = fullfile(dirs('pmn_realpart'), 'realpart.stack');
                dirs('pmn_imaginary')       = fullfile(dirs('PhaseMapNeuron'), 'imaginary');
                    tags('pmn_imaginary')       = fullfile(dirs('pmn_imaginary'), 'imaginary.stack');
        dirs('HDF5')          = fullfile(dirs('Analysis'), 'HDF5');
    dirs('Garbage')     = fullfile(dirs('Run'), 'Garbage'); % unsorted files

% Programs folder
dirs('Programs') = fullfile(dirs('Root'), 'Programs');
    dirs('easyRLS') = fullfile(dirs('Programs'), 'easyRLS');
        dirs('caTools') = fullfile(dirs('easyRLS'), fullfile('Tools','caTools'));
    dirs('NeuroTools') = fullfile(dirs('Programs'), 'NeuroTools');
    
% RefBrains folder
dirs('RefBrains') = fullfile(dirs('Root'), 'RefBrains');

end