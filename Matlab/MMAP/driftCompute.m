function driftCompute(F, mmap, kwargs)
%driftCompute computes the drift on the given layer against the given reference stack
% using the parabolic fft based drift correction

in = inputParser;
in.addParameter('indexOfReferenceStack', 3);
in.addParameter('layersOfReferenceStack', 4:6);
in.addParameter('Layers', [F.sets.id]);
in.parse(kwargs{:})

ref 

% build reference image



end