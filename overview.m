% This code is created by Dingzhi Hu, 2017.7
% revised by Dingzhi Hu, 2020.12
% Anyone who wants to use this code, or the program has to be authorized!! 
%
% overview('SoundFile', soundfile, 'VideoFile', videofile, 'TagName', tagName, 'TagChoice', textTag,...
%   'RightChoice', rightChoiceIdx, 'Soundtype', soundtype, 'Descriptions', descriptions);
%
% Var Definition: * Ϊ������
%   * SoundFile, VideoFile: The file of sound and video of the signal;
%       �ź������ļ���·��: string
%       e.g. soundfile = 'C:\auditory_learning\sound_learning\SoundandVideo\*.mat';
%   * TagName: The name of every tag
%       ÿ���Ӧ������: 5 * 1 cell
%       e.g. tagname = {'distance';'decay';'linefreq';'bandfreq';'Num'};
%   * TagChoice: The name of choices in each tag
%       ÿ����ǩ��ѡ�������: 4 * 1 cell, each contains 1 * n cell ## ֻ���ĸ���ǩ����ѡ��
%       e.g. textTag = {{'Զ','��Զ','�ǳ�Զ','�ܽ�'}; {'˥����','˥������','˥���ܿ�','˥����'};...
%          {'��Ƶ�ź�','���ź�','��Ƶ�ź�','��Ƶ�ź�'};{'�޿����','�п����'}};
%   * RightChoice: The right answer of each tag
%       ÿ����ǩ����ȷѡ��: 5 * 1 matrix
%       e.g. rightChoiceIdx = [2;1;1;1;218];
%   Soundtype: �������ͣ�Ĭ��Ϊ 1
%       1�� 1 *.mat
%       2�� 2 *.wav, *.mp3����
%   Descriptions: ��������
%

function varargout = overview(varargin)
% OVERVIEW MATLAB code for overview.fig
%      OVERVIEW, by itself, creates a new OVERVIEW or raises the existing
%      singleton*.
%
%      H = OVERVIEW returns the handle to a new OVERVIEW or the handle to
%      the existing singleton*.
%
%      OVERVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OVERVIEW.M with the given input arguments.
%
%      OVERVIEW('Property','Value',...) creates a new OVERVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before overview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to overview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help overview

% Last Modified by GUIDE v2.5 08-Jul-2017 14:03:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @overview_OpeningFcn, ...
                   'gui_OutputFcn',  @overview_OutputFcn, ...
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


% --- Executes just before overview is made visible.
function overview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to overview (see VARARGIN)

global isexit;

isexit = 0;

% Choose default command line output for overview
handles.output = hObject;


