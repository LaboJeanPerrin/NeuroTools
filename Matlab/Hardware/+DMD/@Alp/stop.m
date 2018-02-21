function stop(this)
% Stop playing an image sequence

res = calllib(this.dll, 'AlpProjHalt', this.device);