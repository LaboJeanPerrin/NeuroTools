classdef Mmap < handle
% the class Mmap is used to load a mmap by its tag (ex raw) and redefine
% layers index when called as subscript
    properties
        mmap
        width
        height
        Z
        T
    end
    methods
        function self = Mmap(F, tag)
        %Mmap constructor takes a tag to know which mmap
        mmapPath = fullfile(F.dir.files, [tag '.mmap.mat']);
        load(mmapPath, 'mmap', 'X', 'Y', 'Z', 'T');
        self.mmap = mmap;
        self.width = X(end); %#ok<COLND>
        self.height = Y(end); %#ok<COLND>
        self.Z = Z;
        self.T = T;
        end
        
        function out = subsref(self, S)
        %subsref calls the mmap with the correct z index
            switch S.type
                case '()'
                    old_z = S.subs{3}; % values asked ex [4 5 6]
                    new_z = NaN(size(old_z));
                    for i = 1:length(old_z)
                        new_z(i) = find(self.Z == old_z(i));
                    end
                    new_S = S;
                    new_S.subs{3} = new_z;
                    out = subsref(self.mmap.Data.raw, new_S);
                case '.'
                    out = builtin('subsref', self, S);
                otherwise
                    error('subsref other than () or . are not implemented')
            end        
        end
    end
end
        
            