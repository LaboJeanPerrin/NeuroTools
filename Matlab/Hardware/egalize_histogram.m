function out = egalize_histogram(F, img)
out = img;
out = out - F.IP.range(1);
out = out / (F.IP.range(2) - F.IP.range(1)) * 20;
end