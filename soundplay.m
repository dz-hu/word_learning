% This code is created by Dingzhi Hu, 2017.7
% revised by Dingzhi Hu, 2020.12
% Anyone who wants to use this code, or the program has to be authorized!! 
%
% soundplay('SoundFile', soundfile, 'VideoFile', videofile, 'OtherChoiceFile', otherchoicefile,...
%   'TagName', tagName, 'TagChoice', textTag, 'RightChoice', rightChoiceIdx, ...
%   'Soundtype', soundtype);
%
% Var Definition: * 为必填项
%   * SoundFile, VideoFile: The file of sound of the signal;
%       信号声音文件的路径: string
%       e.g. soundfile = 'C:\auditory_learning\sound_learning\Sound_file\100_0.2_0_4000_flie.mat';
%   * OtherChoiceFile: The file of sound in the second choice
%       第二项每项声音对应的文件路径: 1 * 4 cell
%       e.g. otherchoiceFile = {'C:\Dingzhi_Profile\auditory_learning\sound_learning\Sound_file\100_0.2_0_4000_flie.mat', ...
%          'C:\Dingzhi_Profile\auditory_learning\sound_learning\Sound_file\100_0.2_0_4000_flie.mat', ...
%          'C:\Dingzhi_Profile\auditory_learning\sound_learning\Sound_file\100_0.2_0_4000_flie.mat', ...
%          'C:\Dingzhi_Profile\auditory_learning\sound_learning\Sound_file\100_0.2_0_4000_flie.mat'};
%   * TagName: The name of every tag
%       每项对应的名字: 5 * 1 cell
%       e.g. tagname = {'distance';'decay';'linefreq';'bandfreq';'Num'};
%   * TagChoice: The name of choices in each tag
%       每个标签中选项的名字: 4 * 1 cell, each contains 1 * n cell ## 只有四个标签能做选择
%       e.g. textTag = {{'远','很远','非常远','很近'}; {'衰减慢','衰减很慢','衰减很快','衰减快'};...
%          {'低频信号','无信号','中频信号','高频信号'};{'无宽带谱','有宽带谱'}};
%   * RightChoice: The right answer of each tag
%       每个标签的正确选项: 5 * 1 matrix
%       e.g. rightChoiceIdx = [2;1;1;1;218];
%   Soundtype: 声音类型，默认为 1
%       1） 1 *.mat
%       2） 2 *.wav, *.mp3……

function varargout = soundplay(varargin)
% SOUNDPLAY MATLAB code for soundplay.fig
%           

% Edit the above text to modify the response to help soundplay

% Last Modified by GUIDE v2.5 08-Jul-2017 11:27:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @soundplay_OpeningFcn, ...
                   'gui_OutputFcn',  @soundplay_OutputFcn, ...
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


% --- Executes just before soundplay is made visible.
function soundplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to soundplay (see VARARGIN)

global isexit
isexit = 0;

% Choose default command line output for soundplay
handles.output = hObject;

