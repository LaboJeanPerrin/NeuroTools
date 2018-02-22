function driftCompute(F, m, kwargs)
%driftCompute computes the drift on the given layer against the given reference stack max projection
% using the parabolic fft based drift correction
% F is the focus
% m is the Mmap object

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%  Attention : driftCompute contient plusieurs choix
%  - utilisation du max des layers selectionnés
%  - bbox définie dans le programme
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


% parameters
N = length(m.T); % Number of frames per layer

% parse input to change reference stack TODO write validation function
in = inputParser;
in.addParameter('indexOfReferenceStack', 3);
in.addParameter('layersOfReferenceStack', 4:6);
in.addParameter('Layers', [F.sets.id]);
in.parse(kwargs{:})

Layers = in.Results.Layers;
indexOfReferenceStack = in.Results.indexOfReferenceStack;
layersOfReferenceStack = in.Results.layersOfReferenceStack;

% --- Define reference image ---
% the reference image we take is the maximum of the selected layers along
% the 3rd dimension

bbox = [ 53 566 45 914 ]; % define bounding box to look into
X = bbox(1):bbox(2);
Y = bbox(3):bbox(4);

% compute reference image
Ref = NT.Image(max(m(X,Y,layersOfReferenceStack, indexOfReferenceStack),[],3));

% --- Drift correction ---
% creates a figure to plot the drift correction
figure; hold on;
title([F.name '   dx=red, dy=blue']);

dx = zeros(1,N);
dy = zeros(1,N);
for t = m.T % run across the times
    % compute the image to compare with the ref image
    Img = NT.Image(max(m(X,Y,layersOfReferenceStack, t),[],3));
    
    % compute the DX and DY with the fourier transform
    [dx(t), dy(t)] = Ref.fcorr(Img);

    % plot 1/50 images
    if ~mod(t,50)
        plot(t-49:t,dy(t-49:t),'b.');
        plot(t-49:t,dx(t-49:t),'r.');
        pause(0.1) % why ?
    end   
end

% --- Save ---
for i = Layers
      dBoxPath = fullfile(F.dir.IP, num2str(i)); % path of drift box file
      mkdir(dBoxPath);
      save(fullfile(dBoxPath, 'DriftBox'), 'bbox');
      save(fullfile(dBoxPath, 'Drifts'), 'dx', 'dy');
end

savefig(fullfile(F.dir.IP, 'driftCorrection')); 
close gcf

end

