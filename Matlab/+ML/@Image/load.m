function load(this, name, varargin)
%IMAGES.IMAGE.LOAD Load 
%*  IMAGES.IMAGE.LOAD(FILENAME) load a file as an image.
%
%*  See also: Images.Image.save.

% === Input variables =====================================================

in = inputParser;
in.addRequired('name', @ischar);
in.addParamValue('class', 'double', @ischar);

in.parse(name, varargin{:});
in = in.Results;

% =========================================================================

% Set file info
[this.path, this.name, this.ext] = fileparts(in.name);
this.path = [this.path filesep()];
this.ext = this.ext(2:end);
    
% Load file
switch in.class
    case 'uint8', this.pix = uint8(imread(in.name));
    case 'uint16', this.pix = uint16(imread(in.name));
    case 'double', this.pix = double(imread(in.name));
end

% Update infos
this.update_infos();
