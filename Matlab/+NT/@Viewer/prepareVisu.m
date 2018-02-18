function Out = prepareVisu(this)

Out = zeros(this.visuHeight, this.visuWidth, 3);

for i = 1:numel(this.stacks)
    
    switch (this.stacks(i).mode)

        case 'xy'
       
            % Prepare visualization
            tmp = rescaleHist(this.stacks(i).data(1:this.zoom:end, 1:this.zoom:end));
            for c = 1:3
                Out(:,:,c) = Out(:,:,c) + tmp*this.stacks(i).color(c);
            end
        
        case 'xyt'
        
            % Get frame number
            k = round(get(this.slider, 'Value'));
       
            % Prepare visualization
            tmp = rescaleHist(this.stacks(i).data(1:this.zoom:end, 1:this.zoom:end, k));
            for c = 1:3
                Out(:,:,c) = Out(:,:,c) + tmp*this.stacks(i).color(c);
            end
        
        case 'xyz'
        
            % Planes
            YZ = rescaleHist(this.stacks(i).data(1:this.zoom:end, this.x, 1:this.zoom:end))';
            XZ = rescaleHist(this.stacks(i).data(this.y, 1:this.zoom:end, 1:this.zoom:end))';
            XY = rescaleHist(this.stacks(i).data(1:this.zoom:end, 1:this.zoom:end, this.z));
            [this.visuHeight, this.visuWidth]
            S = [size(XY) size(XZ,1)]
            
            for c = 1:3
                
                % XY
                I = 1:S(1);
                J = S(1)+(1:S(2));                
                Out(I,J,c) = Out(I,J,c) + XY*this.stacks(i).color(c);
                
                % XZ
                I = S(1)+(1:S(3));
                J = S(1)+(1:S(2));
                Out(I,J,c) = Out(I,J,c) + XZ*this.stacks(i).color(c);
                
                % YZ
                I = S(1)+(1:S(3));
                J = 1:S(1);
                Out(I,J,c) = Out(I,J,c) + YZ*this.stacks(i).color(c);
                
            end
        
            
    end
end

Out = uint8(Out);

    % -------------------------------------------------------------------------

    function out = rescaleHist(in)

    out = (double(squeeze(in))-this.stacks(i).range(1))/(this.stacks(i).range(2)-this.stacks(i).range(1))*255;
    
    end
end