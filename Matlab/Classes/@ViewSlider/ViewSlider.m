classdef ViewSlider<handle
%ViewSliderClass to view 3D arrays with a slider

    % --- PROPERTIES ------------------------------------------------------
    properties (Access = public)
        
        stack
        
        fig
        axes
        img
        slider
        
        dispWidth
        dispHeight
        sliderHeight
        
        zoom
        Nframes = NaN;
        
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = ViewSlider(varargin)
        %ViewSlider::constructor
        
            % --- Inputs --------------------------------------------------
            
            % Validation
            p = inputParser;
            addParameter(p, 'zoom', 2, @isnumeric);
            parse(p, varargin{:});
            
            % Assignation
            this.zoom = max(1,round(p.Results.zoom));
            
            % --- Parameters ----------------------------------------------
            
            this.sliderHeight = 20;
            
            % --- Define stack structure ----------------------------------
            
            this.stack = struct('data', {}, 'range', {}, 'color', {});
            
        end
            
    end
    
end
