classdef PCO<handle
%PCO Class
    
    % --- PROPERTIES ------------------------------------------------------
    properties (Access = public)
        
        Video
        Source
        
        TriggerMode = 'immediate';
        Binning = [2 2];
        Convf = 0;
        Exposure = 5000;            % In microseconds
        PixelClock = '286000000';   % '95333333' or '286000000'
        
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = PCO(varargin)
        %PCO::constructor
        
            
        
        end
    end
    
    % --- STATIC METHODS --------------------------------------------------
    methods (Static)
      
   end
end
