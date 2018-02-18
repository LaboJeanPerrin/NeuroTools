classdef Viewer<handle
%NT.Viewer Class to visualize data

    % --- PROPERTIES ------------------------------------------------------
    properties (Access = public)
        
        stacks
        
        mode
        figure
        visu
        image
        info
        slider
        
        bgcolor
        visuWidth
        visuHeight
        infosHeight
        sliderHeight
        
        x = NaN
        y = NaN
        z = NaN
        t = NaN
        X = NaN
        Y = NaN
        Z = NaN
        T = NaN
        zoom
        
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
            
            % --- Define stacks structure ---------------------------------
            
            %   mode:   'xy', 'xyt', 'xyz' or 'xyzt'
            %   type:   'array' or 'paf'
            %   data:   An array or a NT.Paf object
            %   size:   A size array
            %   range:  A 2-element vector (intensities range)
            %   color:  A 3-element vector (RGB)
            
            this.stacks = struct('mode', {}, 'type', {}, 'size', {}, ...
                'data', {}, 'range', {}, 'color', {});
            
        end
            
    end
    
end
