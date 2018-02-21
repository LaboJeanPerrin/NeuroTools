classdef Focus < handle
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
        IP       
        
% This part is not implemented
%         dx
%         dy
%         dt
%         exposure
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = Focus(args)
        %Focus::constructor
        
            % --- Inputs --------------------------------------------------
            
            in = inputParser;
            in.addRequired('path', @ischar);        % Hugo Trentesaux added path to get rid of Mlab projects plugin
            in.addRequired('study', @ischar);
            in.addRequired('date', @ischar);
            in.addRequired('run', @(x) ischar(x) || isnumeric(x));
            
            in.parse(args{:})
                    
            % --- Basic properties ----------------------------------------
            
            this.study = in.Results.study;
            this.date = in.Results.date;
            
            if ischar(in.Results.run)
                this.run = in.Results.run;
            else
                this.run = ['Run ' num2str(in.Results.run, '%02i')];
            end
            this.name = [this.study ' - ' this.date ' (' this.run ')'];
            
            % --- Directories ---------------------------------------------
        
            % Preparation
            this.dir = struct();
            
            this.dir.root = in.Results.path;
            
            % --- Data dir
            
            this.dir.data = fullfile(this.dir.root, 'Data', this.study, this.date, this.run);
            
            % Check existence
            if ~exist(this.dir.data, 'dir')
                warning('Focus:Data', 'No data found for study=%s, date=%s and run=%i.', this.study, this.date, this.run);
            end
            
            % --- Other folders
            
            this.dir.images = fullfile(this.dir.data, 'Images');
            this.dir.files = fullfile(this.dir.data, 'Files');
            this.dir.IP = fullfile(this.dir.files, 'IP');
            this.dir.figures = fullfile(in.Results.path, 'Figures');
            this.dir.movies = fullfile(in.Results.path, 'Movies');
            
            % --- create folders if necessary (TODO all necessary folders)
            
            if ~exist(this.dir.files, 'dir')
                disp('creating File directory')
                mkdir(this.dir.files); % TODO handle error properly
                mkdir(this.dir.IP); % TODO handle error properly
            end

            % --- Parameters ----------------------------------------------
            
            paramPath = fullfile(this.dir.data, 'Parameters.txt');
                        
            if ~exist(paramPath, 'file')
                error('No Parameter file found at \n%s\n', paramPath);
            end
            
            P = NT.Parameters;
            P.load(paramPath);
       
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
            
            % --- Config file ---
            % if there is no config file, create it
            Routines.Config(this)
        end
    end
    
    % --- STATIC METHODS --------------------------------------------------
    methods (Static)
      define(varargin)
      F = current()
   end
end
