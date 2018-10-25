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
    versionCheck(F, config); % check version
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
if exist([F.tag('dcimg') '.dcimg'], 'file') % if found dcimg (TODO: just detect dcimg)
    disp('found dcimg, working with it');
    config.Source = 'dcimg'; % tells the focus he is working with dcimg
    config.SourceSpace = getSpace(F);
    
    % tries to find at least one image for dcimg parameters
    image = dir(fullfile(F.dir('Images'), '*.tif'));
    if numel(image) % if there is at least one image 
        config = setstructfields(config, imInfoToConfig(image(1))); % get info from image
    else
        warning('config.IP will not be set correctly without images in the Image directory');
        warning('no image found, using default parameters (dx=dy=0.8µm)');
        config.dx = 0.8;
        config.dy = 0.8;
    end
    
    configToFocus(config, F)
    Focused.MmapOnDCIMG(F); % call this to generate mat file if not existing

% --- tif ---
elseif ~isempty(dir(fullfile(F.dir('Images'), '*.tif'))) % if source is tif
    % build F.frames according to images
    loadFramesInFocus(F);
    
    % tells the focus he is working with tif
    config.Source = 'tif';     
    config.SourceSpace = getSpace(F);        
    
    % --- Prepare images list
    images = dir(fullfile(F.dir('Images'), ['*.' ext]));

    % Get Image Processing parameters
    config = setstructfields(config, imInfoToConfig(images(1))); % get info from image
    
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
    warning('no data found in %s', F.dir('Images'));      
end  

% --- Save configuration

% save config elements to focus
configToFocus(config, F)
save(confPath, 'config')
disp('Config file saved.')

end

function origSpace = getSpace(F)
% try to find the space 
    try % TODO improve this (it was done very quickly before Geoffrey's paper)
        fid = fopen(fullfile(F.dir('Run'), 'space'));
        origSpace = fgetl(fid);
        fclose(fid);
        fprintf('detected space : %s\n', origSpace);
    catch
        origSpace = 'ARIT';
        warning('space not found, setting %s as default', origSpace);
    end
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
    
    try % load source if exists
        % TODO separe focus to analyse data / Focus to visualize data
        F.extra.Source = config.Source; % loads the recorded source
    catch
        warning('no source found in config, setting Focus source to default (dcimg). To set it manually change F.extra.source to ''tif'' for instance');
        F.extra.Source = 'dcimg';
    end
    try % load source space if defined
        F.extra.sourceSpace = config.SourceSpace; % loads source space
    catch
        F.extra.sourceSpace = 'ARIT';
        warning('no space found, setting to default (%s)', F.extra.sourceSpace)
    end
end

function configFields = imInfoToConfig(image)
    info = imfinfo(fullfile(image.folder, image.name));
    configFields.IP.width = info.Width;
    configFields.IP.height = info.Height;
    configFields.IP.bitdepth = info.BitDepth;
    configFields.IP.class = ['uint' num2str(info.BitDepth)];
    configFields.IP.date = info.FileModDate;
    configFields.IP.INFO = 'found by focus config on a sample tif image';
    configFields.IP.description = info.ImageDescription;
    % parse description
    parsed = parseDescription(info.ImageDescription);
    configFields.IP.Software = parsed.Software; 
    configFields.IP.Binning = parsed.Binning;
    fprintf('found width (%d) and height (%d) in %s\n', info.Width, info.Height, image(1).name);

    switch configFields.IP.Software
        case 'Hamamatsu'
            configFields.dx = 0.4; %µm
            configFields.dy = 0.4; %µm
        otherwise
            warning('%s camera case not implemented', configFields.IP.Software);
    end
    configFields.dx = configFields.dx * configFields.IP.Binning;
    configFields.dy = configFields.dy * configFields.IP.Binning;
    
    % Get Image Processing parameters
    regexpImg = regexp(image.name, '^(.*_)([0-9]*)\.(.*)', 'tokens');
    configFields.IP.prefix = regexpImg{1}{1};
    configFields.IP.format = ['%0' num2str(numel(regexpImg{1}{2})) 'i'];
    configFields.IP.extension = regexpImg{1}{3};

%     enable for other camera    
% 
%     if ~isfield(info,'Software'), info.Software = 'PCO_ExCv';end
% 
%     switch info.Software
%         case 'PCO_ExCv'
%             config.dx = 0.8;           % Voxel width (um)
%             config.dy = 0.8;           % Voxel height (um)
%             config.IP.camera = 'PCO.Edge';
%         case 'National Instruments IMAQ   '
%             config.dx = 0.66;           % Voxel width (um)
%             config.dy = 0.66;           % Voxel height (um)
%             config.IP.camera = 'Andor_iXon';
%         otherwise
%             config.IP.camera = 'default';
%     end

    
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

function versionCheck(F, config)
%check version
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
       warning(ME.identifier, 'impossible to check code version:\n%s', ME.message);
    end
end

function version = codeVersion(F, proj)
% return the git name of the commit
    cd(F.dir(proj));
    [status, cmdout] = unix('git describe --tags');
    if status; warning('unable to get program version');
    else; version = cmdout(1:end-1); end
end


function loadFramesInFocus(F)
% loads frames in focus
% (previously directly in focus)
    Images = dir(fullfile(F.dir('Images'), '*.tif'));
    if numel(Images) % if not empty

        tmp = regexp(Images(1).name, '([^_]+_)(\d+)(\..*)', 'tokens');
        Img = imfinfo(fullfile(F.dir('Images'), Images(1).name));

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
    