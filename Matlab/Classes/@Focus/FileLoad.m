function [out, desc] = FileLoad(this, varargin)
%[Focus].FileLoad Load a tagged file from the focus files folder.
%   OUT = FileLoad(TAG) loads the content of the file tagged with TAG. OUT
%   is a struct.
%
%   OUT = FileLoad(TAG, KEYS) loads only some keys. KEYS can be either a
%   string or a cell arrau of strings.
%
%   FileLoad(..., 'ext', EXT) specifies the extension of the matfile. The
%   default value is '.mat'.
%
%   See also: Focus, Focus.FileName, Focus.FileSave

% --- Input variables -----------------------------------------------------

in = ML.Input;
in.tag = @ischar;
in.key = @(x) ischar(x) || iscellstr(x);
in.ext('mat') = @ischar;
in = +in;

% -------------------------------------------------------------------------

% --- Checks
if ischar(in.key)
    in.key = {in.key};
end

% --- Get the file name
fname = this.FileName(in.tag, 'ext', in.ext);

% --- Load content
M = ML.matfile(fname);
[out, desc] = M.load(in.key{:});
