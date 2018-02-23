function naiveBaseline(signal, fid)
%naiveBaseline computes the baseline for the given signal and write it to fid

window = 11;
q = 8;
n = length(signal);

gap=(window-1)/2; % 5
q_ini=quantile(signal(1:window),q);
q_fin=quantile(signal(end-gap:end),q);

w = waitbar(0, 'Computing baseline');

% write beginning
for i = 1:gap
    fwrite(fid,q_ini,'uint16');
end

for i = 1:n-window+1
    waitbar(i/n)
    fwrite(fid,quantile(signal(i:i+window-1), q),'uint16');
end

% write end
for i = 1:gap
    fwrite(fid,q_fin,'uint16');
end

close(w)

end