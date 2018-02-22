function load(this, Seq, type)
% Load a sequence of images in the device RAM
%
% NB: sequence identifiers start at 1, not 0 !
  
% --- Default values

if ~exist('type', 'var')
    type = 'sequence';
end

% --- Conversion for grey levels images
if strcmp(type, 'grey')
    Img = Seq;
    Seq = uint8(NaN(size(Img,1), size(Img,2), 256));
    for i = 1:256, Seq(:,:,i) = uint8((Img>i)*255); end
    Seq = cat(3, Seq(:,:,1:2:end), Seq(:,:,end-1:-2:1));
end

% --- Allocate the RAM

fprintf('Allocating the RAM ...'); tic

% Get sequence bitDepth
tmp = whos('Seq');
bitDepth = tmp.bytes/numel(Seq);

% Allocate the RAM
res = calllib(this.dll, 'AlpSeqAlloc', this.device, ...
    bitDepth, size(Seq,3), libpointer('uint32Ptr', uint32(this.sequenceId)));
fprintf(' %0.2f sec\t\t\t', toc);

% Check the number of frames allocated
[~, n] = calllib(this.dll, 'AlpSeqInquire', this.device, ...
   this.sequenceId, int32(2201), libpointer('int32Ptr', int32(0)));

dispResult(res, n);

% --- Load the sequence

fprintf('Loading sequence ...'); tic

res = calllib(this.dll, 'AlpSeqPut', this.device, ...
    this.sequenceId, 0, size(Seq,3), libpointer('voidPtr', Seq));

fprintf(' %0.2f sec\t\t\t', toc);
dispResult(res, n);

% --- Set the framerate for PWM
if strcmp(type, 'grey')
    this.rate(15000);
end

end

% === Result display ==============================================
function dispResult(res, n)
    switch res
        case 0
            if n==1, fprintf('[\bOK]\b (%i image loaded)\n', n);
            else, fprintf('[\bOK]\b (%i images loaded)\n', n); end
        otherwise
            fprintf(2, '<strong>Failure (%i)</strong>\n', res);
    end
end