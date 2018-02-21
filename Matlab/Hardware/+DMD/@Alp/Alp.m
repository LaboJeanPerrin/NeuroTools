classdef Alp < handle
    
    properties (Access = public)
       
        % serialNumber
        deviceId = 0;
        sequenceId = 1
        
    end
    
    properties (Access = private)
        
        dll = 'alp4395'
        device
        
    end
    
    methods (Access = public)
   
        % === Constructor =================================================
        function this = Alp()
            % Constructor of the Alp objects
                        
            % --- Load the DMD library
        
            % Definitions
            baseDir = 'C:\Program Files\ALP-4.3\ALP-4.3 API\';
            dllFile = [baseDir 'x64\' this.dll '.dll'];
            headerFile = [baseDir 'Alp.h'];
            
            % Load the dynamic library
            if ~libisloaded(this.dll)
                
                fprintf('Loading the library ...'); tic
                loadlibrary(dllFile, headerFile);                
                fprintf(' %0.2f sec - ', toc);
            
                this.dispResult(~libisloaded(this.dll));
                
            end
            
            % --- Allocate the DMD device
            
            fprintf('Allocating the device ...'); tic
            
            % Make an outpointer to write
            hdeviceptr = libpointer('uint32Ptr', this.deviceId); 
            
            % Get the DMD device
            [res, this.device] = calllib(this.dll, 'AlpDevAlloc', int32(0), int32(0), hdeviceptr);
            fprintf(' %0.2f sec - ', toc);
            this.dispResult(res);
                        
        end
        
        % === Destructor ==================================================
        function delete(this)
            
            % Free the device
            fprintf('Freeing the device ...'); tic
            res = calllib(this.dll, 'AlpDevFree', this.device);
            fprintf(' %0.2f sec - ', toc);
            this.dispResult(res);
            
        end
        
        % === Result display ==============================================
        function dispResult(~, res)
            switch res
                case 0, fprintf('Success\n');
                otherwise, fprintf('Failure (%i)\n', res);
            end
        end
    end
    
end