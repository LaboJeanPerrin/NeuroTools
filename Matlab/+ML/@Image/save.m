function save(this, name)
%IMAGES.IMAGE.SAVE Save the image to a file
%*  IMAGES.IMAGE.SAVE(FILENAME) save the image in FILENAME.
%
%*  See also: Images.Image.load.

% --- Optional input
if exist('name', 'var')
    [this.path, this.name, this.ext] = fileparts(name);
    this.path = [this.path filesep];
    this.ext = this.ext(2:end);
end

% --- Checking
if ~exist(this.path, 'dir')
    mkdir(this.path);
end

% --- Writing
imwrite(this.pix, [this.path this.name '.' this.ext], lower(this.ext));
