function F = current()
%[Focus].current Current focus object                       [Static method]
%   F = [Focus].current returns the lastly created Focus object. If the 
%   last Focus object has been deleted or if no Focus object has been 
%   created yet, the Focus finding command-line interface is launched.
%
%   See also: Focus, Focus.define

gname = 'NeuroTools';

% Check group and variable existence
UD = get(groot, 'Userdata');
if ~isstruct(UD) || ~isfield(UD, gname)
    
    F = NaN;
    
else
    
    F = ML.Session.get(gname, 'Focus');
    
    if ~F.isvalid, F = NaN; end
    
end

if ~strcmp(class(F), 'Focus')
    
    ML.CW.print(['~bc[orange]{WARNING !} No current Focus has been found.\n' ...
        'You may want to <a href="matlab:Focus.define">define a focus</a>.\n']);
    
end