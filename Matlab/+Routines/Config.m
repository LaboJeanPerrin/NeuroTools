function out = Config(F)
%Routines.Config Configuration routine.
%   ROUTINES.CONFIG(F) creates a config file for RUN at DATE defined in F


% rewrite function Hugo Trentesaux

% === Parameters ==========================================================

tag = 'Config';
ext = 'tif';

confPath = [F.dir.files filesep tag];

% look for config file and continue only if ther isn't
if exist(confPath, 'dir')
    return
end

disp('No config file found, generating one');



% === Initialize config ===================================================

config.units = struct('dx', 'um', ...
    'dy', 'um', ...
    'dt', 'ms', ...
    'z', 'um', ...
    't', 'ms', ...
    'exposure', 'ms');

config.exposure = F.param.Exposure;
config.dt = F.param.Delay; % TODO verify

config.dx = NaN;
config.dy = NaN;

% === Getting values ======================================================

% --- Prepare images list
images = dir(fullfile(F.dir.images, ['*.' ext]));

% Get Image Processing parameters
tmp = regexp(images(1).name, '^(.*_)([0-9]*)\.(.*)', 'tokens');
config.IP.prefix = tmp{1}{1};
config.IP.format = ['%0' num2str(numel(tmp{1}{2})) 'i'];
config.IP.extension = tmp{1}{3};

tmp = imfinfo(fullfile(F.dir.images, images(1).name));

config.IP.date = tmp.FileModDate;
config.IP.width = tmp.Width;
config.IP.height = tmp.Height;
config.IP.bitdepth = tmp.BitDepth;
config.IP.class = ['uint' num2str(tmp.BitDepth)];
if ~isfield(tmp,'Software'), tmp.Software = 'PCO_ExCv';end

switch tmp.Software
    case 'PCO_ExCv'
        config.dx = 0.8;           % Voxel width (um)
        config.dy = 0.8;           % Voxel height (um)
        config.IP.camera = 'PCO.Edge';
    case 'National Instruments IMAQ   '
        config.dx = 0.66;           % Voxel width (um)
        config.dy = 0.66;           % Voxel height (um)
        config.IP.camera = 'Andor_iXon';
    otherwise
        config.IP.camera = 'default';
end
tmp = Image([F.Images images(round(numel(images)/2)).name]); %% TODO F.dir.images ....
config.IP.range = tmp.autorange;

% Define sets
config.sets = struct('id', {}, 'type', {}, 'frames', {}, 't', {}, 'z', {});

  % Get existing frames
frames = cellfun(@(x) str2double(x{1}), cellfun(@(x) regexp(x,...
    ['^' config.IP.prefix '([0-9]*)'], 'tokens'), {images(:).name}));
          
% --- automatic layers, linear

% Number of layers
    nL = F.param.NLayers;

% Altitudes TODO verify
    dz = F.param.Increment;

for i = 1:nL

    id = numel(config.sets)+1;
    config.sets(id).id = id;

    % Type
    config.sets(id).type = 'Layer';

    % Index
    config.sets(id).frames = frames(i:nL:end);

    % Times
    config.sets(id).t = config.sets(id).frames*config.dt;

    % Altitudes
    config.sets(id).z = dz*(i-1);

end





% --- Save configuration TODO à remettre en forme

save(confPath, conf)
% Conf.save('dx', config.dx, ['Pixel x-size (' config.units.dx ')']);
% Conf.save('dy' ,config.dy, ['Pixel y-size (' config.units.dy ')']);
% Conf.save('dt', config.dt, ['Inverse of the acquisition frequency (' config.units.dt ')']);
% Conf.save('exposure', config.exposure, ['Exposure time (' config.units.exposure ')']);
% Conf.save('sets', config.sets, 'Sets (layers and/or scans)');
% Conf.save('IP', config.IP, 'Image processing parameters');
% Conf.save('units', config.units, 'Summary of the units used in this configuration file');


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


