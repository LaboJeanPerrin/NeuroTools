function stop(this, varargin)
% Stop playing an image sequence

fprintf('* Stopping sequence\t\t\t\t\t\t');

res = calllib(this.dll, 'AlpProjHalt', this.device);

switch res
    case 0, fprintf('[\bOK]\b (exposed %.03f sec)\n', toc);
    otherwise, fprintf(2, '<strong>Failure (%i)</strong>\n', res);
end