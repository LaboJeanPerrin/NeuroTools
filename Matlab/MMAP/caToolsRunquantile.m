function caToolsRunquantile(F, Layers)
%caToolsRunquantile computes running quantile using caTools

    baselinePath = fullfile(F.dir.IP, 'baseline');
    disp('creating ''baseline'' directory'); mkdir(baselinePath);
    
    for z = Layers
        
        m = Mmap2D(F, 'signalStacks', z);
        
        output = fullfile(baselinePath, [num2str(z, '%02d') '.bin']);
        outputInfo = fullfile(baselinePath, [num2str(z, '%02d') '.mat']);

        fid = fopen(output, 'wb');

        OUT = NaN(m.t, m.numIndex);

        tic
        [~, OUT] = calllib('caTools', 'runquantile',...
                m(:,:),... input matrix
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

% MORE

% libfunctions('caTools') 	% to know available functions
% libfunctions caTools -full 	% to learn more about these functions
% ... function signature
% [doublePtr, doublePtr, int32Ptr, int32Ptr, doublePtr, int32Ptr, int32Ptr]
% runquantile(doublePtr, doublePtr, int32Ptr, int32Ptr, doublePtr, int32Ptr, int32Ptr)
% ... function syntax
% OUT = calllib('caTools', 'runquantile', IN, OUT, 1500, 100, 0.1, 1, 1);
