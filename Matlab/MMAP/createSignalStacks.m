function createSignalStacks(F, m)
%createSignalStacks creates one signal stack for each layer (double)

    T = m.T; % times
    
    outputPath = fullfile(F.dir.IP, 'signalStacks');
    mkdir(outputPath);

    for z = 13:m.Z(end) % for each layer

        % get indices of interest
        indices = maskToIndex(F, z); 

        % create a mmap file
        outputMmap = fullfile(outputPath, [num2str(z, '%02d') '.mmap']);
        outputMmapInfo = fullfile(outputPath, [num2str(z, '%02d') '.mmap.mat']);
        fid = fopen(outputMmap ,'wb');

        w = waitbar(0, ['Creating signal stack of layer ' num2str(z, '%02d')]);
        
        [X,Y] = ind2sub([F.IP.height F.IP.width], indices); % get the x,y corresponding position
            
        % for each index
        for i = 1:length(indices) 
            fwrite(fid, squeeze(m(X(i),Y(i),z,:)), 'uint16'); % write all values of a pixel along time
            if ~mod(i,1000)
                waitbar(i/length(indices), w,...
                    ['Creating signal stack of layer ' num2str(z, '%02d') ' - ' num2str(i)...
                    ' / ' num2str(length(indices))] )
            end
        end
        
    
        close(w)
        

        fclose(fid);

        % create corresponding mmap info
        mmap = memmapfile(outputMmap,...
            'Format',{'uint16',[length(T), length(indices)],'raw'}); %#ok<NASGU>
        save(outputMmapInfo, 'mmap', 'T', 'indices');
    end

end