function updatePixelInfo(this)

tmp = round(get(this.visu, 'CurrentPoint'));
x = min(max(1, tmp(1)), this.visuWidth);
y = min(max(1, tmp(3)), this.visuWidth);
k = round(get(this.slider, 'Value'));

i = min(max(y*this.zoom,1), size(this.stacks(1).data, 1));
j = min(max(x*this.zoom,1), size(this.stacks(1).data, 2));
p = this.stacks(1).data(i,j, k);

set(this.info.pixelInfo, 'string', ['(' num2str(x) ',' num2str(y) ') - ' num2str(p)]);