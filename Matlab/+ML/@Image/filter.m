function out = filter(this, fname, varargin)
%IMAGES.IMAGE.FILTER filters the image
%*  IMAGES.IMAGE.FILTER(FNAME) filters the image with filter FNAME. 
%   FNAME is a string which can be:
%   * 'Gaussian': Gaussian filter. Optional parameters are:
%                 - 'box' ([3 3]) filter size
%                 - 'sigma' (0.5) standard deviation (positive)
%
%   * 'Laplacian': 3-by-3 filter approximating the shape of the 2D Laplacian
%                operator. Optional parameters are:
%                 - 'alpha' (0.2) shape of the Laplacian (between 0 and 1)
%
%   * 'mean'    : Mean filter. Optional parameters are:
%                 - 'box' ([16 16]) filter size
%
%   * 'median'  : Median filter. Good for removing "salt & pepper noise",
%                 while keeping the edges sharp. Optional parameters are:
%                 - 'box' ([16 16]) filter size
%
%   * 'motion'  : Motion blur. Optional parameters are:
%                 - 'vec' ([5 5]) motion vector
%
%   * 'Prewitt' : Monodirectional edge detection. Optional parameters are:
%                 - 'axis' ('x') edge detection axis ('x' or 'y')
%
%   * 'Sobel'   :
%
%   * 'Laplacian' :
%
%*  IMAGES.IMAGE.FILTER(..., 'v', true) turns verbose on.
%
%*  IMG = IMAGES.IMAGE.FILTER(...) returns a new instance of image object.
%
%*  See also: Images.Image, Images.Image.threshold.

% === Input variables =====================================================

in = inputParser;
in.addRequired('filter', @ischar);
in.addParamValue('v', false, @islogical);

switch lower(fname)
    case 'gaussian'
        in.addParamValue('box', [3 3], @isnumeric);
        in.addParamValue('sigma', 0.5, @isnumeric);
    case 'laplacian'
        in.addParamValue('box', [3 3], @isnumeric);
        in.addParamValue('sigma', 0.5, @isnumeric);
    case 'mean'
        in.addParamValue('box', [16 16], @isnumeric);
    case 'median'    
        in.addParamValue('box', [16 16], @isnumeric);
    case 'motion'
        in.addParamValue('vec', [5 5], @isnumeric);
    case 'prewitt'
        in.addParamValue('axis', 'x', @ischar);
    case 'sobel'
        in.addParamValue('axis', 'x', @ischar);
end

in.parse(fname, varargin{:});
in = in.Results;

% =========================================================================

% --- Inputs
if isfield(in, 'box') && numel(in.box)==1
    in.box = in.box*[1 1]; 
end

% --- Verbose
if in.v
    if isfield(in, 'box')
        fprintf('Applying [%ix%i] %s filter ...', in.box, in.filter);
    else
        fprintf('Applying %s filter ...', in.filter);
    end
    tic;
end
    

switch lower(in.filter)
    
    case 'gaussian'
        
        tmp = imfilter(this.pix, fspecial('gaussian', in.box, in.sigma), 'same');
        
    case 'laplacian'
        
        [X, Y] = meshgrid(linspace(1-in.box(1),in.box(1)-1,in.box(1))/2, ...
                          linspace(1-in.box(2),in.box(2)-1,in.box(2))/2);
        
        F = -1/pi/in.sigma^4*(1-(X.^2+Y.^2)/2/in.sigma^2).*exp(-(X.^2+Y.^2)/2/in.sigma^2);
        
        
        tmp = imfilter(this.pix, F, 'same');
        
    case 'mean'
        
        tmp = conv2(double(this.pix), double(ones(in.box)/prod(in.box)), 'same');
    
    case 'median'
        
        tmp = medfilt2(this.pix, in.box);
        
    case 'motion'
        
        tmp = imfilter(this.pix, fspecial('motion', in.vec(1), in.vec(2)), 'replicate');
        
    case 'prewitt'
        
        switch in.axis
            case 'x'
                tmp = imfilter(this.pix, fspecial('prewitt')', 'same');
            case 'y'
                tmp = imfilter(this.pix, fspecial('prewitt'), 'same');
            case 'both'
                tmp = (imfilter(this.pix, fspecial('prewitt'), 'same') + ...
                       imfilter(this.pix, fspecial('prewitt')', 'same'))/2;
        end
        
    case 'sobel'
        
        switch in.axis
            case 'x'
                tmp = imfilter(this.pix, fspecial('sobel')', 'same');
            case 'y'
                tmp = imfilter(this.pix, fspecial('sobel'), 'same');
        end
end

% --- Verbose
if in.v
    fprintf(' %.2fs\n', toc); 
end

% --- Output
if nargout
    out = Images.Image(tmp);
else
    this.pix = tmp;
end