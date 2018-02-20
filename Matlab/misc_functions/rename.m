function rename(p_date, p_run)
%rename is a tiny utility to rename the files from the camera style to a reference style
% i.e. : Images_5_000001 → Image0_000000
% Hugo Trentesaux 2018-02-19

% --- Java way to renames files (Guillaume)
Data_path = [pwd filesep 'Data' filesep p_date filesep 'Run ' num2str(p_run,'%02i') filesep];
cd([Data_path, 'Images/']);
files = dir( '*.tif');
for i = 1:length(files)
    oldname = files(i).name ;
    newname = ['Image0_', num2str(i-1,'%05i'), '.tif'];
    java.io.File(oldname).renameTo(java.io.File(newname));
end
