function Out = prepare(this, k)

Out = zeros(this.dispHeight, this.dispWidth, 3);

for i = 1:numel(this.stack)
    tmp = this.stack(i).data(1:this.zoom:end, 1:this.zoom:end, k);
    for c = 1:3
        Out(:,:,c) = Out(:,:,c) + (double(tmp)-this.stack(i).range(1))/(this.stack(i).range(2)-this.stack(i).range(1))*255*this.stack(i).color(c);
    end
end

Out = uint8(Out);
