classdef Viewer < handle
%NT.Viewer Class to visualize data

    % --- PROPERTIES ------------------------------------------------------
    properties (Access = public)
        
        % --- Window management
        
        screen = 0;
        
        % --- Connectivity
        
        Conn = struct();
        port = 3231;
        
        % --- Parameters
        
        view = '3D';
        dataSet
        
        warnings = true;
        verbose = true;
        
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = Viewer(varargin)
        % NT.Viewer Constructor
            
            % --- Connections ---------------------------------------------
            
            % --- Instructions
            
            this.Conn.Commands = tcpip('localhost', this.port);
            set(this.Conn.Commands, 'BytesAvailableFcnMode', 'terminator');
            set(this.Conn.Commands, 'BytesAvailableFcn', @this.newCommand);            
            
            try
                fopen(this.Conn.Commands);
                if this.verbose
                    fprintf('  [[\bconnnection]\b] Command\n');
                end
            catch ME
                if this.warnings
                    warning(ME.identifier, '%s', ME.message);
                end
            end
            
            this.Conn.Data = struct('conn', {}, 'available', {});
            
            % --- Datasets ------------------------------------------------
            this.dataSet = struct('name', {}, 'type', {}, 'X', {}, 'Y', {}, 'Z', {}, ...
                'data', {}, 'faces', {}, 'transform', {}, 'cmap', {}, 'visible', {}, 'frozen', {}, ...
                'x2um', {}, 'y2um', {}, 'z2um', {}, 'T', {}, 't', {}, 't2s', {});
            
        end
         
        % _________________________________________________________________
        function delete(this)
        % NT.Viewer destructor
        
            fclose(this.Conn.Commands);
%             fclose(this.Conn.Data);
            
        end
        
        % _________________________________________________________________
        function this = set.view(this, value)
        
            if ismember(value, {'montage', '3D'})
                this.sendCommand(['display:0:view:' value]);
            else
                if this.warnings
                    warning('Invalid property value. The view can be ''3D'' or ''montage''.');
                end
            end
            
        end
        
    end
    
end
