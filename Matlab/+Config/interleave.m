function out = interleave(n)
%Config.interleave Interleaves frames (for triangle step waveforms)

if mod(n,2)
   out = [1:2:n n-1:-2:2];
else
    out = [1:2:n-1 n:-2:2];
end
