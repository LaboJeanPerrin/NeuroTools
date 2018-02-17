function Out = prepare(this, k)

Out = uint8(zeros(this.dispHeight, this.dispWidth, 3));

for i = 1:numel(this.stack)
    tmp = this.stack(i).data(1:this.zoom:end, 1:this.zoom:end, k);
    tmp = uint8((double(tmp)-this.stack(i).range(1))/(this.stack(i).range(2)-this.stack(i).range(1))*255);
    for c = 1:3
        Out(:,:,c) = Out(:,:,c) + tmp*this.stack(i).color(c);
    end
end

% this.stack(1).data)
% 
% Out = uint8((double(In)-this.range(1))/(this.range(2)-this.range(1))*255);
% Out = repmat(Out, [1 1 3]);
