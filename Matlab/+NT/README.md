# Neurotools

Neurotools contains several classes as @Focus, @Parameters, @Image...

## Using Neurotools for data analysis

The Focus class helps you access your files during analysis if you respect the standard folder architecture : Data/Study/yyy-mm-dd/Run 01/Parameters.txt. A lot of functions in 'easyRLS' will require a valid focus as their first argument. It will let them know where to find files and where to record files.
 
To create a focus during analysis, simply instanciate the class :

	F = NT.Focus({rootFolder, 'Study', 'yyyy-mm-dd', 1});

It will:
- search and load a parameter file named 'Parameters.txt' in the 'Data/Study/yyy-mm-dd/Run 01/' folder.
- try to parse some information on images in 'Data/Study/yyy-mm-dd/Run 01/Images/'
- create config file (or load if existing) in 'Data/Study/yyy-mm-dd/Run 01/Files/Config.m'

If you do not have a study repertory, just let an empty string (`''`) and it will be ignored. If you name your runs in a different way as 'Run%.02d', just give the full string (for example 'Run_0001').
