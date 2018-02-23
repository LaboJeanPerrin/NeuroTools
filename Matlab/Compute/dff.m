function dff(F, Layers, background)
%dff computes dff for current brain

dffPath = fullfile(F.dir.IP, 'dff');
disp('creating ''baseline'' directory'); mkdir(dffPath);

    for z = Layers
               
        msig = Mmap2D(F, 'signalStacks', z);
        mbas = Mmap2D(F, 'baseline', z);
        m = msig;
                
        output = fullfile(dffPath, [num2str(z, '%02d') '.bin']);
        outputInfo = fullfile(dffPath, [num2str(z, '%02d') '.mat']);
        
        fid = fopen(output, 'wb');
        
        % compute dff
        fwrite(fid,...
            (double(msig(:,:))-mbas(:,:) ./ (mbas(:,:) - background)),...
            'double');

        fclose(fid);
        
        % get values
        x = m.x;    %#ok<NASGU>
        y = m.y;    %#ok<NASGU>
        z = z;      %#ok<FXSET,ASGSL>
        t = m.t;
        Z = z;      %#ok<NASGU>
        T = m.T;    %#ok<NASGU>
        indices = m.indices; %#ok<NASGU>
        numIndex = m.numIndex;

        % create corresponding mmap info
        mmap = memmapfile(output,...
            'Format',{'double',[t, numIndex],'bit'}); %#ok<NASGU>
        save(outputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');

    end
end