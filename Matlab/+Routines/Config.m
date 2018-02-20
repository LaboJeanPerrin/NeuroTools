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
    disp('config file found, loading it');
    load(confPath, 'config');
    % save config elements to focus
    configTowardsFocus(config, F) %#ok<NODEF>
    
    disp('Config.m loaded');
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





% --- Save configuration
% TODO à remettre en forme

% save config elements to focus
configTowardsFocus(config, F)

save(confPath, 'config')

disp('config file saved')

end

% Conf.save('dx', config.dx, ['Pixel x-size (' config.units.dx ')']);
% Conf.save('dy' ,config.dy, ['Pixel y-size (' config.units.dy ')']);
% Conf.save('dt', config.dt, ['Inverse of the acquisition frequency (' config.units.dt ')']);
% Conf.save('exposure', config.exposure, ['Exposure time (' config.units.exposure ')']);
% Conf.save('sets', config.sets, 'Sets (layers and/or scans)');
% Conf.save('IP', config.IP, 'Image processing parameters');
% Conf.save('units', config.units, 'Summary of the units used in this configuration file');

function configTowardsFocus(config, F)

    % save config elements to focus
    F.units = config.units;
    F.sets = config.sets;
    F.IP = config.IP;
%         dx
%         dy
%         dt
%         exposure
end