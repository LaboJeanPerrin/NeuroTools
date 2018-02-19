function F = getFocus(p_date, p_run)
%getFocus Get a Focus (static method of focus)
%   F = GETFOCUS(DATE, RUN) Returns the Focus corresponding to RUN at DATE.
%   if a config file exists, load it, otherwise, create it
%
%   See also Focus.

% =========================================================================


% --- Return the Focus
F = Focus(p_date, p_run);

end

