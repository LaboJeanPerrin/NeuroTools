function out = egalize_histogram(F, img)
    if class(img) == 'double'
        out = img;
        out = out - F.IP.range(1);
        out = out / (F.IP.range(2) - F.IP.range(1)) * 20;
    elseif class(img) == 'uint16'
        out = double(img);
        out = out - F.IP.range(1);
        out = out / (F.IP.range(2) - F.IP.range(1)) * 20;
    else
        out = img;
    end
end