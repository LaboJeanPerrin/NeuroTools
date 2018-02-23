function createSignalStacks(F, Layers)
%createSignalStacks creates one signal stack for each layer (double)

    m = Mmap(F, 'corrected');
    
    outputPath = fullfile(F.dir.IP, 'signalStacks');
    disp('making ''signalStacks'' directory'); mkdir(outputPath);

    for z = Layers % for each layer

        % get indices of interest
        indices = maskToIndex(F, z);
        numIndex = length(indices); % number of index

        % create a mmap file
        output = fullfile(outputPath, [num2str(z, '%02d') '.bin']);
        outputInfo = fullfile(outputPath, [num2str(z, '%02d') '.mat']);
        fid = fopen(output ,'wb');

        w = waitbar(0, ['Creating signal stack of layer ' num2str(z, '%02d')]);
        
        [X,Y] = ind2sub([m.x m.y], indices); % get the X,Y corresponding positions
            
        % for each index
        for i = 1:numIndex
            % write all values of a pixel along time
            fwrite(fid, squeeze(m(X(i),Y(i),z,:)), 'uint16');
            if ~mod(i,999) % one over 999 times, actualize waitbar
                waitbar(i/length(indices), w,...
                    ['Creating signal stack of layer ' num2str(z, '%02d') ' - '... 
                    num2str(i) ' / ' num2str(length(indices))] )
            end
        end

        close(w)
        
        fclose(fid);
        
        % get values
        x = m.x;    %#ok<NASGU>
        y = m.y;    %#ok<NASGU>
        z = z;      %#ok<FXSET,ASGSL>
        t = m.t;
        Z = z;      %#ok<NASGU>
        T = m.T;    %#ok<NASGU>

        % create corresponding mmap info
        mmap = memmapfile(output,...
            'Format',{'uint16',[t, numIndex],'bit'}); %#ok<NASGU>
        save(outputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
    end
end