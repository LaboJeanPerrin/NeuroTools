function out = equalize_histogram(~, img)
%equalize_histogram is the Hugo's function for rescalegd
% DO NOT USE unless you really want it

min = 400;
max = 700;
% base = F.IP.range(1);
% max = F.IP.range(2);

    if class(img) == 'double'
        out = img;
        out = out - min;
        out = out / (max-min);
    elseif class(img) == 'uint16'
        out = double(img);
        out = out - min;
        out = out / (max-min);
    else
        out = img;
    end
end