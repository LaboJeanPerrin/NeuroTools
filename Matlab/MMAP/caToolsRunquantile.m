function caToolsRunquantile(F)
%caToolsRunquantile computes running quantile using caTools

    baselinePath = fullfile(F.dir.IP, 'baseline');
    mkdir(baselinePath);
        
    for z = 10:12
        inputMmapInfo = fullfile(F.dir.IP, 'signalStacks', [num2str(z, '%02d') '.mmap.mat']);
        outputMmap = fullfile(baselinePath, [num2str(z, '%02d') '.mmap']);
        outputMmapInfo = fullfile(baselinePath, [num2str(z, '%02d') '.mmap.mat']);

        load(inputMmapInfo, 'mmap', 'T', 'indices');

        fid = fopen(outputMmap, 'wb');

        OUT = NaN(length(T), length(indices));

        tic
        [~, OUT] = calllib('caTools', 'runquantile',...
                mmap.Data.raw(:,:),... input matrix
                OUT,... output variable
                1500,... size column (time)
                100,... window
                0.1,... quantile
                1,... lenght of quantile vector (here only one)
                1 ... type of quantile calculation
                );
        toc

        % write baseline to binary file (cast to double operated by matlab)
        fwrite(fid,...
            OUT,...
            'double');

        fclose(fid);

        % generate and save mmap info
        mmap = memmapfile(outputMmap,...
                    'Format',{'double',[length(T), length(indices)],'raw'});
        save(outputMmapInfo, 'mmap', 'T', 'indices');

    end

end