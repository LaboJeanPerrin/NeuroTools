function fileSave(this,varargin)
%[Focus].FileSave Save data in a tagged-file.
%   FileSave(TAG, KEY, VAL) saves the value VAL of the variable KEY in the 
%   file tagged with TAG. The tagged file is located in the files directory
%   of the Focus object.
%
%   FileSave(TAG, KEY, VAL, DESC) includes a textual description of the
%   content of the variable. It is highly recommended to systematically add
%   an accurate description for each variable.
%
%   FileSave(..., 'ext', EXT) specifies the extension of the matfile. The
%   default value is '.mat'.
%
%   See also: Focus, Focus.FileName, Focus.FileLoad

% --- Input variables -----------------------------------------------------

in = ML.Input;
in.tag = @ischar;
in.key = @ischar;
in.value = @(x) true;
in.desc{''} = @ischar;
in.ext('mat') = @ischar;
in = +in;

% -------------------------------------------------------------------------

% --- Get the file name
fname = this.fileName(in.tag, 'ext', in.ext);

% % --- Create the directory (if needed)
% dir = fileparts(fname);
% if ~exist(dir,'dir')
%      fprintf('→ Creating folder : %s\n',dir);
%      mkdir(dir);
% end

% --- Save the file
M = ML.matfile(fname);
M.save(in.key, in.value, in.desc);