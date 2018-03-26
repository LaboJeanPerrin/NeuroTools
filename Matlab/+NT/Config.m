function Config(F)
%Routines.Config Configuration routine.
%   ROUTINES.CONFIG(F) creates a config file for RUN at DATE defined in F


% rewrite function Hugo Trentesaux

% === Parameters ==========================================================

% tag = 'Config';
tag = 'Config.mat';
ext = 'tif';

confPath = fullfile(F.dir.files, tag);

% look for config file and continue only if ther isn't
if exist(confPath, 'file')
    disp('Config file found, loading it...');
    load(confPath, 'config');
    % save config elements to focus
    configToFocus(config, F) %#ok<NODEF>
    
    disp('Config.m loaded');
    return
end

disp('No config file found, generating one...');


% === Initialize config ===================================================

config.units = struct('dx', 'um', ...
    'dy', 'um', ...
    'dt', 'ms', ...
    'z', 'um', ...
    't', 'ms', ...
    'exposure', 'ms');

config.exposure = F.param.Exposure;
config.dt = F.param.Delay  + F.param.Exposure ;
% dt is the sum of the delay and the exposure (ignoring delay long)

config.sets = struct();
config.IP = struct();

config.dx = NaN;
config.dy = NaN;

% === Getting values ======================================================

if ~exist(F.dir.images, 'dir')
    warning('config.IP will not be set unless there is an Image directory')
else

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

    tmp = NT.Image(fullfile(F.dir.images, images(round(numel(images)/2)).name));
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
      
end  

% --- Save configuration

% save config elements to focus
configToFocus(config, F)
save(confPath, 'config')
disp('Config file saved.')

end

function configToFocus(config, F)

    % save config elements to focus
    F.units = config.units;
    F.sets = config.sets;
    F.IP = config.IP;
    F.dt = config.dt;

    % TODO other elements (like dx, dy)
end