%% function initialize_gui(fig_handle, isrenew, handles, varargin, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.


set(handles.PlaySound, 'Enable', 'on');
set(handles.Certify, 'Enable', 'on');
% Ϊ���ܹ�ֱ�����г���
RightChoice = [2;1;4;2;208];
TagName = {{'����' };{'˥��' };{'����' };{'�����'};{'����' }};
TagChoice = {{'Զ','��Զ','�ǳ�Զ','�ܽ�'}; {'˥����','˥������','˥���ܿ�','˥����'};...
    {'��Ƶ�ź�','���ź�','��Ƶ�ź�','��Ƶ�ź�'};{'�޿����','�п����'}};
SoundFile = 'SoundandVideo\��Ƶ1.wav';
VideoFile =  'SoundandVideo\��ͼ1.wav';
Descriptions = '����������Ϣ';
Soundtype = 2;

% ������������
for i = 1 : 2 : length(varargin)
    eval([varargin{i} '= varargin{i + 1};']);
end

% ����handles
handles.input.RightChoice = RightChoice;
handles.input.TagName = TagName;
handles.input.TagChoice = TagChoice;
handles.input.Soundtype = Soundtype;

% ���������ļ�
if Soundtype == 1
    handles.input.SoundFile = load(SoundFile);
    handles.input.SoundFile.fs = 40000;
else
    try
        [handles.input.SoundFile.y_all, handles.input.SoundFile.fs] = ...
            audioread(SoundFile);
    catch
        [handles.input.SoundFile.y_all, handles.input.SoundFile.fs] = ...
            wavread(SoundFile);
    end
end

% ��������ļ����
cutNum = 10;
Soundlength = length(handles.input.SoundFile.y_all);
startpointIdx = 1 : floor(Soundlength / cutNum) : Soundlength;
startpoint = randsample(startpointIdx, 1);
if startpoint ~= 1
    try
        handles.input.SoundFile.y_all = ...
            [handles.input.SoundFile.y_all(startpoint : end), ...
            handles.input.SoundFile.y_all(1 : startpoint - 1)];
    catch
        handles.input.SoundFile.y_all = ...
            [handles.input.SoundFile.y_all(startpoint : end); ...
            handles.input.SoundFile.y_all(1 : startpoint - 1)];
    end
end

% ������Ƶ���������Ҹ�������λ�õ������
input_video_file = VideoFile;
% Acquiring video
videoObject = load(input_video_file);
videoObject = videoObject.demon_lc_qd;
% Display first frame
axes(handles.axes1);
axis(handles.axes1,'off');

vstartpoint = ceil(startpoint / handles.input.SoundFile.fs);
handles.videoObject = [videoObject(vstartpoint : end, :); videoObject(1 : vstartpoint-1, :)];



% ������ɫ
handles.color.backcolor = [235 225 197] / 255;

handles.color.stopcolor = [174 218 231] / 255; % blue
handles.color.playcolor = [70 174 204] / 255; % light blue

handles.color.normalbordercolor = [190 196 199] / 255; % gray
handles.color.normalTextcolor = [0 0 0]; % black

handles.color.warningcolor = [232 96 72] / 255; % red

handles.color.wrongstopcolor = [242 160 146] / 255; % red
handles.color.wrongplaycolor = handles.color.warningcolor; % light red

handles.color.mycolor = [204 88 69] / 255; % dark red
handles.color.rightcolor = [59 155 183] / 255; % dark blue

handles.color.hovercolor = handles.color.rightcolor; % dark blue

% ��ʼ��һЩ��ɫ
set(handles.Certify, 'BackgroundColor', handles.color.hovercolor);
set(handles.Certify, 'ForegroundColor', [1 1 1]);

set(handles.IntroWord, 'ForegroundColor', [95 108 115] / 255);

% ��������������
set(handles.PlaySound, 'String', '��ͣ');
set(handles.PlaySound, 'BackgroundColor', handles.color.stopcolor);
handles.playing.player = ...
    audioplayer(handles.input.SoundFile.y_all, handles.input.SoundFile.fs);
blah.stopPlayback = false;
handles.playing.player.Userdata = blah;
handles.playing.player.stopfcn = @audioplayerLoopingStopFcn;
handles.playing.isstart = false;

% �����ź�����
play(handles.playing.player);
handles.playing.isstart = true;

for i = 1 : length(TagName)
    si = num2str(i);
    %���ñ�ǩ��
    eval(['set(handles.Tag' si ', ''Title'', TagName{i, 1});']);
    eval(['set(handles.Tag' si ', ''ForegroundColor'', handles.color.normalTextcolor);'])
    eval(['set(handles.Tag' si ', ''ShadowColor'', handles.color.normalbordercolor);'])
    if i <= length(TagChoice)        
        % �õ���Ҫ���ֵ�����
        PresentString = TagChoice{i}{RightChoice(i)};
        eval(['set(handles.Meaning_' si ', ''String'', PresentString);']);
    end
end
set(handles.Meaning_5, 'String', num2str(RightChoice(5)));


set(handles.textinformation, 'String', Descriptions);



% ��������ļ�
handles.choicedata.IsDone = 0;
handles.choicedata.isComplete = 1;

%%
% Update handles structure
guidata(hObject, handles);

% ������Ƶ
videoObject = handles.videoObject;

NT=15;
[m,n]=size(videoObject);
T=1:1:m;
f=(1:1:n)/NT;
i = 1;

while ~isexit
    if i <= m
        t=1:i;
        demon_lc(i,:)=videoObject(i,:);
    else
        t = 1 : m;
        demon_lc = demon_lc(2:end,:);
        if (mod(i,m))
            demon_lc(m,:) = videoObject(mod(i,m), :);
        else
            demon_lc(m,:) = videoObject(m, :);
        end
    end
    ptxs=flipud(demon_lc);
   
    imagesc(handles.axes1, f*60,t,ptxs);
    caxis(handles.axes1, [0 1]);
    xlim(handles.axes1, [1 3000]);
    ylim(handles.axes1, [0,m]);
%     xlabel(handles.axes1, 'ת��');
    ylabel(handles.axes1, 'ʱ��');
    
    imagesc(handles.axes2, f*60,t,ptxs);
    caxis(handles.axes2, [0 1]);
    xlim(handles.axes2, [1 3000]);
    ylim(handles.axes2, [0,m]);
    xlabel(handles.axes2, 'ת��');
    ylabel(handles.axes2, 'ʱ��');
    
    pause(1);%ÿ��ˢ��һ�Σ�ʱ����������
    i = i + 1;
end


% UIWAIT makes overview wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = overview_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% �˳�ǰֹͣ��������
if ~isempty(handles)
    if isplaying(handles.playing.player)
        set(handles.PlaySound, 'String', '����');
        set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
        blah.stopPlayback = true;
        handles.playing.player.Userdata = blah;
        stop(handles.playing.player);
        set(handles.PlaySound, 'Value', 1);
    end
    
    varargout{1} = handles.choicedata;
    varargout{2} = handles.figure1;
    
    initialize_gui(hObject, true, handles, {}, true);
    
    delete(handles.figure1);
else
    handles.choicedata.IsDone = 0;
    handles.choicedata.isComplete = 0;
    varargout{1} = handles.choicedata;
    varargout{2} = [];
end

% --------------------------------------------------------------------
function initialize_gui(fig_handle, isrenew, handles, varargin, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'choicedata') && ~isreset
    return;
end

if isrenew
    set(handles.PlaySound, 'Enable', 'inactive');
    set(handles.Certify, 'Enable', 'inactive');
    varargin = {};
    RightChoice = [2;1;1;1;218];
    TagName = {'';'';'';'';''};
    TagChoice = {{'','','',''}; {'','','',''};...
        {'','','',''};{'',''}};
    SoundFile = 'Sound_file\100_0.2_0_4000_flie.mat';
    Soundtype = 1;
    
    if isplaying(handles.playing.player)
        set(handles.PlaySound, 'String', '����');
        set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
        blah.stopPlayback = true;
        handles.playing.player.Userdata = blah;
        stop(handles.playing.player);
        set(handles.PlaySound, 'Value', 1);
    end
else
    set(handles.PlaySound, 'Enable', 'on');
    set(handles.Certify, 'Enable', 'on');
    % Ϊ���ܹ�ֱ�����г���
    RightChoice = [2;1;1;1;218];
    TagName = {'distance';'decay';'linefreq';'bandfreq';'Num'};
    TagChoice = {{'Զ','��Զ','�ǳ�Զ','�ܽ�'}; {'˥����','˥������','˥���ܿ�','˥����'};...
        {'��Ƶ�ź�','���ź�','��Ƶ�ź�','��Ƶ�ź�'};{'�޿����','�п����'}};
    SoundFile = 'Sound_file\100_0.2_0_4000_flie.mat';
    Soundtype = 1;
end

% ������������
for i = 1 : 2 : length(varargin)
    eval([varargin{i} '= varargin{i + 1};']);
end

% ����handles
handles.input.RightChoice = RightChoice;
handles.input.TagName = TagName;
handles.input.TagChoice = TagChoice;
handles.input.Soundtype = Soundtype;

if ~isrenew
    if Soundtype == 1
        handles.input.SoundFile = load(SoundFile);
        handles.input.SoundFile.fs = 40000;
    else
        try
            [handles.input.SoundFile.y_all, handles.input.SoundFile.fs] = ...
                audioread(SoundFile);
        catch
            [handles.input.SoundFile.y_all, handles.input.SoundFile.fs] = ...
                wavread(SoundFile);
        end
    end

    % ��������ļ����
    cutNum = 10;
    Soundlength = length(handles.input.SoundFile.y_all);
    startpointIdx = 1 : floor(Soundlength / cutNum) : Soundlength;
    startpoint = randsample(startpointIdx, 1);
    if startpoint ~= 1
        handles.input.SoundFile.y_all = ...
            [handles.input.SoundFile.y_all(startpoint : end), ...
            handles.input.SoundFile.y_all(1 : startpoint - 1)];
    end
    
    % ������ɫ
    handles.color.backcolor = [235 225 197] / 255;
    
    handles.color.stopcolor = [174 218 231] / 255; % blue
    handles.color.playcolor = [70 174 204] / 255; % light blue
    
    handles.color.normalbordercolor = [190 196 199] / 255; % gray
    handles.color.normalTextcolor = [0 0 0]; % black
    
    handles.color.warningcolor = [232 96 72] / 255; % red
    
    handles.color.wrongstopcolor = [242 160 146] / 255; % red
    handles.color.wrongplaycolor = handles.color.warningcolor; % light red
    
    handles.color.mycolor = [204 88 69] / 255; % dark red
    handles.color.rightcolor = [59 155 183] / 255; % dark blue
    
    handles.color.hovercolor = handles.color.rightcolor; % dark blue
    
    % ��ʼ��һЩ��ɫ
    set(handles.Certify, 'BackgroundColor', handles.color.hovercolor);
    set(handles.Certify, 'ForegroundColor', [1 1 1]);
    
    set(handles.IntroWord, 'ForegroundColor', [95 108 115] / 255);
    
    % ��������������
    set(handles.PlaySound, 'String', '��ͣ');
    set(handles.PlaySound, 'BackgroundColor', handles.color.stopcolor);
    handles.playing.player = ...
        audioplayer(handles.input.SoundFile.y_all, handles.input.SoundFile.fs);
    blah.stopPlayback = true;
    handles.playing.player.Userdata = blah;
    handles.playing.player.stopfcn = @audioplayerLoopingStopFcn;
    handles.playing.isstart = false;
    
    % �����ź�����
    play(handles.playing.player);
    handles.playing.isstart = true;
end



for i = 1 : length(TagName)
    si = num2str(i);
    %���ñ�ǩ��
    eval(['set(handles.Tag' si ', ''Title'', TagName{i, 1});']);
    eval(['set(handles.Tag' si ', ''ForegroundColor'', handles.color.normalTextcolor);'])
    eval(['set(handles.Tag' si ', ''ShadowColor'', handles.color.normalbordercolor);'])
    if i <= length(TagChoice)        
        % �õ���Ҫ���ֵ�����
        PresentString = TagChoice{i}{RightChoice(i)};
        eval(['set(handles.Meaning_' si ', ''String'', PresentString);']);
    end
end
if ~isrenew
    set(handles.Meaning_5, 'String', num2str(RightChoice(5)));
else
    set(handles.Meaning_5, 'String', '');
end

set(handles.textinformation, 'String', '����������Ϣ');

% Update handles structure
guidata(fig_handle, handles);


% --- Executes on button press in Certify.
function Certify_Callback(hObject, eventdata, handles)
% hObject    handle to Certify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global isexit
isexit = 1;
handles.choicedata.IsDone = 1;

if handles.choicedata.IsDone
    % ����ͣ��������
    PlayState = get(handles.PlaySound, 'Value');
    if ~PlayState
        set(handles.PlaySound, 'String', '����');
        set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
        blah.stopPlayback = true;
        handles.playing.player.Userdata = blah;
        pause(handles.playing.player);
        set(handles.PlaySound, 'Value', 1);
    end
end

% Update handles structure
guidata(handles.figure1, handles);
uiresume;



% --------------------------------------------------------------------
function uitoggletool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.choicedata.isComplete = 0;
PlayState = get(handles.PlaySound, 'Value');
if ~PlayState
    set(handles.PlaySound, 'String', '����');
    set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
    blah.stopPlayback = true;
    handles.playing.player.Userdata = blah;
    pause(handles.playing.player);
    set(handles.PlaySound, 'Value', 1);
end

guidata(handles.figure1, handles);
uiresume;



% --- Executes on button press in PlaySound.
function PlaySound_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlaySound

PlayState = get(hObject, 'Value');
if PlayState
    set(handles.PlaySound, 'String', '��ͣ');
    set(handles.PlaySound, 'BackgroundColor', handles.color.stopcolor);
    blah.stopPlayback = false;
    handles.playing.player.Userdata = blah;
    if handles.playing.isstart
        resume(handles.playing.player);
        uiresume;
    else
        play(handles.playing.player);
        handles.playing.isstart = true;
    end
else
    set(handles.PlaySound, 'String', '����');
    set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
    blah.stopPlayback = true;
    handles.playing.player.Userdata = blah;
    pause(handles.playing.player);
    uiwait;
end

% Update handles structure
guidata(handles.figure1, handles);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.choicedata.isComplete = 0;

% Update handles structure
guidata(handles.figure1, handles);

% --- Executes during object deletion, before destroying properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
