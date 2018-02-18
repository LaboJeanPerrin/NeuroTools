classdef Viewer<handle
%NT.Viewer Class to visualize data

    % --- PROPERTIES ------------------------------------------------------
    properties (Access = public)
        
        stack
        
        fig
        axes
        img
        info
        slider
        
        infosHeight
        sliderHeight
        dispWidth
        dispHeight
        bgcolor
        
        zoom
        Nframes = NaN;
        
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = Viewer(varargin)
        %NT.Viewer Constructor
        
            % --- Inputs --------------------------------------------------
            
            % Validation
            p = inputParser;
            addParameter(p, 'zoom', 2, @isnumeric);
            parse(p, varargin{:});
            
            % Assignation
            this.zoom = max(1,round(p.Results.zoom));
            
            % --- Parameters ----------------------------------------------
            
            this.infosHeight = 20;
            this.sliderHeight = 20;
            this.bgcolor = [1 1 1]*0.15;
            
            % --- Define stack structure ----------------------------------
            
            this.stack = struct('data', {}, 'range', {}, 'color', {});
            
        end
            
    end
    
end
