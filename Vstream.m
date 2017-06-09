function varargout = Vstream(varargin)
% Vstream MATLAB code for Vstream.fig
%      Vstream, by itself, creates a new Vstream or raises the existing
%      singleton*.
%
%      H = Vstream returns the handle to a new Vstream or the handle to
%      the existing singleton*.
%
%      Vstream('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Vstream.M with the given input arguments.
%
%      Vstream('Property','Value',...) creates a new Vstream or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Vstream_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Vstream_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Vstream

% Last Modified by GUIDE v2.5 22-Jun-2016 16:31:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Vstream_OpeningFcn, ...
                   'gui_OutputFcn',  @Vstream_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Vstream is made visible.
function Vstream_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Vstream (see VARARGIN)

% Choose default command line output for Vstream
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global rlsiDat
rlsiDat=[];
try
    rlsiDat.sID = varargin{1}; % subject number
    rlsiDat.type = varargin{2};
catch
    error(['Incorrect parameters entered: RLSI(SubjectNumber,TYPE)' ...
        'Type should be pretest, thresh or test']);
end
%% initialise the motu

% UIWAIT makes Vstream wait for user response (see UIRESUME)
% uiwait(handles.figure1);
rlsiDat.fs=44100; % speech sounds are at 44100
rlsiDat.spks2use = [4:16];%[4,6,8,9,10,11,12,14,16];
rlsiDat.nSpk =length(rlsiDat.spks2use);
InitializePsychSound; % initialize psychtoolbox

nrchannels = 24; % Total number of channels to be used
try
    % Try with the 'frequency we wanted: % to check if this is a problem
    % run
    %   InitializePsychSound
    %   a=PsychPortAudio('GetDevices', 3);% find which a(n) (usually a(2) is
    %  the motu (which has 24 output channels) and change the channel number from 47 to whatever it is
    %  now which is listed as the "DeviceIndex")
    
    InitializePsychSound;
    
    % Close all devices
    PsychPortAudio('Close');
    
    % Check base workspace for AO - probably redundant now
    % Try and get AO from workspace
    try
        AO = evalin('base', 'AO');
    catch
        AO = [];
    end
    
    % Close PortAudio if open
    if exist('AO', 'var') && isfield(AO,'ao')
        PsychPortAudio('Close', AO.ao)
    end
    
    % Find MOTU
    devs=PsychPortAudio('GetDevices');
    d=1;
    
    found=0;
    disp('Watiting to connect to MOTU...')
    while found==0
        disp(['Checking device ', num2str(d), '...'])
        if strcmp(devs(d).DeviceName, 'MOTU PCI ASIO')==1
            found=1;
            AO.device=d-1;
        else
            if d < 100
                d=d+1;
            else
                d = 1;
            end
        end
    end
    
    rlsiDat.pahandle = PsychPortAudio('Open',  AO.device, [], 0, rlsiDat.fs, nrchannels); %69 is the MOTU device
catch
    
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', rlsiDat.fs);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    
    psychlasterror('reset');
    rlsiDat.pahandle = PsychPortAudio('Open', 58, [], 0, rlsiDat.fs, nrchannels);
end

%% initialise variables;
rlsiDat.h = handles;
rlsiDat.input=cell(1);
rlsiDat.output=cell(1);
%rlsiDat.h.allboxes=[rlsiDat.h.box1 rlsiDat.h.box2 rlsiDat.h.box3 rlsiDat.h.box4];
type = varargin{2};
if strcmp(type,'click')

rlsiDat.trials = makeTrialSequenceClickTrains;%piloting settings (one vowel and a click train).
    rlsiDat.fileName = ['C:\toolbox\Psychtoolbox\JB_streaming\data\' 'Subj' num2str(rlsiDat.sID), rlsiDat.type,date '-click-'];

elseif strcmp(type,'vowel')

trials = makeTrialSequenceVowelTrains;%piloting settings (one vowel and a click train).

    trials = repmat(trials, 6, 1);
    rlsiDat.trials = trials(randperm(length(trials)),:);
    rlsiDat.fileName = ['C:\toolbox\Psychtoolbox\JB_streaming\data\' 'Subj' num2str(rlsiDat.sID), rlsiDat.type,date '-click-'];
    

else
    error('invalid session type entered, please try again (should be *pretest*, *thresh* , *test* or *restart*');
end

  rlsiDat.tNum = 1 ;
%     rlsiDat.bNum = a.rlsiDat.bNum ;
%     rlsiDat.firstTrial = 0;
     rlsiDat.response2 = [];
%     rlsiDat.response =[];
%     rlsiDat.respTime1 = [];
     rlsiDat.respTime2 = [];
%     rlsiDat.imData{1} = [];
     rlsiDat.data=[];

%
% set(rlsiDat.h.Start,'visible','on');
%
%wait for start

%waitfor(rlsiDat.h.Start,'visible','off');

%start the task timer
rlsiDat.tasktimer=timer('TimerFcn','streamTaskTick','BusyMode','drop', 'ExecutionMode','fixedRate','Period',0.2);

rlsiDat.status = 'PrepareStim';
start(rlsiDat.tasktimer);
% --- Outputs from this function are returned to the command line.


function varargout = Vstream_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% eventdata % Let's see the KeyPress event data
% disp(eventdata.Key) % Let's display the key, for fun!

% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlsiDat 
set(rlsiDat.h.Start,'visible','off')

% --- Executes on button press in left.
function left_Callback(hObject, eventdata, handles)
% hObject    handle to left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rlsiDat
rlsiDat.response2 = 0;
rlsiDat.respTime2 = GetSecs;

% --- Executes on button press in right.
function right_Callback(hObject, eventdata, handles)
% hObject    handle to right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rlsiDat

rlsiDat.response2 = 1;
rlsiDat.respTime2 = GetSecs;

% --- Executes on mouse press over axes background.
function box1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to box1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlsiDat

rlsiDat.response = [rlsiDat.response;01];
rlsiDat.respTime1 = [rlsiDat.respTime1;GetSecs];

% --- Executes on mouse press over axes background.
function box2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to box2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlsiDat

rlsiDat.response = [rlsiDat.response;02];
rlsiDat.respTime1 = [rlsiDat.respTime1;GetSecs];
% --- Executes on mouse press over axes background.
function box3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to box3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlsiDat

rlsiDat.response = [rlsiDat.response;03];
rlsiDat.respTime1 = [rlsiDat.respTime1;GetSecs];

% --- Executes on mouse press over axes background.
function box4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to box4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlsiDat

rlsiDat.response = [rlsiDat.response;04];
rlsiDat.respTime1 = [rlsiDat.respTime1;GetSecs];


% --- Executes on key press with focus on left and none of its controls.
function left_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to left (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
