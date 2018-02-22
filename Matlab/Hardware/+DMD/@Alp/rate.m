function rate(this, f)
% Specifies the sequence display rate

fprintf('Setting the display rate\t\t\t\t');

res = calllib(this.dll, 'AlpSeqTiming', this.device, this.sequenceId, ...
    0, uint32(1e6/f), 0, 0, 0);

this.dispResult(res);