%% function initialize_gui(fig_handle, isrenew, handles, varargin, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.



set(handles.PlaySound, 'Enable', 'on');
set(handles.Certify, 'Enable', 'on');
set(handles.PlayWrongSound, 'Enable', 'on');
set(handles.NextOne, 'Enable', 'on');

% 为了能够直接运行程序
RightChoice = [2;1;1;1;218];
TagName = {'distance';'decay';'linefreq';'bandfreq';'Num'};
TagChoice = {{'远','很远','非常远','很近'}; {'衰减慢','衰减很慢','衰减很快','衰减快'};...
    {'低频信号','无信号','中频信号','高频信号'};{'无宽带谱','有宽带谱'}};
SoundFile = 'SoundandVideo/音频1.wav';
VideoFile = 'SoundandVideo/谱图1.mat';
OtherChoiceFile = {{'SoundandVideo\音频1.wav'}, ...
    {'SoundandVideo\音频1.wav'}, ...
    {'SoundandVideo\音频1.wav'}, ...
    {'SoundandVideo\音频1.wav'}};
Soundtype = 2;

% 读入输入数据
for i = 1 : 2 : length(varargin)
    eval([varargin{i} '= varargin{i + 1};']);
end

% 导入handles
handles.input.RightChoice = RightChoice;
handles.input.TagName = TagName;
handles.input.TagChoice = TagChoice;
handles.input.Soundtype = Soundtype;
handles.input.OtherChoiceFile = OtherChoiceFile;

% 读入声音文件
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

% 随机声音文件起点
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

% 建立视频播放器并且根据
input_video_file = VideoFile;
% Acquiring video
videoObject = load(input_video_file);
videoObject = videoObject.demon_lc_qd;
% Display first frame
axes(handles.axes1);
axis(handles.axes1,'off');

vstartpoint = ceil(startpoint / handles.input.SoundFile.fs);
handles.videoObject = [videoObject(vstartpoint : end, :); videoObject(1 : vstartpoint-1, :)];

% 设置颜色
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

% 初始化一些颜色
set(handles.Certify, 'BackgroundColor', handles.color.hovercolor);
set(handles.Certify, 'ForegroundColor', [1 1 1]);

set(handles.NextOne, 'BackgroundColor', handles.color.mycolor);
set(handles.NextOne, 'ForegroundColor', [1 1 1]);

set(handles.IntroWord, 'ForegroundColor', [95 108 115] / 255);

% 建立声音播放器
set(handles.PlaySound, 'String', '暂停');
set(handles.PlaySound, 'BackgroundColor', handles.color.stopcolor);
handles.playing.player = ...
    audioplayer(handles.input.SoundFile.y_all, handles.input.SoundFile.fs);
blah.stopPlayback = false;
handles.playing.player.Userdata = blah;
handles.playing.player.stopfcn = @audioplayerLoopingStopFcn;
handles.playing.isstart = false;

% 播放信号声音
play(handles.playing.player);
handles.playing.isstart = true;

% 建立错误声音播放器
handles.wrongplaying.isstart = false;

% 处理输出文件
handles.choicedata.MyChoice  = ones(length(RightChoice), 1) * -1;
handles.choicedata.IsDone = 0;
handles.choicedata.isComplete = 1;

% 隐藏播放错误选项
set(handles.WrongSound, 'visible', 'off');
set(handles.PlayWrongSound, 'visible', 'off');
set(handles.NextOne, 'visible', 'off');

% 隐藏标签五里面的回答
set(handles.Right_5_tit, 'visible', 'off');
set(handles.Right_5_ans, 'visible', 'off');
set(handles.My_5_tit, 'visible', 'off');
set(handles.My_5_ans, 'visible', 'off');

% 重设确认按钮（因为之前曾经隐藏
set(handles.Certify, 'visible', 'On');


for i = 1 : length(TagName)
    si = num2str(i);
    %设置标签名
    eval(['set(handles.Tag' si ', ''Title'', TagName{i, 1});']);
    eval(['set(handles.Tag' si ', ''ForegroundColor'', handles.color.normalTextcolor);'])
    eval(['set(handles.Tag' si ', ''ShadowColor'', handles.color.normalbordercolor);'])
    
    % 隐藏项目之前的反馈
    eval(['set(handles.Feedback' si ', ''visible'', ''off'');'])
    if (i < 5)
        eval(['set(handles.gou' si ', ''visible'', ''off'');'])
        eval(['set(handles.cha' si ', ''visible'', ''off'');'])
    end
    
    if i <= length(TagChoice)
        % 将选项全部设为第一个
        eval(['set(handles.Tag' si ', ''SelectedObject'', handles.radiobutton' si '_1);'])
        handles.choicedata.MyChoice(i) = 1;
        for j = 1 : length(TagChoice{i})
            sj = num2str(j);
            % 设置颜色和文字
            eval(['set(handles.radiobutton' si '_' sj ', ''String'', TagChoice{i}{j});']);
            eval(['set(handles.radiobutton' si '_' sj ', ''visible'', ''on'');']);
            eval(['set(handles.radiobutton' si '_' sj ', ''ForegroundColor'', [0 0 0]);']);
        end
        jj = j;
        if jj < 4
            for j = jj + 1 : 4
                sj = num2str(j);
                eval(['set(handles.radiobutton' si '_' sj ', ''visible'', ''off'');']);
            end
        end
    end
end

set(handles.Answer_5, 'String', '');
set(handles.Answer_5, 'ForegroundColor', [0 0 0]);

%%

% Update handles structure
guidata(hObject, handles);

% 播放视频
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
    xlabel(handles.axes1, '转速');
    ylabel(handles.axes1, '时间');
    
    imagesc(handles.axes2, f*60,t,ptxs);
    caxis(handles.axes2, [0 1]);
    xlim(handles.axes2, [1 3000]);
    ylim(handles.axes2, [0,m]);
    xlabel(handles.axes2, '转速');
    ylabel(handles.axes2, '时间');
    
    pause(1);%每秒刷新一次，时间自由设置
    i = i + 1;
end

% UIWAIT makes soundplay wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = soundplay_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if ~isempty(handles)
    % 退出前停止播放声音
    if isplaying(handles.playing.player)
        set(handles.PlaySound, 'String', '播放');
        set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
        blah.stopPlayback = true;
        handles.playing.player.Userdata = blah;
        stop(handles.playing.player);
        set(handles.PlaySound, 'Value', 1);
        
        uiwait();
    end
    
    if handles.wrongplaying.isstart
        if isplaying(handles.wrongplaying.player)
            set(handles.PlayWrongSound, 'String', '播放');
            set(handles.PlayWrongSound, 'BackgroundColor', handles.color.wrongplaycolor);
            blah.stopPlayback = true;
            handles.wrongplaying.player.Userdata = blah;
            stop(handles.wrongplaying.player);
            set(handles.PlayWrongSound, 'Value', 1);
        end
    end
    
    if handles.choicedata.isComplete == 0
        handles.choicedata.MyChoice(1 : 5) = -1;
    end
    
    varargout{1} = handles.choicedata;
    varargout{2} = handles.figure1;
    
    initialize_gui(hObject, true, handles, {}, true);
else
    handles.choicedata.MyChoice(1 : 5) = -1;
    handles.choicedata.isComplete = 0;
    varargout{1} = handles.choicedata;
    varargout{2} = [];    
end


% --- Executes when selected object is changed in Tag1.
function Tag1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Tag1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TagNum = 1;

a = get(hObject, 'String');
b = find(strcmp(handles.input.TagChoice{TagNum}, a));

handles.choicedata.MyChoice(TagNum)  = b;

% Update handles structure
guidata(handles.figure1, handles);


% --- Executes when selected object is changed in Tag2.
function Tag2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Tag2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TagNum = 2;

a = get(hObject, 'String');
b = find(strcmp(handles.input.TagChoice{TagNum}, a));

handles.choicedata.MyChoice(TagNum)  = b;

% Update handles structure
guidata(handles.figure1, handles);


% --- Executes when selected object is changed in Tag3.
function Tag3_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Tag3 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TagNum = 3;

a = get(hObject, 'String');
b = find(strcmp(handles.input.TagChoice{TagNum}, a));

handles.choicedata.MyChoice(TagNum)  = b;

% Update handles structure
guidata(handles.figure1, handles);


% --- Executes when selected object is changed in Tag4.
function Tag4_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Tag4 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TagNum = 4;

a = get(hObject, 'String');
b = find(strcmp(handles.input.TagChoice{TagNum}, a));

handles.choicedata.MyChoice(TagNum)  = b;

% Update handles structure
guidata(handles.figure1, handles);


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
    set(handles.PlayWrongSound, 'Enable', 'inactive');
    set(handles.NextOne, 'Enable', 'inactive');
    
    set(handles.IntroWord, 'String', '请听声音，并作选择',...
        'ForegroundColor', [0.3725    0.4235    0.4510]);
    
    varargin = {};
    RightChoice = [2;1;1;1;218];
    TagName = {'';'';'';'';''};
    TagChoice = {{'','','',''}; {'','','',''};...
        {'','','',''};{'',''}};
    SoundFile = 'C:\Dingzhi_Profile\auditory_learning\sound_learning\Sound_file\100_0.2_0_4000_flie.mat';
    OtherChoiceFile = {};
    Soundtype = 1;
    
    if isplaying(handles.playing.player)
        set(handles.PlaySound, 'String', '播放');
        set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
        blah.stopPlayback = true;
        handles.playing.player.Userdata = blah;
        stop(handles.playing.player);
        set(handles.PlaySound, 'Value', 1);
        uiwait();
    end
    
    if handles.wrongplaying.isstart
        if isplaying(handles.wrongplaying.player)
            set(handles.PlayWrongSound, 'String', '播放');
            set(handles.PlayWrongSound, 'BackgroundColor', handles.color.wrongplaycolor);
            blah.stopPlayback = true;
            handles.wrongplaying.player.Userdata = blah;
            stop(handles.wrongplaying.player);
            set(handles.PlayWrongSound, 'Value', 1);
            
        end
    end
else
    set(handles.PlaySound, 'Enable', 'on');
    set(handles.Certify, 'Enable', 'on');
    set(handles.PlayWrongSound, 'Enable', 'on');
    set(handles.NextOne, 'Enable', 'on');
    
     % 为了能够直接运行程序
     RightChoice = [2;1;1;1;218];
     TagName = {'distance';'decay';'linefreq';'bandfreq';'Num'};
     TagChoice = {{'远','很远','非常远','很近'}; {'衰减慢','衰减很慢','衰减很快','衰减快'};...
         {'低频信号','无信号','中频信号','高频信号'};{'无宽带谱','有宽带谱'}};
     SoundFile = 'Sound_file\100_0.2_0_4000_flie.mat';
     OtherChoiceFile = {'Sound_file\100_0.2_0_4000_flie.mat', ...
         'Sound_file\100_0.2_0_4000_flie.mat', ...
         'Sound_file\100_0.2_0_4000_flie.mat', ...
         'Sound_file\100_0.2_0_4000_flie.mat'};
     Soundtype = 1;
end

% 读入输入数据
for i = 1 : 2 : length(varargin)
    eval([varargin{i} '= varargin{i + 1};']);
end

% 导入handles
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
    handles.input.OtherChoiceFile = OtherChoiceFile;
    
    % 随机声音文件起点
    cutNum = 10;
    Soundlength = length(handles.input.SoundFile.y_all);
    startpointIdx = 1 : floor(Soundlength / cutNum) : Soundlength;
    startpoint = randsample(startpointIdx, 1);
    if startpoint ~= 1
        handles.input.SoundFile.y_all = ...
            [handles.input.SoundFile.y_all(startpoint : end), ...
            handles.input.SoundFile.y_all(1 : startpoint - 1)];
    end
    
    % 设置颜色
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
    
    % 初始化一些颜色
    set(handles.Certify, 'BackgroundColor', handles.color.hovercolor);
    set(handles.Certify, 'ForegroundColor', [1 1 1]);
    
    set(handles.NextOne, 'BackgroundColor', handles.color.mycolor);
    set(handles.NextOne, 'ForegroundColor', [1 1 1]);
    
    set(handles.IntroWord, 'ForegroundColor', [95 108 115] / 255);
    
    % 建立声音播放器
    set(handles.PlaySound, 'String', '暂停');
    set(handles.PlaySound, 'BackgroundColor', handles.color.stopcolor);
    handles.playing.player = ...
        audioplayer(handles.input.SoundFile.y_all, handles.input.SoundFile.fs);
    blah.stopPlayback = false;
    handles.playing.player.Userdata = blah;
    handles.playing.player.stopfcn = @audioplayerLoopingStopFcn;
    handles.playing.isstart = false;
    
    % 播放信号声音
    play(handles.playing.player);
    handles.playing.isstart = true;
    
    % 建立错误声音播放器
    handles.wrongplaying.isstart = false;
end

% 处理输出文件
handles.choicedata.MyChoice  = ones(length(RightChoice), 1) * -1;
handles.choicedata.IsDone = 0;
handles.choicedata.isComplete = 1;

% 隐藏播放错误选项
set(handles.WrongSound, 'visible', 'off');
set(handles.PlayWrongSound, 'visible', 'off');
set(handles.NextOne, 'visible', 'off');

% 隐藏标签五里面的回答
set(handles.Right_5_tit, 'visible', 'off');
set(handles.Right_5_ans, 'visible', 'off');
set(handles.My_5_tit, 'visible', 'off');
set(handles.My_5_ans, 'visible', 'off');

% 重设确认按钮（因为之前曾经隐藏
set(handles.Certify, 'visible', 'On');


for i = 1 : length(TagName)
    si = num2str(i);
    %设置标签名
    eval(['set(handles.Tag' si ', ''Title'', TagName{i, 1});']);
    eval(['set(handles.Tag' si ', ''ForegroundColor'', handles.color.normalTextcolor);'])
    eval(['set(handles.Tag' si ', ''ShadowColor'', handles.color.normalbordercolor);'])
    
    % 隐藏项目之前的反馈
    eval(['set(handles.Feedback' si ', ''visible'', ''off'');'])
    if (i < 5)
        eval(['set(handles.gou' si ', ''visible'', ''off'');'])
        eval(['set(handles.cha' si ', ''visible'', ''off'');'])
    end
    
    if i <= length(TagChoice)
        % 将选项全部设为第一个
        eval(['set(handles.Tag' si ', ''SelectedObject'', handles.radiobutton' si '_1);'])
        handles.choicedata.MyChoice(i) = 1;
        for j = 1 : length(TagChoice{i})
            sj = num2str(j);
            % 设置颜色和文字
            eval(['set(handles.radiobutton' si '_' sj ', ''String'', TagChoice{i}{j});']);
            eval(['set(handles.radiobutton' si '_' sj ', ''visible'', ''on'');']);
            eval(['set(handles.radiobutton' si '_' sj ', ''ForegroundColor'', [0 0 0]);']);
        end
        jj = j;
        if jj < 4
            for j = jj + 1 : 4
                sj = num2str(j);
                eval(['set(handles.radiobutton' si '_' sj ', ''visible'', ''off'');']);
            end
        end
    end
end

set(handles.Answer_5, 'String', '');
set(handles.Answer_5, 'ForegroundColor', [0 0 0]);

% Update handles structure
guidata(handles.figure1, handles);


% --- Executes on button press in Certify.
function Certify_Callback(hObject, eventdata, handles)
% hObject    handle to Certify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global isexit

answer5 = get(handles.Answer_5, 'String');
set(handles.Tag5, 'ShadowColor', handles.color.normalbordercolor);
if isempty(answer5)
    set(handles.Answer_5, 'String', '请输入数值后再按确认按钮！');
    set(handles.Answer_5, 'ForegroundColor', handles.color.warningcolor);
    set(handles.Tag5, 'ShadowColor', handles.color.warningcolor);
else
    if isnan(str2double(answer5))
        set(handles.Answer_5, 'String', '请输入正确的数值！');
        set(handles.Answer_5, 'ForegroundColor', handles.color.warningcolor);
        set(handles.Tag5, 'ShadowColor', handles.color.warningcolor);
    else
        handles.choicedata.MyChoice(5) = str2double(answer5);
        handles.choicedata.IsDone = 1;
    end
end

if handles.choicedata.IsDone
   for ii = 1 : 4
       TagNum = ii;
       sTagNum = num2str(TagNum);
       eval(['hChoice = get(handles.Tag' sTagNum ', ''SelectedObject'');']);
       a = get(hChoice, 'String');
       b = find(strcmp(handles.input.TagChoice{TagNum}, a));
       
       handles.choicedata.MyChoice(TagNum)  = b;
   end  
     % 先暂停播放声音
    PlayState = get(handles.PlaySound, 'Value');
    if ~PlayState
        set(handles.PlaySound, 'String', '播放');
        set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
        blah.stopPlayback = true;
        handles.playing.player.Userdata = blah;
        pause(handles.playing.player);
        set(handles.PlaySound, 'Value', 1);
        uiwait();
    end
    
    % 获得行为数据
    RightChoice = handles.input.RightChoice;
    MyChoice = handles.choicedata.MyChoice;
    
    biaoPosition = [17 38 58 79];
    
    for i = 1 : 4
        si = num2str(i);
        j = RightChoice(i); sj = num2str(j);
        eval(['set(handles.radiobutton' si '_' sj ', ''ForegroundColor'', handles.color.rightcolor);']);
        mj = MyChoice(i); smj = num2str(mj);
        if mj ~= j
            % 如果选错
            eval(['set(handles.radiobutton' si '_' smj ', ''ForegroundColor'', handles.color.mycolor);']);
            
            eval(['set(handles.gou' si ', ''visible'', ''on'');'])
            try
                eval(['set(handles.gou' si ', ''InnerPosition'', [biaoPosition(j) 0.875 8 1.571]);'])
            catch
                eval(['set(handles.gou' si ', ''Position'', [biaoPosition(j) 0.875 8 1.571]);'])
            end
            eval(['set(handles.gou' si ', ''ForegroundColor'', handles.color.rightcolor);'])
            
            eval(['set(handles.cha' si ', ''visible'', ''on'');'])
            
            try
                eval(['set(handles.cha' si ', ''InnerPosition'', [biaoPosition(mj) 0.875 8 1.571]);'])
            catch
                eval(['set(handles.cha' si ', ''Position'', [biaoPosition(mj) 0.875 8 1.571]);'])
            end
            eval(['set(handles.cha' si ', ''ForegroundColor'', handles.color.mycolor);'])
            
%             eval(['set(handles.Feedback' si ', ''visible'', ''on'');'])
%             eval(['set(handles.Feedback' si ', ''String'', ''错误'');'])
%             eval(['set(handles.Feedback' si ', ''ForegroundColor'', handles.color.mycolor);'])
            
            eval(['set(handles.Tag' si ', ''ForegroundColor'', handles.color.mycolor);'])
            eval(['set(handles.Tag' si ', ''ShadowColor'', handles.color.mycolor);'])
            % 加上重新播放的东西
            if i == 2
                set(handles.WrongSound, 'visible', 'on');
                set(handles.PlayWrongSound, 'visible', 'on');
                set(handles.PlayWrongSound, 'BackgroundColor', handles.color.wrongplaycolor);
                set(handles.WrongSound, 'ForegroundColor', handles.color.warningcolor);
            end
        else
            
            eval(['set(handles.gou' si ', ''visible'', ''on'');'])
            
            try
                eval(['set(handles.gou' si ', ''InnerPosition'', [biaoPosition(j) 0.875 8 1.571]);'])
            catch
                eval(['set(handles.gou' si ', ''Position'', [biaoPosition(j) 0.875 8 1.571]);'])
            end
            eval(['set(handles.gou' si ', ''ForegroundColor'', handles.color.rightcolor);'])
%             
%             eval(['set(handles.Feedback' si ', ''visible'', ''on'');'])
%             eval(['set(handles.Feedback' si ', ''String'', ''正确'');'])
%             eval(['set(handles.Feedback' si ', ''ForegroundColor'', handles.color.rightcolor);'])
        end
    end
    
    j = RightChoice(5);
    mj = MyChoice(5);
    
    errorj = abs(j - mj) / j;
    
    if errorj <= 0.1
        sj = num2str(j); smj = num2str(mj);
        
        % 清空标签五内的输入
%         set(handles.Answer_5, 'String', '');
        
        % 设置反馈
        set(handles.Feedback5, 'Visible', 'on');
        set(handles.Feedback5, 'String', '正确');
        set(handles.Feedback5, 'ForegroundColor', handles.color.rightcolor);
        
        % 显示正确答案和输入答案
%         set(handles.Right_5_tit, 'visible', 'on');
%         
%         set(handles.Right_5_ans, 'visible', 'on');
%         set(handles.Right_5_ans, 'ForegroundColor', handles.color.rightcolor);
%         set(handles.Right_5_ans, 'String', sj);
        
%         set(handles.My_5_tit, 'visible', 'on');
%         
%         set(handles.My_5_ans, 'visible', 'on');
%         set(handles.My_5_ans, 'ForegroundColor', handles.color.rightcolor);
%         set(handles.My_5_ans, 'String', smj);
    else
        sj = num2str(j); smj = num2str(mj);
        
        % 清空标签五内的输入
%         set(handles.Answer_5, 'String', '');
        
        % 设置反馈
        set(handles.Feedback5, 'Visible', 'on');
        set(handles.Feedback5, 'String', '错误');
        set(handles.Feedback5, 'ForegroundColor', handles.color.mycolor);
        
        set(handles.Tag5, 'ForegroundColor', handles.color.mycolor);
        set(handles.Tag5, 'ShadowColor', handles.color.mycolor);
        
        % 显示正确答案和输入答案
        set(handles.Right_5_tit, 'visible', 'on');
        
        set(handles.Right_5_ans, 'visible', 'on');
        set(handles.Right_5_ans, 'ForegroundColor', handles.color.rightcolor);
        set(handles.Right_5_ans, 'String', sj);
        
%         set(handles.My_5_tit, 'visible', 'on');
%         
%         set(handles.My_5_ans, 'visible', 'on');
%         set(handles.My_5_ans, 'ForegroundColor', handles.color.mycolor);
%         set(handles.My_5_ans, 'String', smj);
    end
    
    set(handles.IntroWord, 'String', '反馈',...
        'ForegroundColor', [0.8    0.4235    0.4510]);
    % 出现下一个的按钮
    set(handles.NextOne, 'visible', 'on');
    set(handles.NextOne, 'Position', [94 1.8 25.125 2.5]);
    set(handles.Certify, 'visible', 'off');
    beep;
    
    isexit = 1;
end

% Update handles structure
guidata(handles.figure1, handles);



function Answer_5_Callback(hObject, eventdata, handles)
% hObject    handle to Answer_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Answer_5 as text
%        str2double(get(hObject,'String')) returns contents of Answer_5 as a double


% --- Executes during object creation, after setting all properties.
function Answer_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Answer_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uitoggletool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.choicedata.isComplete = 0;
guidata(handles.figure1, handles);
uiresume;




% --- Executes on key press with focus on Answer_5 and none of its controls.
function Answer_5_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Answer_5 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
answer5 = get(handles.Answer_5, 'String');
if ~isempty(answer5)
    set(handles.Answer_5, 'ForegroundColor', [0 0 0]);
    set(handles.Tag5, 'ShadowColor', handles.color.normalbordercolor);
    set(handles.Answer_5, 'String', '');
end


% --- Executes on button press in PlaySound.
function PlaySound_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlaySound

% 先暂停播放之前的声音(只有当这个声音曾经播放过，才能执行这一步）
if handles.wrongplaying.isstart
    PlayState = get(handles.PlayWrongSound, 'Value');
    if ~PlayState
        set(handles.PlayWrongSound, 'String', '播放');
        set(handles.PlayWrongSound, 'BackgroundColor', handles.color.wrongplaycolor);
        blah.stopPlayback = true;
        handles.wrongplaying.player.Userdata = blah;
        pause(handles.wrongplaying.player);
        set(handles.PlayWrongSound, 'Value', 1);
    end
end

PlayState = get(hObject, 'Value');
if PlayState
    set(handles.PlaySound, 'String', '暂停');
    set(handles.PlaySound, 'BackgroundColor', handles.color.stopcolor);
    blah.stopPlayback = false;
    handles.playing.player.Userdata = blah;
    if handles.playing.isstart
        resume(handles.playing.player);
        uiresume();
    else
        play(handles.playing.player);
        handles.playing.isstart = true;
        uiresume();
    end
else
    set(handles.PlaySound, 'String', '播放');
    set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
    blah.stopPlayback = true;
    handles.playing.player.Userdata = blah;
    pause(handles.playing.player);
    uiwait();
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


% --- Executes on button press in PlayWrongSound.
function PlayWrongSound_Callback(hObject, eventdata, handles)
% hObject    handle to PlayWrongSound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlayWrongSound

% 先暂停播放之前的声音(只有当这个声音曾经播放过，才能执行这一步）
if handles.playing.isstart
    PlayState = get(handles.PlaySound, 'Value');
    if PlayState
        set(handles.PlaySound, 'String', '播放');
        set(handles.PlaySound, 'BackgroundColor', handles.color.playcolor);
        blah.stopPlayback = true;
        handles.playing.player.Userdata = blah;
        pause(handles.playing.player);
        set(handles.PlaySound, 'Value', 0);
        uiwait();
    end
end

PlayState = get(hObject, 'Value');
if ~PlayState
    set(handles.PlayWrongSound, 'String', '暂停');
    set(handles.PlayWrongSound, 'BackgroundColor', handles.color.wrongstopcolor);
    if handles.wrongplaying.isstart
        % 如果已经播放过了
        blah.stopPlayback = true;
        handles.wrongplaying.player.Userdata = blah;
        resume(handles.wrongplaying.player);
    else
        % 如果从未播放，那么新建声音文件
        mj = handles.choicedata.MyChoice(2);
        
        % 导入错误选项的声音
        if handles.input.Soundtype == 1
            WrongSound = load(handles.input.OtherChoiceFile{mj}{1});
            WrongSound.fs = 40000;
        else
            try
                [WrongSound.y_all, WrongSound.fs] = ...
                    audioread(handles.input.OtherChoiceFile{mj}{1});
            catch
                [WrongSound.y_all, WrongSound.fs] = ...
                    wavread(handles.input.OtherChoiceFile{mj}{1});
            end
        end
       
        
        % 随机声音文件起点
        cutNum = 10;
        Soundlength = length(WrongSound.y_all);
        startpointIdx = 1 : floor(Soundlength / cutNum) : Soundlength;
        startpoint = randsample(startpointIdx, 1);
        if startpoint ~= 1
            try
                WrongSound.y_all = ...
                    [WrongSound.y_all(startpoint : end), ...
                    WrongSound.y_all(1 : startpoint - 1)];
            catch
                
                WrongSound.y_all = ...
                    [WrongSound.y_all(startpoint : end); ...
                    WrongSound.y_all(1 : startpoint - 1)];
            end
        end
        
        % 建立错误声音播放器
        handles.wrongplaying.player = ...
            audioplayer(WrongSound.y_all, WrongSound.fs);
        blah.stopPlayback = false;
        handles.wrongplaying.player.Userdata = blah;
        handles.wrongplaying.player.stopfcn = @audioplayerLoopingStopFcn;
        
        % 播放错误声音
        play(handles.wrongplaying.player);
        handles.wrongplaying.isstart = true;
    end
else
    set(handles.PlayWrongSound, 'String', '播放');
    set(handles.PlayWrongSound, 'BackgroundColor', handles.color.wrongplaycolor);
    if handles.wrongplaying.isstart
        blah.stopPlayback = true;
        handles.wrongplaying.player.Userdata = blah;
        pause(handles.wrongplaying.player);
    end;
end;

% Update handles structure
guidata(handles.figure1, handles);


% --- Executes on button press in NextOne.
function NextOne_Callback(hObject, eventdata, handles)
% hObject    handle to NextOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;

% --- Executes during object deletion, before destroying properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
