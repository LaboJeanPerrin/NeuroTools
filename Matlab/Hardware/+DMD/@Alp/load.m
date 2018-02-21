function load(this, Seq)
% Load a sequence of images in the device RAM
%
% NB: sequence identifiers start at 1, not 0 !
  
% --- Allocate the RAM

fprintf('Allocating the RAM ...'); tic

% Get sequence bitDepth
tmp = whos('Seq');
bitDepth = tmp.bytes/numel(Seq);

% Allocate the RAM
res = calllib(this.dll, 'AlpSeqAlloc', this.device, ...
    bitDepth, size(Seq,3), libpointer('uint32Ptr', uint32(this.sequenceId)));
fprintf(' %0.2f sec\n', toc);

% % % % Check the number of frames allocated
% % % [~, n] = calllib(this.dll, 'AlpSeqInquire', this.device, ...
% % %    this.sequenceId, int32(2201), libpointer('int32Ptr', int32(0));

% --- Load the sequence

fprintf('Loading sequence ...'); tic

res = calllib(this.dll, 'AlpSeqPut', this.device, ...
    this.sequenceId, 0, size(Seq,3), libpointer('voidPtr', Seq));

fprintf(' %0.2f sec\n', toc);
