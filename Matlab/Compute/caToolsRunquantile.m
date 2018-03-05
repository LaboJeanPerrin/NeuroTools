function caToolsRunquantile(F, Layers)
%caToolsRunquantile computes running quantile using caTools

    baselinePath = fullfile(F.dir.IP, 'baseline');
    disp('creating ''baseline'' directory'); mkdir(baselinePath);
    
    for z = Layers
        
        m = Mmap(F, 'corrected');
        
        output = fullfile(baselinePath, [num2str(z, '%02d') '.bin']);
        outputInfo = fullfile(baselinePath, [num2str(z, '%02d') '.mat']);

        indices = maskToIndex(F, z);
        numIndex = length(indices);
        
        OUT = NaN(m.t, numIndex);

        tic
        [~, OUT] = calllib('caTools', 'runquantile',...
                squeeze(m(indices, z, :))',... input matrix (t, index)
                OUT,... output variable
                m.t*numIndex,... size of input matrix
                100,... window
                0.1,... quantile
                1,... lenght of quantile vector (here only one)
                1 ... type of quantile calculation
                );
        toc

        fid = fopen(output, 'wb');
        % write baseline to binary file (seems that cast to double is operated by matlab)
        fwrite(fid,...
            OUT,...
            'double');
        fclose(fid);
        
        % get values
        x = m.x;     %#ok<*NASGU>
        y = m.y;   
        % z
        t = m.t;
        Z = z;
        T = m.T;

        % create corresponding mmap info
        mmap = memmapfile(output,...
            'Format',{'double', [t, numIndex],'bit'});
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
