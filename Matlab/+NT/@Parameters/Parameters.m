classdef Parameters < handle

    properties (Access = public)
               
        % --- Header
        Version
        Study
        Date
        RunName
        Description

        % --- Window
        Screen = 1;
        
        % --- Folders
        DataRoot
        
        % --- Images
        CameraModel
        FluoMode
        
        % --- Mirrors & piezo
        HM_Position_min
        HM_Position_max
        HM_Position
        HM_um2V
        HM_Symmetrize
        
        VM_Position
        VM_um2V
        
        OP_Position
        OP_um2V
        
        % --- Light scan
        HM_Mode
        HM_Shape
        HM_Rate
        
        DelayBefore
        DelayAfter
        
        % --- Layers
        NLayers
        Exposure
        Delay
        
        DelayLong
        StepsShape
        Increment
        StabShape
        StabRatio
        
        % --- Timing
        NCycles
        CycleTime
        NFrames
        RunTime
        
        % --- Signals
        Signals
        
        % --- Units
        Units
        
        % --- Key-Value-Unit
        KVU
        
    end
    
    methods
        
        % --- Constructor -------------------------------------------------
        function this = Parameters(varargin)
            
            % Default Units
            this.Units = struct('Length', [char(181) 'm'], ...
                'Time', 'ms', ...
                'Frequency', 'Hz', ...
                'Ratio', '%', ...
                'KVU', struct());
            
            % Default KVU
            this.KVU = struct();
            
        end
        
    end
    
end