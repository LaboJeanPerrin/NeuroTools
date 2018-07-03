function define()
%[Focus].current Define the current focus object            [Static method]
%   F = [Focus].define launchs a command-line interface to select the
%   current Focus. At the end of the process the selected Focus is defined
%   as the current Focus.
%
%   See also: Focus, Focus.current

% --- Preparation
proj = ML.Projects.select;
Studies = ML.dir([proj.path 'Data']);

for i = 1:numel(Studies)
    
    Dates = ML.dir([proj.path 'Data' filesep Studies(i).name]);
    T = cell(numel(Dates),1);
    
    % --- Display
    
    ML.CW.line(['Available runs in ~bc[teal]{' Studies(i).name '}']);
    
    for j = 1:numel(Dates)
        
        Runs = ML.dir([proj.path 'Data' filesep Studies(i).name filesep Dates(j).name]);
        
        for k = 1:numel(Runs)
            
            T{j, k} = ['<a href="matlab:Focus(''' Studies(i).name ''', ''' Dates(j).name ''', ''' Runs(k).name ''', ''verbose'', true);">' Runs(k).name '</a>'];
            
        end
        
    end
    
    ML.Text.table(T, 'row', {Dates(:).name},  'style', 'compact', 'border', 'none');
    
end
