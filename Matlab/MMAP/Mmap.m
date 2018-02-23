classdef Mmap < handle
% the class Mmap is used to load a mmap by its tag (ex raw)
% and redefine layers index when called as subscript
    properties
        tag
        mmap
        x % width
	y % height
	z % number of layers
	t % number of time frame
        Z % layers concerned
        T % times concerned
    end
    methods
        function self = Mmap(F, tag)
        %Mmap constructor takes a tag to know which mmap to load
            self.tag = tag;
            inputInfo = fullfile(F.dir.files, [tag '.mat']); % TODO know automatically location
            load(inputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T');
            self.mmap = mmap;
            self.x = x; 
            self.y = y; 
            self.z = z; 
            self.t = t; 
            self.Z = Z; 
            self.T = T; 
        end
        
        function out = subsref(self, S)
        %subsref calls the mmap with the correct z index
            switch S(1).type
                case '()'
                    old_z = S.subs{3}; % values asked ex [4 5 6]
                    new_z = NaN(size(old_z)); % values corrected ex [2 3 4]
                    for i = 1:length(old_z)
                        try
                            new_z(i) = find(self.Z == old_z(i));
                        catch
                            error('INDEX OUT OF RANGE : trying to reach layers outside mmap')
                        end
                    end
                    new_S = S(1);
                    new_S.subs{3} = new_z;
                    out = subsref(self.mmap.Data.bit, new_S);
                case '.'
                    out = builtin('subsref', self, S);
                otherwise
                    error('subsref other than () or . are not implemented')
            end        
        end
    end
end
        
            