% % --- Preparation
% line = @(x) fprintf('%s\n', ML.CW.line(x));
% quit = false;
% 
% % --- The main loop
% while ~quit
%     
%     % --- Get Focus object
%     if ~isempty(in.date)
%         F = getFocus(p_date, p_run);
%     else
%         tmp = ML.WS.get_by_class('Focus');
%         if ~isempty(tmp)
%             F = evalin('base', tmp{1});
%         else
%             F = getFocus;
%         end
%     end
%     
%     % --- Display
%     clc
%     line('Configuration');
%     
%     % --- Actions
%     firstIteration = 0;
%     while true
%         
%         Conf = F.matfile(tag);
%         
%         % --- Display
%         clc
%         line(['Config ' F.date ' (' num2str(F.run, '%02i') ')']);
%         fprintf('The ''%s.mat'' file ', Conf.name);
%         if Conf.exist
%             ML.cprintf([0 0.8 0], 'exists');
%         else
%             ML.cprintf('red', 'does not exist');
%         end
%         fprintf('.\n');
%         
%         % --- Prepare images list
%         images = dir([F.Images '*.' ext]);
%         
%         % --- Prepare config structure
%         if ~exist('config', 'var')
%             if Conf.exist
%                 
%                 % Load config
%                 config = Conf.load;
%                 
%             else
% 
%                 % Autoload from Parameters.txt file
%                 fparam = [F.Data 'Parameters.txt'];
%                 if exist(fparam, 'file')
%                     
%                     % Display
%                     fprintf('A ''Parameters.txt'' file has been found ...');
%                     
%                     % Parse parameters file
%                     tmp = ML.readtext(fparam);
%                     param = cell(numel(tmp),2);
%                     for i = 1:numel(tmp)
%                         
%                         tok = regexp(tmp{i}, '([^\t]*)\t(.*)', 'tokens');
%                         if isempty(tok), continue; end
%                         tok = tok{1};
%                         param{i,1} = tok{1};
%                         switch(tok{1})
%                             
%                             case 'Stimulation'
%                                 jnk = textscan(tok{2}, '%f');
%                                 param{i,2} = jnk{:}';
%                                 
%                             otherwise
%                                 jnk = textscan(tok{2}, '%f %s');
%                                 param{i,2} = struct('value', jnk{1}, 'unit', '');
%                                 if numel(jnk)==2
%                                     if ~isempty(jnk{2})
%                                         param{i,2}.unit = jnk{2}{:};
%                                     end
%                                 end
%                         end
%                     end
%                     
%                     fprintf(' and loaded.\n');
%                     
%                     % Remove empty elements
%                     param(cellfun(@isempty, param(:,1)),:) = [];
%                     
%                     % Check consistency
%                     [tf, i] = ismember('Number of frames', param(:,1));
%                     if tf && numel(images)<param{i,2}.value
%                         ML.cprintf([1 0.5 0], ['\nWARNING: Inconsistent number of images: ' ...
%                             num2str(param{i,2}.value) ' expected, ' num2str(numel(images)) ' found.\n']);
%                     end
%                     
%                     
%                     
%                 end
%                 
%             end
%         end
%         
%       
%         
%         % --- Select action
%         
%         fprintf('\nPlease choose an action:\n');
%         
%         fprintf('\n--- General\n');
%         fprintf('\t[x] - Change dx = %f %s\n', config.dx, config.units.dx);
%         fprintf('\t[y] - Change dy = %f %s\n', config.dy, config.units.dy);
%         fprintf('\t[t] - Change dt = %f %s\n', config.dt, config.units.dt);
%         fprintf('\t[e] - Change exposure = %f %s\n', config.exposure, config.units.exposure);
%         fprintf('\t[p] - Change prefix = %s\n', config.IP.prefix);
%         fprintf('\t[f] - Change format = %s\n', config.IP.format);
%         fprintf('\t[.] - Change extension = %s\n', config.IP.extension);
%         fprintf('\t[r] - Change range = %s\n', mat2str(config.IP.range));
%         
%         fprintf('\n--- Sets\n');
%         
%         % Existing sets
%         I = frames;
%         if numel(config.sets)
%             for i = 1:numel(config.sets)
%                 fprintf('\t[%i] - %s (%i frames)\n', i, config.sets(i).type, numel(config.sets(i).frames));
%                 I = setdiff(I, config.sets(i).frames);
%             end
%             fprintf('\n');
%         end
%         
%            
%         
%         % Remaining frames
%         fprintf('\tRemaining frames: %i (on %i)\n', numel(I), numel(frames));
%         
%         if numel(I)
%             fprintf('\t[n] - New set\n');
%             fprintf('\t[l] - Automatic 3D, linear mode\n');
%             fprintf('\t[i] - Automatic 3D, interleaved mode\n');
%         end
%         if numel(config.sets)
%             fprintf('\t[d] - Delete set\n');
%         end
%         
%         fprintf('\n--- Save & quit\n');
%         fprintf('\n\t[s] - Save the parameters in the ''%s.mat'' file and quit.\n', tag);
%         fprintf('\t[q] - Quit\n');
%         
%         if firstIteration == 0
%             a = 'l';
%         else
%             a = input('?> ', 's');
%         end
%         
%         switch a
%             
%             % --- Change dx
%             case 'x'
%                 line('');
%                 fprintf('Please enter the new value for dx (%s):\n', config.units.dx);
%                 config.dx = input('?> ');
%                 
%                 % --- Change dy
%             case 'y'
%                 line('');
%                 fprintf('Please enter the new value for dy (%s):\n', config.units.dy);
%                 config.dy = input('?> ');
%                 
%                 % --- Change dt
%             case 't'
%                 line('');
%                 fprintf('Please enter the new value for dt (%s):\n', config.units.dt);
%                 config.dt = input('?> ');
%                 
%                 % --- Change exposure
%             case 'e'
%                 line('');
%                 fprintf('Please enter the new value for the exposure time (%s):\n', config.units.exposure);
%                 config.exposure = input('?> ');
%                 
%                 % --- Change prefix
%             case 'p'
%                 line('');
%                 fprintf('Please enter the prefix:\n');
%                 config.IP.prefix = input('?> ', 's');
%                 
%                 % --- Change format
%             case 'f'
%                 line('');
%                 fprintf('Please enter the new format:\n');
%                 config.IP.format = input('?> ', 's');
%                 
%                 % --- Change extension
%             case '.'
%                 line('');
%                 fprintf('Please enter the new extension:\n');
%                 config.IP.extension = input('?> ', 's');
%                 
%                 % --- Change range
%             case 'r'
%                 line('');
%                 fprintf('Please enter the new range:\n');
%                 config.IP.range = input('?> ');
%                 
%                 % --- New set
%             case 'n'
%                 
%                 line('New set');
%                 id = numel(config.sets)+1;
%                 config.sets(id).id = id;
%                 
%                 % Type
%                 config.sets(id).type = choose_type();
%                 
%                 % Index
%                 fprintf('Please enter the corresponding frame numbers (from %i to %i) [Enter for all]:\n', min(frames), max(frames));
%                 tmp = input('?> ');
%                 if isempty(tmp)
%                     config.sets(id).frames = frames;
%                 else
%                     config.sets(id).frames = tmp;
%                 end
%                 
%                 % Times
%                 switch config.IP.camera 
%                     case 'Andor_iXon'
%                         config.sets(id).t = load([F.Images 'Times.txt']);
%                     otherwise
%                         config.sets(id).t = config.sets(id).frames*config.dt;
%                 end
%                 
%                 % Altitudes
%                 switch config.sets(id).type
%                     
%                     case 'Layer'
%                         
%                         fprintf('Please enter the layer altitude (%s) [Press enter for zero]:\n', config.units.z);
%                         tmp = input('?> ');
%                         if isempty(tmp)
%                             config.sets(id).z = 0;
%                         else
%                             config.sets(id).z = tmp;
%                         end
%                         
%                     case 'Scan'
%                         fprintf('Please enter the corresponding altitudes (%s):\n', config.units.z);
%                         config.sets(id).z = input('?> ');
%                 end
%                 
%                 % --- Delete set
%             case 'd'
%                 line('');
%                 fprintf('Please enter the index of the set to delete:\n');
%                 config.sets(input('?> ')) = [];
%                 
%                 % --- Automatic layers, linear
%             case 'l'
%                 
%                 if firstIteration == 0
%                     % dz
%                     [tf, i] = ismember('Z increment', param(:,1));
%                     if tf
%                         dz = param{i,2}.value;
%                         if strcmp(param{i,2}.unit, 'm')
%                             dz = dz*1000000;
%                         end
%                     else
%                         dz = 0;  % Volker 2017-05-22
%                     end
%                     % number of layers
%                     [tf, i] = ismember('Number of layers', param(:,1));
%                     if tf
%                         nL = param{i,2}.value;
%                     end
%                    
%                 else
%                    
%                
%                     % Number of layers
%                     fprintf('Please enter the number of layers:\n');
%                     nL = input('?> ');
% 
%                     % Altitudes
%                     fprintf('Please enter the altitude increment (%s):\n', config.units.z);
%                     dz = input('?> ');
%                 end
%                 
%                 for i = 1:nL
%                     
%                     id = numel(config.sets)+1;
%                     config.sets(id).id = id;
%                     
%                     % Type
%                     config.sets(id).type = 'Layer';
%                     
%                     % Index
%                     config.sets(id).frames = frames(i:nL:end);
%                     
%                     % Times
%                     config.sets(id).t = config.sets(id).frames*config.dt;
%                     
%                     % Altitudes
%                     config.sets(id).z = dz*(i-1);
%                     
%                 end
%                 
%                 
%                 % --- Automatic layers, interleaved
%             case 'i'
%                 
%                 % Number of layers
%                 fprintf('Please enter the number of layers:\n');
%                 nL = input('?> ');
%                 
%                 % Altitudes
%                 fprintf('Please enter the altitude increment (%s):\n', config.units.z);
%                 dz = input('?> ');
%                 
%                 tmp = sortrows([[1:2:nL fliplr(2:2:nL)]' (1:nL)']);
%                 I = tmp(:,2);
%                 
%                 for i = 1:nL
%                     
%                     id = numel(config.sets)+1;
%                     config.sets(id).id = id;
%                     
%                     % Type
%                     config.sets(id).type = 'Layer';
%                     
%                     % Index
%                     config.sets(id).frames = frames(I(i):nL:end);
%                     
%                     % Times
%                     config.sets(id).t = config.sets(id).frames*config.dt;
%                     
%                     % Altitudes
%                     config.sets(id).z = dz*(i-1);
%                     
%                 end
%                 
%                 % --- Save parameters
%             case 's'
%                 Conf.save('dx', config.dx, ['Pixel x-size (' config.units.dx ')']);
%                 Conf.save('dy' ,config.dy, ['Pixel y-size (' config.units.dy ')']);
%                 Conf.save('dt', config.dt, ['Inverse of the acquisition frequency (' config.units.dt ')']);
%                 Conf.save('exposure', config.exposure, ['Exposure time (' config.units.exposure ')']);
%                 Conf.save('sets', config.sets, 'Sets (layers and/or scans)');
%                 Conf.save('IP', config.IP, 'Image processing parameters');
%                 Conf.save('units', config.units, 'Summary of the units used in this configuration file');
%                 
%                 quit = true;
%                 break;
%                 
%             case 'q'
%                 quit = true;
%                 break;
%                 
%             otherwise
%                 
%                 % Check that the input is a number
%                 if ~numel(a) || ~all(isstrprop(a, 'digit')), continue; end
%                 
%                 line(['Modifying set ' a]);
%                 n = str2num(a);
%                 
%                 while true
%                     
%                     fprintf('Please choose an action:\n');
%                     
%                     fprintf('\t[t] - Change type (''%s'')\n', config.sets(n).type);
%                     fprintf('\t[i] - Change frames (%i elements)\n', numel(config.sets(n).frames));
%                     fprintf('\t[z] - Change altitudes (%i elements)\n', numel(config.sets(n).z));
%                     
%                     fprintf('\t[Enter] - Return\n');
%                     a = input('?> ', 's');
%                     
%                     switch a
%                         
%                         % Type
%                         case 't'
%                             line('');
%                             config.sets(n).type = choose_type();
%                             
%                             % Frames
%                         case 'i'
%                             line('');
%                             fprintf('Please enter the frame numbers:\n');
%                             config.sets(n).frames = input('?> ');
%                             
%                             % Altitudes
%                         case 'z'
%                             line('')
%                             fprintf('Please enter the altitudes (µm):\n');
%                             config.sets(n).z = input('?> ');
%                             
%                         otherwise
%                             break
%                             
%                     end
%                     
%                 end
%                 
%         end
%         firstIteration =1;
%     end
% end
% 
% fprintf('%s\n', ML.CW.line('End of configuration'));
% 
% % --- Output
% out = 'Done';
% 
% % -------------------------------------------------------------------------
% function out = choose_type()
% 
% while true
%     fprintf('Please choose a set type:\n');
%     fprintf('\t[l] Layer\n');
%     fprintf('\t[s] Scan\n');
%     switch lower(input('?> ', 's'))
%         case 'l', out = 'Layer';
%         case 's', out = 'Scan';
%         otherwise, continue
%     end
%     break;
% end
