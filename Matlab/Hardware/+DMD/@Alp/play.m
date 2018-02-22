function play(this, duration)
%DMD.Alp.play Play a sequence for a given duration (in seconds)
      
% Start display      
this.start

pause(duration)

% Stop display
this.stop

