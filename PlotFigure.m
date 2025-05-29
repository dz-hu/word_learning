% This code is created by Dingzhi Hu, 2017.7
% Anyone who wants to use this code, or the program need to be authorized!!

function varargout = PlotFigure(varargin)
% PLOTFIGURE MATLAB code for PlotFigure.fig
%      PLOTFIGURE, by itself, creates a new PLOTFIGURE or raises the existing
%      singleton*.
%
%      H = PLOTFIGURE returns the handle to a new PLOTFIGURE or the handle to
%      the existing singleton*.
%
%      PLOTFIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTFIGURE.M with the given input arguments.
%
%      PLOTFIGURE('Property','Value',...) creates a new PLOTFIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotFigure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotFigure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlotFigure

% Last Modified by GUIDE v2.5 12-Jul-2017 13:31:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotFigure_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotFigure_OutputFcn, ...
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


% --- Executes just before PlotFigure is made visible.
function PlotFigure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotFigure (see VARARGIN)


% UIWAIT makes PlotFigure wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Choose default command line output for PlotFigure
handles.output = hObject;

if ~isempty(varargin)
    for i = 1 : 2 : length(varargin)
        eval([varargin{i} '= varargin{i + 1};']);
    end
end

if length(varargin) > 2
    plot_results(handles.axes2, subName, group, DayName, SigSeq, ScoreSeq, signalIdx, IsOld);
else
    plot_all_results(handles.axes2, subName);
end

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = PlotFigure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure



% --- Executes on button press in Title.
function Title_Callback(hObject, eventdata, handles)
% hObject    handle to Title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object deletion, before destroying properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in Certify.
function Certify_Callback(hObject, eventdata, handles)
% hObject    handle to Certify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1);
