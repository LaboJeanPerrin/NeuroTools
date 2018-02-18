function out = FileName(this,varargin)
%[Focus].FileName filename corresponding to a tag
%   OUT = FileName(TAG) returns the filename corresponding to the tag TAG. 
%   TAG should be a string, optionnaly comprising file separators to define
%   subfolders.
%
%   Note: If TAG contains an '@', it is automatically converted to the 
%   current set number followed by a file separator.
%
%   FileName(..., 'ext', EXT) specifies the extension of the matfile. The
%   default value is '.mat'.
%
%   See also: Focus, Focus.FileSave, Focus.FileLoad.

% --- Inputs --------------------------------------------------------------

in = ML.Input;
in.tag = @ischar;
in.ext('mat') = @ischar;
in = +in;

% -------------------------------------------------------------------------

% --- Run shortcut
if strfind(in.tag, '@')
    if isa(this.set, 'struct')
        in.tag = strrep(in.tag, '@', [num2str(this.set.id) filesep]);
    else
        warning('Focus:fname:NoSetDefined', 'No set is defined in the focus object, but a ''@'' sign has been detected in a tag name. The shortcut hasn''t been applied.');
    end
end 

% --- Output
out = [this.dir.files in.tag '.' in.ext];