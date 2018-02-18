function Out = prepareVisu(this)

Out = zeros(this.visuHeight, this.visuWidth, 3);

for i = 1:numel(this.stacks)
    
    switch (this.stacks(i).mode)

        case 'xy'
       
            % Prepare visualization
            tmp = this.stacks(i).data(1:this.zoom:end, 1:this.zoom:end);
            for c = 1:3
                Out(:,:,c) = Out(:,:,c) + (double(tmp)-this.stacks(i).range(1))/(this.stacks(i).range(2)-this.stacks(i).range(1))*255*this.stacks(i).color(c);
            end
        
        case 'xyt'
        
            % Get frame number
            k = round(get(this.slider, 'Value'));
       
            % Prepare visualization
            tmp = this.stacks(i).data(1:this.zoom:end, 1:this.zoom:end, k);
            for c = 1:3
                Out(:,:,c) = Out(:,:,c) + (double(tmp)-this.stacks(i).range(1))/(this.stacks(i).range(2)-this.stacks(i).range(1))*255*this.stacks(i).color(c);
            end
        
        case 'xyz'
        
            % Prepare visualization
            tmp = this.stacks(i).data(1:this.zoom:end, 1:this.zoom:end, k);
            for c = 1:3
                Out(:,:,c) = Out(:,:,c) + (double(tmp)-this.stacks(i).range(1))/(this.stacks(i).range(2)-this.stacks(i).range(1))*255*this.stacks(i).color(c);
            end
        
            
    end
end

Out = uint8(Out);
