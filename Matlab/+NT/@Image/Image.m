classdef Image<ML.Image
%IMAGE is the Image class.
    
    % --- PROPERTIES ------------------------------------------------------
    properties
        camera = '';
        range = '';
        tstamp = NaN;
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = Image(img)
        %Image::constructor

            % --- Call the parent's constructor
            this = this@ML.Image(img);
            
        end
        
        % _________________________________________________________________
        function h = show(this, varargin)
        %SHOW show function
        
            in = ML.Input(varargin{:});
            in.addParamValue('range', [], @isnumeric);
            in = +in;
            
            if isempty(in.range) && ~isempty(this.range)
                varargin{end+1} = 'range';
                varargin{end+1} = this.range;
            end
            
            % --- Call the parent's constructor
            out = show@ML.Image(this, varargin{:});
        
            % Adjustments
            hold on
            colorbar
            
            % --- Output
            if nargout
                h = out;
            end
            
        end
    end
end
