function out = rm_infos(varargin)
%PCO.rm_infos Remove information in the upper-left part of a PCO image.
%
%   See also: PCO.timestamp

% --- Inputs --------------------------------------------------------------

in = ML.Input;
in.Img = @(x) isnumeric(x) | isa(x, 'Image');
in.rep(NaN) = @isnumeric;
in = +in;

% --- Parameters ----------------------------------------------------------

x = 1:8;
y = 1:292;

if isa(in.Img, 'Image')

    % --- Image object

    % Default value
    if isnan(in.rep)        
        in.rep = in.Img.Pixels(1,y(end)+1);
    end
    
    % Replacement
    in.Img.Pixels(x,y) = in.rep;
    
    % Output
    if nargout
        out = in.Img.Pixels;
    end
    
else

    % --- Image array

    % Default value
    if isnan(in.rep)        
        in.rep = in.Img(1,y(end)+1);
    end
    
    % Replacement
    in.Img(x,y) = in.rep;

    % Output
    if nargout
        out = in.Img;
    end
end