classdef Paf<handle
%NT.Paf Class to handle Portable Array Files

    % --- PROPERTIES ------------------------------------------------------
    properties (Access = public)
        
        filepath
        type
        size
        mmap
        description
        
    end
    
    % --- METHODS ---------------------------------------------------------
    methods
        
        % _________________________________________________________________
        function this = Paf(varargin)
        %NT.Paf Constructor
        
            % --- Inputs --------------------------------------------------
            
            % Validation
            p = inputParser;
            addRequired(p, 'filepath', @ischar);
            parse(p, varargin{:});
            
            % Assignation
            this.filepath = p.Results.filepath;

            % --- Process -------------------------------------------------
            
            % --- Open file for reading
            
            fid = fopen(this.filepath, 'r');
            
            % --- Get data type
            this.type = '';
            while true
                tmp = fread(fid, 1, 'char');
                if tmp==newline
                    break;
                else
                    this.type(end+1) = tmp;
                end
            end
            
            % --- Get array size 
            s = '';
            while true
                tmp = fread(fid, 1, 'char');
                if tmp==newline
                    break;
                else
                    s = [s tmp];
                end
            end
            this.size = cellfun(@str2double, split(s, ' '))';
            
            % --- Get description
            this.description = '';
            while true
                tmp = fread(fid, 1, 'char');
                if tmp==newline
                    break;
                else
                    this.description(end+1) = tmp;
                end
            end
            
            % --- Close file
            fclose(fid);
            
            % --- Get a memory map of the data
            offset = numel(this.type) + numel(s) + numel(this.description) + 3;
            this.mmap = memmapfile(this.filepath, 'Offset', offset, 'Format', {this.type, this.size, 'array'}, 'Writable', true);
            
        end
            
    end
    
    % --- STATIC METHODS --------------------------------------------------
    methods(Static)
             
      function array2Paf(varargin)
          
          % --- Inputs --------------------------------------------------
          
          % Validation
          p = inputParser;
          addRequired(p, 'array', @isnumeric);
          addRequired(p, 'filepath', @ischar);
          addParameter(p, 'description', '', @ischar);
          parse(p, varargin{:});
          
          % Assignation
          array = p.Results.array;
          filepath = p.Results.filepath;
          description = p.Results.description;
          
          % ---------------------------------------------------------------
          
          % Open file
          fid = fopen(filepath, 'w');
          
          % Array type
          fwrite(fid, [class(array) newline], 'char');
          
          % Array size
          for i = 1:numel(size(array))
              fwrite(fid, num2str(size(array,i)), 'char');
              if i<numel(size(array))
                  fwrite(fid, ' ', 'char');
              else
                  fwrite(fid, newline, 'char');
              end
          end          
          
          % Description
          fwrite(fid, [description newline], 'char');
          
          % --- Append data
          
          % NOTE: maybe consider fallocate (on Unix systems) and memmapfile
          % for speed. This is not obvious though, since fwrite is already
          % quite fast.
          
          fwrite(fid, array, class(array));
          
          % Close file
          fclose(fid);
          
      end
    
      function images2Paf(varargin)
         
          % --- Inputs --------------------------------------------------
          
          % Validation
          p = inputParser;
          addRequired(p, 'ipath', @ischar);
          addRequired(p, 'filepath', @ischar);
          addParameter(p, 'layers', 1, @isnumeric);
          addParameter(p, 'description', '', @ischar);
          addParameter(p, 'verbose', true, @islogical);
          parse(p, varargin{:});
          
          % Assignation
          ipath = p.Results.ipath;
          filepath = p.Results.filepath;
          layers = p.Results.layers;
          description = p.Results.description;
          verbose = p.Results.verbose;
          
          % --- Image infos -----------------------------------------------
          
          if verbose
              fprintf('Gathering image infos ...');
              tic
          end
          
          D = dir(ipath);
          
          % Check
          
          if isempty(D)
              warning('NT.Paf:NoImage', 'No image found.');
              return
          end
          
          % Get image info
          
          iname = @(i) [D(i).folder filesep D(i).name];
          info = imfinfo(iname(1));
          
          % Process image info
          
          switch info.BitDepth
              case 8, type = 'uint8';
              case 16, type = 'uint16';
          end
          
          width = info.Width;
          height = info.Height;
          
          switch layers
              case 1
                  arraySize = [height width numel(D)];
              otherwise
                  arraySize = [height width layers numel(D)/layers];
          end
          
          if verbose
            fprintf(' %0.2f sec\n', toc);
          end
          
          % --- Creating Paf file -----------------------------------------
          
          if verbose
              fprintf('Creating Paf file ...');
              tic
          end
          
          % Open file
          fid = fopen(filepath, 'w');
          
          % Array type
          fwrite(fid, [type newline], 'char');
          
          % Array size
          for i = 1:numel(arraySize)
              fwrite(fid, num2str(arraySize(i)), 'char');
              if i<numel(arraySize)
                  fwrite(fid, ' ', 'char');
              else
                  fwrite(fid, newline, 'char');
              end
          end          
          
          % Description
          fwrite(fid, [description newline], 'char');
          
          % --- Append data

          for i = 1:numel(D)
              Img = imread(iname(i));
              fwrite(fid, Img, type);
              if ~mod(i,1000), fprintf('.'); end
          end
          
          % Close file
          fclose(fid);
          
          if verbose
              fprintf(' %0.2f sec\n', toc);
          end

      end
      
    end
end
