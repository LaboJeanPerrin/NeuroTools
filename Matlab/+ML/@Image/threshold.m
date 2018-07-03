function out = threshold(this, varargin)
%IMAGES.IMAGE.THRESHOLD thresholds image
%*  IMAGES.IMAGE.THRESHOLD(VAL) thresholds the image at value VAL. All 
%   pixels above or equal to VAL are kept.
%
%*  IMAGES.IMAGE.THRESHOLD(..., 'method', METHOD) specifies the method to 
%   use. METHOD should be a string and the same values as in 
%   IMAGES.IMAGE.FILTER are authorized.
%
%*  IMAGES.IMAGE.THRESHOLD(..., 'box', BOX) specifies the size of the 
%   filter. BOX should be a 1-by-2 array [width height].
%
%*  IMAGES.IMAGE.THRESHOLD(..., 'shift', S) add the shift S to the output 
%   of the filter, before the comparison with the input image.
%
%*  IMG = IMAGES.IMAGE.THRESHOLD(...) returns a new instance of image 
%   object.
%
%*  See also: Images.Image, Images.Image.filter.

% === Input variables =====================================================

in = inputParser;
in.addOptional('thresh', NaN, @isnumeric);
in.addParamValue('method', 'direct', @ischar);
in.addParamValue('shift', 0, @isnumeric);
in.addParamValue('box', [16 16], @isnumeric);

in.parse(varargin{:});
in = in.Results;

% =========================================================================

% --- Proceed
switch lower(in.method)
    
    case 'direct'
       comp = in.thresh;
       
    case 'otsu'
       comp = graythresh(this.pix);
        
    otherwise
        tmp = this.filter(in.method, 'box', in.box);
        comp = tmp.pix + in.shift;
        
         % nlfilter(img,[1 1]*20,fun);
end

tmp = double(this.pix >= comp);

% --- Output
if nargout
    out = Images.Image(tmp);
else
    this.pix = tmp;
    this.update_infos();
end