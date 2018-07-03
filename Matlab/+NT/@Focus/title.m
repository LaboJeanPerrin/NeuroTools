function title(this, T)
%FOCUS.TITLE Fancy figure title
%*  FOCUS.TITLE() Add a specific title to the figure
%
%*  See also: Focus.

if exist('T', 'var')
    if ~iscell(T)
        T = {T};
    end
else
    T = {};
end

T{end+1} = [this.name ' - set ' num2str(this.set.id)];

title(T);