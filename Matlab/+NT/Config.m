function Config(F)
%Routines.Config Configuration routine.
%   ROUTINES.CONFIG(F) creates a config file for RUN at DATE defined in F

% rewrite function Hugo Trentesaux

% === Parameters ==========================================================

ext = 'tif';

confPath = F.tag('Config');

% look for config file and continue only if ther isn't
if exist(confPath, 'file')
    disp('Config file found, loading it...');
    load(confPath, 'config');
    % save config elements to focus
    configToFocus(config, F) %#ok<NODEF>
    
    disp('Config loaded');
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

config.version = struct();

% === Recording code version ==============================================

for proj = {'easyRLS', 'NeuroTools'}
    try
        config.version.(proj{1}) = codeVersion(proj{1});
    catch me
        warning(me.identifier, 'can not find %s code in default directory\n%s', proj{1}, me.message)
    end
end

% === Getting values ======================================================

if ~exist(F.dir('Images'), 'dir')
    warning('config.IP will not be set correctly unless there is an Image directory')
    
    % tries to find at least one image for dcimg parameters
    image = dir(fullfile(F.dir('Images'), '*.tif'));
    if numel(image) % if there is at least one image 
        info = imfinfo(fullfile(image(1).folder, image(1).name));
        config.IP.width = info.Width;
        config.IP.height = info.Height;
        config.IP.bitdepth = info.BitDepth;
        config.IP.date = info.FileModDate;
        config.IP.INFO = 'found by focus config on a sample tif image';
        config.IP.description = info.ImageDescription;
        % parse description
        parsed = parseDescription(info.ImageDescription);
        config.IP.Software = parsed.Software; 
        config.IP.Binning = parsed.Binning;
        fprintf('found width (%d) and height (%d) in %s\n', info.Width, info.Height, image(1).name);
        
        switch config.IP.Software
            case 'Hamamatsu'
                config.dx = 0.4; %µm
                config.dy = 0.4; %µm
        end
        config.dx = config.dx * config.IP.Binning;
        config.dy = config.dy * config.IP.Binning;
    end
    
else
    % --- Prepare images list
    images = dir(fullfile(F.dir('Images'), ['*.' ext]));

    % Get Image Processing parameters
    tmp = regexp(images(1).name, '^(.*_)([0-9]*)\.(.*)', 'tokens');
    config.IP.prefix = tmp{1}{1};
    config.IP.format = ['%0' num2str(numel(tmp{1}{2})) 'i'];
    config.IP.extension = tmp{1}{3};

    tmp = imfinfo(fullfile(F.dir('Images'), images(1).name));

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

    tmp = NT.Image(fullfile(F.dir('Images'), images(round(numel(images)/2)).name));
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
% loads the elements of 'config' to the focus

    % save config elements to focus
    F.units = config.units;
    F.sets = config.sets;
    F.IP = config.IP;
    F.dt = config.dt;
    F.dx = config.dx;
    F.dy = config.dy;
    % TODO other elements (like dx, dy)
    
    %version check
    projs = fieldnames(config.version);
    versions = struct2cell(config.version);
    for i = 1:2
        if ~strcmp(versions{i}, codeVersion(projs{i}))            
            warning('code version for %s do not match\nthere might be some incompatibilities', projs{i});
        end
    end
end

function parsed = parseDescription(descr)
% parse the given description to find hamamatsu parameters

    parsed = struct(...
        'Software', '',...
        'Binning', 1);
    
    if contains(descr, 'Hamamatsu')
        parsed.Software = 'Hamamatsu';
    end
    
    p = strfind(descr, 'Binning = ');
    b = descr(p+10);
    parsed.Binning = str2double(b);

end

function version = codeVersion(proj)
% return the git name of the commit

    focusPath = mfilename('fullpath');
    toErase = 'NeuroTools/Matlab/+NT/Config';
    programPath = erase(focusPath,toErase);
    path = fullfile(programPath, proj);
    cd(path);
    [status, cmdout] = unix('git describe --tags');
    if status; warning('unable to get program version');
    else; version = cmdout(1:end-1); end
    
end
    