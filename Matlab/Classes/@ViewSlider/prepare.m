function Out = prepare(this, k)

Out = uint8(zeros(this.dispHeight, this.dispWidth, 3));

for i = 1:numel(this.stack)
    tmp = this.stack(i).data(1:this.zoom:end, 1:this.zoom:end, k);
    tmp = uint8((double(tmp)-this.stack(i).range(1))/(this.stack(i).range(2)-this.stack(i).range(1))*255);
    for c = 1:3
        Out(:,:,c) = Out(:,:,c) + tmp*this.stack(i).color(c);
    end
end
