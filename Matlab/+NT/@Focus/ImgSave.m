function isave(this, img, tag, varargin)
%FOCUS.ISAVE save an image in the Figures directory.
%*  FOCUS.ISAVE(IMG, TAG) saves image IMG in the TAG file in the
%   Figures directory.
%
%[  Note: A TAG composed of tokens separated by the filesystem separator
%   will save the file in subfolders. TAG supports both '@' and '@@'
%   shortcuts, See FOCUS.GNAME. ]
%
%*  See also: Focus, Focus.gname, Focus.iload.

% === Input variables =====================================================

in = ML.Input(img, tag, varargin{:});
in.addRequired('img', @(x) isnumeric(x) | isa(x,'Image'));
in.addRequired('tag', @ischar);
in.addParamValue('type', 'png', @ischar);
in.addParamValue('fname', '', @ischar);
in.addParamValue('bitdepth', 8, @isnumeric);
in.addParamValue('quiet', false, @islogical);
in = +in;

% =========================================================================

% --- Get the file name
if isempty(in.fname)
    in.fname = [this.gname(in.tag) '.' in.type];
end

% --- Create the directory (if needed)
d = fileparts(in.fname);
if ~exist(d, 'dir')
    fprintf('→ Creating folder : %s\n', d);
    mkdir(d);
end

% --- Manage Image objects
if isa(in.img, 'Image')
    img = in.img.pix;
else
    img = in.img;
end

% --- Prepare bitdpeth
switch in.bitdepth
    case 8
        img = uint8(img);
    case 16
        img = uint16(img);
end

% --- Save the image
imwrite(img, in.fname, in.type, 'bitdepth', in.bitdepth);

% --- Confirmation
if ~in.quiet
%     Text.msg(in.fname, 'title', 'Image saved', 'icon', 'save');
end
