classdef Image<handle
%IMAGES.IMAGE is the Image class.
    
    % --- PROPERTIES ------------------------------------------------------
    properties
        
        path = '';
        name = '';
        ext = '';
        pix = NaN;
        vmin = NaN;
        vmax = NaN;
        width = NaN;
        height = NaN;
        cmap = [];
        tag = '';
        infos = '';
        
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = Image(img, varargin)
        %Image::constructor
        
            if exist('img', 'var')
                if ischar(img)
                    this.load(img, varargin{:});
                elseif isnumeric(img) || islogical(img)
                    this.pix = img;
                    this.update_infos();
                end
            end
        end
    end
end
