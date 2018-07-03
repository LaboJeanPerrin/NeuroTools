function rm_infos(this, varargin)
%[Image].rm_infos Remove information pixels of an image.
%   [Image].RM_INFOS() Remove pixel information from the current image.
%
%*  See also: Image.autorange, PCO.rm_infos.

switch this.camera
    
    case 'PCO.Edge'
        this = PCO.rm_infos(this, varargin{:});
        this.update_infos();
        
    otherwise
        % warning('No procedure is defined to remove information from the image.');
        
end
