function H = hist(this, varargin)
%IMAGES.IMAGE.HIST image histogram
%*  IMAGES.IMAGE.HIST() display the histogram of the image.
%
%*  IMAGES.IMAGE.HIST(FIG) display the histogram in figure FIG.
%
%*  H = IMAGES.IMAGE.HIST(...) returns a structure with fields:
%   * 'bin'
%   * 'hist'
%   and do not display anything.
%
%*  See also: Images.Image.

% === Input variables =====================================================

in = inputParser;
in.addOptional('fig', NaN, @isnumeric);

in.parse(varargin{:});
in = in.Results;

% =========================================================================
    
% Get range
minv = min(this.pix(:));
maxv = max(this.pix(:));

switch size(this.pix,3)
    
    case 1      % --- BW images -------------------------------------------
        
        [h, bin] = hist(double(this.pix(:)), double(minv:maxv));
        
        if nargout
            H = struct('bin', bin, 'hist', h);
        else
            
            % Set figure
            if isnan(in.fig), in.fig = gcf; end
            figure(in.fig);
            
            % Plot
            plot(bin, h, 'k');
        end

    case 3      % --- True Color images -----------------------------------
        
        dpix = min(diff(unique(this.pix(:))));
        bin = 0:dpix:1;        
        tmp = double(this.pix(:,:,1)); rh = hist(tmp(:), bin);
        tmp = double(this.pix(:,:,2)); gh = hist(tmp(:), bin);
        tmp = double(this.pix(:,:,3)); bh = hist(tmp(:), bin);
        
        if nargout
            H = struct('bin', bin, 'rhist', rh, 'ghist', gh, 'bhist', bh);
        else
            
            % Set figure
            if isnan(in.fig), in.fig = gcf; end
            figure(in.fig);
            
            % Plot
            hold on
            plot(bin, rh, 'r');
            plot(bin, gh, 'g');
            plot(bin, bh, 'b');
            
        end
end

% --- Adjustment
box on
xlim([minv maxv]);