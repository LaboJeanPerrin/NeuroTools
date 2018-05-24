classdef Focus < handle
%Focus Class providing access to NeuroTool datasets
    
    % --- PROPERTIES ------------------------------------------------------
    properties (Access = public)
        
        rootdir
        study
        date
        run
        name
        
        param
        frames
        units
        stim
        
        sets
        set
        IP       
        
% This part is not implemented (TODO)
        dx
        dy
        dt % currently, dt = delay + exposure (ignoring delay long)
%         binning

% empty structure to store analysis parameters
        Analysis
    end
    
    properties (Hidden)
        dir
        tag
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = Focus(path, study, date, run)
        %Focus::constructor
        % call focus with NT.Focus(path, study, date, run)
        
        % path:     root folder
        % study:    name of study (if '', ignored)
        % date:     date of experiment yyyy-mm-dd
        % run:      run number
                    
            % --- Basic properties ----------------------------------------

            this.study = study;
            this.date = date;
            
            if ischar(run)
                this.run = run;
            else
                this.run = ['Run ' num2str(run, '%02i')];
            end
            
            this.name = [this.study ' ' this.date ' (' this.run ')'];
            
            this.Analysis = struct(); % empty structure to store analysis parameters
            
            % --- Directories ---------------------------------------------
        
            % Preparation
            this.rootdir = path;
            
            % --- Data dir
            
            sdr = fullfile(this.study, this.date, this.run); % study date run
            
            % --- Architecture
            
            dirs = containers.Map; % directories
            tags = containers.Map; % tags

            dirs('Run') = fullfile(this.rootdir, 'Data', sdr);
                tags('Config') = fullfile(dirs('Run'), 'Config.mat');
                dirs('Images')      = fullfile(dirs('Run'), 'Images');
                    tags('dcimg')     = fullfile(dirs('Images'), 'stack');
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
                        dirs('RefBrain')      = fullfile(dirs('Registration'), 'RefBrain');
                            tags('RefBrain')      = fullfile(dirs('RefBrain'), 'RefBrain.nhdr');
                    dirs('Regression')    = fullfile(dirs('Analysis'), 'Regression');
                    dirs('PhaseMap')      = fullfile(dirs('Analysis'), 'PhaseMap');
                        dirs('amplitude')     = fullfile(dirs('PhaseMap'), 'amplitude.stack');
                            tags('amplitude')     = fullfile(dirs('amplitude'), 'amplitude');
                        dirs('phase')     = fullfile(dirs('PhaseMap'), 'phase.stack');
                            tags('phase')     = fullfile(dirs('phase'), 'phase');
                        dirs('real')     = fullfile(dirs('PhaseMap'), 'real.stack');
                            tags('real')     = fullfile(dirs('real'), 'real');
                        dirs('imaginary')     = fullfile(dirs('PhaseMap'), 'imaginary.stack');
                            tags('imaginary')     = fullfile(dirs('imaginary'), 'imaginary');
                    dirs('Segmentation')  = fullfile(dirs('Analysis'), 'Segmentation');
                    dirs('Baseline')      = fullfile(dirs('Analysis'), 'Baseline');
                        dirs('BaselineNeuron') = fullfile(dirs('Baseline'), 'neuron');
                        dirs('BaselinePixel')  = fullfile(dirs('Baseline'), 'pixel');
                    dirs('DFF')           = fullfile(dirs('Analysis'), 'DFF');
                        dirs('DFFNeuron')      = fullfile(dirs('DFF'), 'neuron');
                        dirs('DFFPixel')       = fullfile(dirs('DFF'), 'pixel');
                    dirs('HDF5')          = fullfile(dirs('Analysis'), 'HDF5');
                dirs('Garbage')     = fullfile(dirs('Run'), 'Garbage'); % unsorted files
                    
            this.dir = dirs;
            this.tag = tags;
            
            % Check existence
            if ~exist(this.dir('Run'), 'dir')
                error('No data found in %s', this.dir('Run'));
            end
            
            % --- create folders if necessary
           
            if ~exist(this.dir('Analysis'), 'dir')
                disp('creating ''Analysis'' directory')
                mkdir(this.dir('Analysis'));
            end

            % --- Parameters ----------------------------------------------
            
            paramPath = fullfile(this.dir('Run'), 'Parameters.txt');
                        
            if ~exist(paramPath, 'file')
                error('No Parameter file found at \n%s\n', paramPath);
            end
            
            P = NT.Parameters;
            P.load(paramPath);
       
            % Set Parameters
            
            % P.Version corresponds to the Lightsheet program version
            % (not the parameter file version)
            % the switch could be done on the parameter file version
            switch P.Version
            
                case {'4.1', '4.2'}
                
                    % --- Units
                    this.units = P.Units;
                    
                    % --- Parameters
                    this.param = struct();
                    this.param.LigthSheet_Version = P.Version;
                    this.param.Description = P.Description;
                    this.param.CameraModel = P.CameraModel;
                    this.param.FluoMode = P.FluoMode;
                    this.param.HM_Position_min = P.HM_Position_min;
                    this.param.HM_Position_max = P.HM_Position_max;
                    this.param.HM_um2V = P.HM_um2V;
                    this.param.VM_Position = P.VM_Position;
                    this.param.VM_um2V = P.VM_um2V;
                    this.param.OP_Position = P.OP_Position;
                    this.param.OP_um2V = P.OP_um2V;
                    this.param.HM_Mode = P.HM_Mode;
                    this.param.HM_Shape = P.HM_Shape;
                    this.param.HM_Rate = P.HM_Rate;
                    this.param.NLayers = P.NLayers;
                    this.param.Exposure = P.Exposure;
                    this.param.Delay = P.Delay;
                    this.param.DelayLong = P.DelayLong;
                    this.param.StepsShape = P.StepsShape;
                    this.param.Increment = P.Increment;
                    this.param.StabShape = P.StabShape;
                    this.param.StabRatio = P.StabRatio;
                    this.param.NCycles = P.NCycles;
                    this.param.CycleTime = P.CycleTime;
                    this.param.NFrames = P.NFrames;
                    this.param.RunTime = P.RunTime;
                                   
                    % --- Signals
                    this.stim = P.Signals;
                    
                otherwise
                    warning('Focus:Parameters', 'Couldn''t read this version of the Parameters file.');
            end
            
            % --- Frame information
            if exist(this.dir('Images'), 'dir')
                
                Images = dir([this.dir('Images') '*.tif']);
                if numel(Images)
                    
                    tmp = regexp(Images(1).name, '([^_]+_)(\d+)(\..*)', 'tokens');
                    Img = imfinfo([this.dir('Images') Images(1).name]);
                    
                    this.frames = struct();
                    this.frames.Number = numel(Images);
                    this.frames.Prefix = tmp{1}{1};
                    this.frames.Format = ['%0' num2str(numel(tmp{1}{2})) 'i'];
                    this.frames.Extension = tmp{1}{3};
                    this.frames.Width = Img.Width;
                    this.frames.Height = Img.Height;
                    this.frames.BitDepth = Img.BitDepth;
                    
                end
                
            else
                warning('Focus.frames will not be set without Image directory')
            end
            
            % --- Sets ----------------------------------------------------
            
            this.sets = struct('id', {}, 'type', {}, 'frames', {}, 'z', {});
            
            if this.param.NFrames == this.param.NLayers
                
                % -#- Scan -#-
                this.sets(1).id = 1;
                this.sets(1).type = 'Scan';
                this.sets(1).frames = 0:this.param.NFrames-1;
                this.sets(1).z = (0:this.param.NFrames-1)*this.param.Increment;
                
            else
                
                % -#- Stack -#-
                
                for i = 1:this.param.NLayers
                    this.sets(i).id = i;
                    this.sets(i).type = 'Layer';
                    this.sets(i).frames = (i-1):this.param.NLayers:this.param.NFrames-1;
                    this.sets(i).z = (i-1)*this.param.Increment;
                end
                
            end
            
            % --- Default set
            this.select(1);
            
            % --- Config file ---
            % if there is no config file, create it
            NT.Config(this)
        end
    end
    
    % --- STATIC METHODS --------------------------------------------------
    methods (Static)
      define(varargin)
      F = current()
   end
end
