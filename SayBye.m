% This code is created by Dingzhi Hu, 2017.7
% Anyone who wants to use this code, or the program need to be authorized!!

function varargout = SayBye(varargin)
% SAYBYE MATLAB code for SayBye.fig
%      SAYBYE, by itself, creates a new SAYBYE or raises the existing
%      singleton*.
%
%      H = SAYBYE returns the handle to a new SAYBYE or the handle to
%      the existing singleton*.
%
%      SAYBYE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAYBYE.M with the given input arguments.
%
%      SAYBYE('Property','Value',...) creates a new SAYBYE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SayBye_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SayBye_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SayBye

% Last Modified by GUIDE v2.5 12-Jul-2017 13:47:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SayBye_OpeningFcn, ...
                   'gui_OutputFcn',  @SayBye_OutputFcn, ...
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


% --- Executes just before SayBye is made visible.
function SayBye_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SayBye (see VARARGIN)


% UIWAIT makes SayBye wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Choose default command line output for SayBye
handles.output = hObject;

if ~isempty(varargin)
    for i = 1 : 2 : length(varargin)
        eval([varargin{i} '= varargin{i + 1};']);
    end;
    eval(['set(handles.intro_word, ''String'', ' varargin{1} ');']);
end;

% Update handles structure
guidata(hObject, handles);

uiwait;


% --- Outputs from this function are returned to the command line.
function varargout = SayBye_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.figure1;



% --- Executes during object deletion, before destroying properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in intro_word.
function intro_word_Callback(hObject, eventdata, handles)
% hObject    handle to intro_word (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Certify.
function Certify_Callback(hObject, eventdata, handles)
% hObject    handle to Certify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;
