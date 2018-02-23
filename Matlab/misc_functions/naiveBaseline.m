function naiveBaseline(signal, fid, i)
%naiveBaseline computes the baseline for the given signal and write it to fid

ssignal = single(signal);
window = 11;
q = single(8/100);
n = length(ssignal);

gap=(window-1)/2; % 5
q_ini=quantile(ssignal(1:window),q);
q_fin=quantile(ssignal(end-gap:end),q);

w = waitbar(0, ['Computing baseline number ' num2str(i)]);

% write beginning
for i = 1:gap
    fwrite(fid,q_ini,'uint16');
end

for i = 1:n-window+1
    waitbar(i/n)
    fwrite(fid,quantile(ssignal(i:i+window-1), q),'uint16');
end

% write end
for i = 1:gap
    fwrite(fid,q_fin,'uint16');
end

close(w)

end