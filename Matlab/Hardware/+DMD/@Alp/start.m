function start(this)
% Start playing an image sequence

fprintf('\n* Playing sequence\t\t\t\t\t\t');

res = calllib(this.dll, 'AlpProjStartCont', this.device, this.sequenceId);
tic

this.dispResult(res);