classdef Mmap2D < handle
    % analog of Mmap class, but for 2D stacks (not 4D)
    properties
        tag
        mmap
        x
        y
        z
        t
        Z
        T
        indices
        numIndex
    end
    methods
        function self = Mmap2D(F, tag, z)
            % constructor
            self.tag = tag;
            inputInfo = fullfile(F.dir.IP, tag, [num2str(z,'%02d') '.mat']);
            load(inputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
            self.mmap = mmap;
            self.x = x;
            self.y = y;
            self.z = z;
            self.t = t;
            self.Z = Z;
            self.T = T;
            self.indices = indices;
            self.numIndex = numIndex;
        end
        
        function out = subsref(self, S)
            %subsref calls the mmap with the correct z index
            switch S(1).type
                case '()'
                    out = subsref(self.mmap.Data.bit, S(1));
                case '.'
                    out = builtin('subsref', self, S);
                otherwise
                    error('subsref other than () or . are not implemented')
            end
        end
    end
end
