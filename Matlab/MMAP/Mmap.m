classdef Mmap < handle
% the class Mmap is used to load a mmap by its tag (ex raw)
% and redefine layers index when called as subscript
% allows to call by linear subscript thanks to mmaplin
    properties
        tag % name of the mmap (ex raw, corrected)
        binFile % relative path of the binary file (from / = Files)
        mmap % 4D mmap (x,y,z,t)
        mmaplin % 3D mmap of *the same* binary file (xy, z, t)
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
            self.binFile = [tag '.bin'];
            binFile = fullfile(F.dir.files, self.binFile); % TODO know automatically location thanks to tag 
            inputInfo = fullfile(F.dir.files, [tag '.mat']); % TODO know automatically location thanks to tag
            load(inputInfo, 'x', 'y', 'z', 't', 'Z', 'T');
            self.mmap = ...
                memmapfile(binFile,'Format',{'uint16',[x,y,z,t],'bit'});
            self.mmaplin = ...
                memmapfile(binFile,'Format',{'uint16',[x*y,z,t],'bit'});
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
                    switch length(S(1).subs)
                        case 4 % 4D
                            zpos = 3; % position of the z coordinate in the subscript
                        case 3 % 3D with xy as index
                            zpos = 2; % position of the z coordinate in the subscript
                        otherwise
                            error('NUMBER OF SUBSCRIPT NOT COMPATIBLE')
                    end
                    % corrects the z
                    old_z = S.subs{zpos}; % values asked ex layers [4 5 6]
                    new_z = self.zCorrect(old_z); % values corrected ex index [2 3 4]
                    new_S = S; % (avoid illegal use of subscript parameter)
                    new_S(1).subs{zpos} = new_z; % replace the z in the subscript
                    
                    % calls the right mmap
                    switch length(S(1).subs)
                        case 4 % 4D
                            out = subsref(self.mmap.Data.bit, new_S);
                        case 3 % 3D with xy as index
                            out = subsref(self.mmaplin.Data.bit, new_S);
                    end
                case '.'
                    out = builtin('subsref', self, S);
                otherwise
                    error('subsref other than () or . are not implemented')
            end        
        end
    end
    
    methods %(Static)
        function new_z = zCorrect(self, old_z)
        %zCorrect returns z compatible with mmap
        % example :
        % input is 4 5 6
        % output should be 2 3 4

            new_z = NaN(size(old_z)); % values corrected ex [2 3 4]
            for i = 1:length(old_z)
                try
                    new_z(i) = find(self.Z == old_z(i));
                catch
                    error('INDEX OUT OF RANGE : trying to reach layers outside mmap\n    asked : %s\n    available : %s', num2str(old_z), num2str(self.Z))
                end
            end

        end
        
    end
    
end
        
            
