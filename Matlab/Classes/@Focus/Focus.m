classdef Focus<handle
%Focus Class providing access to NeuroTool datasets
    
    % --- PROPERTIES ------------------------------------------------------
    properties (Access = public)
        
        study
        date
        run
        name
        dir
        
        param
        frames
        units
        stim
        
        sets
        set
        
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = Focus(varargin)
        %Focus::constructor
        
            % --- Inputs --------------------------------------------------
            
            in = ML.Input;
            in.study = @ischar;
            in.date = @ischar;
            in.run = @(x) ischar(x) || isnumeric(x);
            in.verbose(false) = @islogical;
            in = +in;
                    
            % --- Basic properties ----------------------------------------
            
            this.study = in.study;
            this.date = in.date;
            
            if ischar(in.run)
                this.run = in.run;
            else
                this.run = ['Run ' num2str(in.run, '%02i')];
            end
            this.name = [this.study ' - ' this.date ' (' this.run ')'];
            
            % --- Directories ---------------------------------------------
        
            % Preparation
            proj = ML.Projects.select;
            this.dir = struct();
            
            % --- Data dir
            
            this.dir.data = [proj.path 'Data' filesep this.study filesep this.date filesep this.run filesep];
            
            % Check existence
            if ~exist(this.dir.data, 'dir')
                warning('Focus:Data', 'No data found for study=%s, date=%s and run=%i.', this.study, this.date, this.run);
            end
            
            % --- Other folders
            
            this.dir.images = [this.dir.data 'Images' filesep];
            this.dir.files = [this.dir.data 'Files' filesep];
            this.dir.figures = [proj.path 'Figures' filesep];
            this.dir.movies = [proj.path 'Movies' filesep];
            
            % --- Parameters ----------------------------------------------
            
            P = Parameters;
            P.load([this.dir.data 'Parameters.txt']);
            
            kvufile = [this.dir.data 'KVU.txt'];
            if exist(kvufile, 'file')
                P.load_KVU(kvufile);
            end
                        
            % --- Checks
                        
            % Study
            if ~strcmp(this.study, P.Study)
                error('Focus:Study', 'Studies do not match. This is a serious problem with the Parameters file.');
            end
            
            % Date
            if ~strcmp(this.date, P.Date)
                error('Focus:Date', 'Dates do not match. This is a serious problem with the Parameters file.');
            end
            
            % Run
            if ~strcmp(this.run, P.RunName)
                error('Focus:Run', 'Run names do not match. This is a serious problem with the Parameters file.');
            end
            
            % Set Parameters
            
            switch P.Version
            
                case '4.1'
                
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
                    
                    % --- KVU parameters
                    keys = fieldnames(P.KVU);
                    for i = 1:numel(keys)
                        this.param.(keys{i}) = P.KVU.(keys{i});
                        if isfield(P.Units.KVU, keys{i})
                            this.units.KVU.(keys{i}) = P.Units.KVU.(keys{i});
                        end
                    end
                    
                    % --- Signals
                    this.stim = P.Signals;
                                        
                otherwise
                    warning('Focus:Parameters', 'Couldn''t read this version of the Parameters file.');
            end
            
            % --- Frame information
            if exist(this.dir.images, 'dir')
                
                Images = dir([this.dir.images '*.tif']);
                if numel(Images)
                    
                    tmp = regexp(Images(1).name, '([^_]+_)(\d+)(\..*)', 'tokens');
                    Img = imfinfo([this.dir.images Images(1).name]);
                    
                    this.frames = struct();
                    this.frames.Number = numel(Images);
                    this.frames.Prefix = tmp{1}{1};
                    this.frames.Format = ['%0' num2str(numel(tmp{1}{2})) 'i'];
                    this.frames.Extension = tmp{1}{3};
                    this.frames.Width = Img.Width;
                    this.frames.Height = Img.Height;
                    this.frames.BitDepth = Img.BitDepth;
                    
                end
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
            
            % --- Current Focus -------------------------------------------

            % --- Define as current focus
            gname = 'NeuroTools';
            ML.Session.set(gname, 'Focus', this);

            % --- Verbose
            if in.verbose
                ML.CW.print('The current focus is now ~bc[teal]{%s}.\n', this.name);
            end
            
        end
    end
    
    % --- STATIC METHODS --------------------------------------------------
    methods (Static)
      define(varargin)
      F = current()
   end
end
