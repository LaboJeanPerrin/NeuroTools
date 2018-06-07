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
        config.version.(proj{1}) = codeVersion(F,proj{1});
    catch me
        warning(me.identifier, 'can not find %s code in default directory\n%s', proj{1}, me.message)
    end
end

% === Getting values ======================================================

% --- dcimg ---
if exist([F.tag('dcimg') '.dcimg'], 'file') % if found dcimg
    disp('found dcimg, working with it');
    F.extra.Source = 'dcimg'; % tells the focus he is working with dcimg
    Focused.MmapOnDCIMG(F); % call this to generate mat file if not existing
    warning('config.IP will not be set correctly without images in the Image directory');
    
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
            otherwise
                warning('%s camera case not implemented', config.IP.Software);
        end
        config.dx = config.dx * config.IP.Binning;
        config.dy = config.dy * config.IP.Binning;
    else
        warning('no image found, using default parameters (dx=dy=0.8µm)');
        config.dx = 0.8;
        config.dy = 0.8;
    end

% --- tif ---
elseif ~isempty(dir(fullfile(F.dir('Images'), '*.tif'))) % if tif exist
    % build F.frames according to images
    loadFramesInFocus(F);
    
    % tells the focus he is working with tif
    F.extra.Source = 'tif'; 
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
    
else
    error('no data found in %s', F.dir('Images'));      
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
    
    %version check
    projs = fieldnames(config.version);
    versions = struct2cell(config.version);
    try
        for i = 1:2
            if ~strcmp(versions{i}, codeVersion(F,projs{i}))            
                warning('code version for %s do not match\nconfig: %s, current: %s',...
                    projs{i}, versions{i}, codeVersion(F,projs{i}));
            else
                fprintf('version check --- %s : OK\n', projs{i} );
            end
        end
    catch ME
       disp(ME);
       warning('impossible to check code version on windows or no tag found');
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

function version = codeVersion(F,proj)
% return the git name of the commit

    cd(F.dir(proj));
    [status, cmdout] = unix('git describe --tags');
    if status; warning('unable to get program version');
    else; version = cmdout(1:end-1); end
    
end


function loadFramesInFocus(F)
% loads frames in focus
% (previously directly in focus)
    Images = dir([F.dir('Images') '*.tif']);
    if numel(Images) % if not empty

        tmp = regexp(Images(1).name, '([^_]+_)(\d+)(\..*)', 'tokens');
        Img = imfinfo([F.dir('Images') Images(1).name]);

        F.frames = struct();
        F.frames.Number = numel(Images);
        F.frames.Prefix = tmp{1}{1};
        F.frames.Format = ['%0' num2str(numel(tmp{1}{2})) 'i'];
        F.frames.Extension = tmp{1}{3};
        F.frames.Width = Img.Width;
        F.frames.Height = Img.Height;
        F.frames.BitDepth = Img.BitDepth;
    else
        warning('Focus.frames will not be set without images in Images directory');
    end

end
    