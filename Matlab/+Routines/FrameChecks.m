function status = FrameChecks(varargin)
%FrameChecks Check frames before pre-processing
%   Routines.FrameChecks performs the following checks on the frames of the
%   current Focus:
%
%   - Number of frames
%       The number of frames (computed and stored in F.frames.Number) must
%       match the number of fframes defined in the Parameters file (defined
%       in F.param.NFrames). If not ...
%
%   - Digit format
%       The number fo digits in the frame names must be sufficient to
%       describe the whole dataset. Depending on the number of images the
%       format should be:
%       * 0-9           %01f
%       * 10-99         %02f
%       * 100-999       %03f
%       * 1000-9999     %04f
%       * 10000-99999   %05f
%       * ... and so on
%

% --- Parameters ----------------------------------------------------------

in = ML.Input;
in.force(false) = @islogical;
in = +in;

% -------------------------------------------------------------------------

% Get current Focus
F = Focus.current;

% Prepare output
status = true;

% === NUMBER OF FRAMES ====================================================

% TO DO !!

% === DIGIT FORMAT ========================================================

% Minimum number of digits
mnod = ceil(log10(F.frames.Number));

% Number of digits
nod = str2double(F.frames.Format(3:end-1));

if nod<mnod
    
    if ~in.force
        ML.CW.line('~bc[teal]{Digit check}');
        ML.CW.print('\nThe number of digits in the frame names is insufficient.\n');
        ML.CW.print('Do you want to start automatic correction ? [Y/n]\n');
    end
    
    while true
        
        if in.force
            z = 'y';
        else
            z = input('?> ', 's');
        end
        
        switch lower(z)
            
            case {'', 'y'}
                
                lim = 10^(mnod-1)-1;
                wb = waitbar(0,'Formating files ...');
                
                for i = 0:lim

                    prevname = [F.dir.images F.frames.Prefix num2str(i, ['%0' num2str(nod) 'i']) F.frames.Extension];
                    if exist(prevname, 'file')
                        movefile(prevname, [F.dir.images F.frames.Prefix num2str(i, ['%0' num2str(mnod) 'i']) F.frames.Extension]);
                    end

                    % Waitbar
                    if ~mod(i,200), waitbar(i/lim, wb); end
                    
                end
                close(wb);
                
                % Update Focus
                F.frames.Format = ['%0' num2str(mnod) 'i'];
                
                break
                
            case 'n'
                status = false;
                break
        end
    end
end

% --- Output
if ~status
    warning('Routines:FailedFrameChecks', 'Checks failed.');
end