function import_Lightsheet(this, LS)
% Import from a Lightsheet object

% --- General -------------------------------------------------------------

% --- Version
this.Version = LS.Version;

% --- Study
list = get(LS.UI.Study, 'String');
this.Study = list{get(LS.UI.Study, 'Value')};

% --- Date
this.Date = get(LS.UI.Date, 'String');

% --- Run name
this.RunName = LS.Run.Name;

% --- Description
this.Description = 'This is a description.';

% --- Images --------------------------------------------------------------

% --- Camera model
list = get(LS.UI.Model, 'String');
this.CameraModel = list{get(LS.UI.Model, 'Value')};

% --- Fluo mode
list = get(LS.UI.FluoMode, 'String');
this.FluoMode = list{get(LS.UI.FluoMode, 'Value')};

% --- Mirrors & piezo -----------------------------------------------------

% Horizontal mirror
this.HM_Position_min = str2double(get(LS.UI.HM_Position_min, 'String'));
this.HM_Position_max = str2double(get(LS.UI.HM_Position_max, 'String'));
this.HM_um2V = str2double(get(LS.UI.HM_um2V, 'String'));

% Vertical mirror
this.VM_Position = str2double(get(LS.UI.VM_Position, 'String'));
this.VM_um2V = str2double(get(LS.UI.VM_um2V, 'String'));

% Objective piezo
this.OP_Position = str2double(get(LS.UI.OP_Position, 'String'));
this.OP_um2V = str2double(get(LS.UI.OP_um2V, 'String'));

% --- Light scan ----------------------------------------------------------

% HM mode
this.HM_Mode = get(get(LS.UI.HM_Mode, 'SelectedTab'), 'Title');

switch this.HM_Mode
    case 'Slave'
        this.DelayBefore = str2double(get(LS.UI.DelayBefore, 'String'));
        this.DelayAfter = str2double(get(LS.UI.DelayAfter, 'String'));
end

% Scan shape
list = get(LS.UI.HM_Shape, 'String');
this.HM_Shape = list{get(LS.UI.HM_Shape, 'Value')};

% HM Rate
this.HM_Rate = str2double(get(LS.UI.HM_Rate, 'String'));

% --- Layers --------------------------------------------------------------

this.NLayers = str2double(get(LS.UI.NLayers, 'String'));
this.Exposure = str2double(get(LS.UI.Exposure, 'String'));
this.Delay = str2double(get(LS.UI.Delay, 'String'));

if this.NLayers>1
    
    this.DelayLong = str2double(get(LS.UI.DelayLong, 'String'));
    
    % Steps shape
    list = get(LS.UI.StepsShape, 'String');
    this.StepsShape = list{get(LS.UI.StepsShape, 'Value')};
    
    this.Increment = str2double(get(LS.UI.Increment, 'String'));
    
    % Stabilization
    list = get(LS.UI.StabShape, 'String');
    this.StabShape = list{get(LS.UI.StabShape, 'Value')};
    this.StabRatio = str2double(get(LS.UI.StabRatio, 'String'));
    
else
    
    this.DelayLong = [];
    this.StepsShape = [];
    this.Increment = [];
    this.StabShape = [];
    this.StabRatio = [];
    
end

% --- Timing --------------------------------------------------------------

this.NCycles = str2double(get(LS.UI.NCycles, 'String'));
this.CycleTime = str2double(get(LS.UI.CycleTime, 'String'));
this.NFrames = str2double(get(LS.UI.NFrames, 'String'));
this.RunTime = str2double(get(LS.UI.RunTime, 'String'));

% --- Signals -------------------------------------------------------------

this.Signals = LS.Signals;
