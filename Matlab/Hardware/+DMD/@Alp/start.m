function start(this)
% Start playing an image sequence

res = calllib(this.dll, 'AlpProjStartCont', this.device, this.sequenceId);