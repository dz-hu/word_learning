function [] = PlayGame_Learning(subName, group, signalNum, minGroupnum)
% 信号识别训练，每天学习signalNum个信号，分为2个小组
% PlayGame_Learning(subName, group, signalNum)
% subName = 'test';
% group = 1;
% signalNum = 20;

%   Created by Diana, Hu, 2017.6.1
%   Updated by Xinyu Xie, 2017.7.10

t1 = GetSecs;
%% 检查是否有输入Name和signal number，如果没有输入报错
if isempty(subName)
    h = errordlg('请输入姓名！','错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',10);
    error('Please Enter your NAME!')
end

if isempty(signalNum)
    h = errordlg('请输入本次学习的信号总数！','错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',10);
    error('Please Enter the signal numeber!')
end

%% 参数设置
P.maxTimes = 2;  %% 每个小组每个信号最多出现多少次,8
P.minTimes = 1;  %% 每个小组每个信号最少出现多少次,5
P.ReviewTimes = 2;  %% 每个大组每个信号出现次数,3
P.RightTimes = 1;  %% 每个信号连续多少次达到ScoreBound可以通过，适用于GameType = New & Old,3
P.maxCorrTimes = 1; %% 每个信号总共多少次达到ScoreBound可以通过，适用于GameType = Rev,2

P.ScoreBound = 90; % 答对的分数标准
P.TagWeight = [0 80 0 10 10]';  % 标签权重
P.impTagNum = 2; % 重要的标签编号

SoundType = 2;  % 播放声音的方式，1对应.mat文件，2对于其他音频文件
minGroupnum = minGroupnum; % 最少分组数目，小于次数目则不分组学习信号 在Welcom Line 62 修改

%% 导入信号列表
ListFielName = fullfile(pwd, 'Process_data', 'signal_list');
load(ListFielName);

% 测试的记忆标签数量
tagNum = length(fieldnames(TagList)) - 4;  %5个

%% 数据存储
% 导入被试信息
SubjectFilePath = fullfile(pwd, 'Subject', subName);
SubjectFileName = fullfile(SubjectFilePath, 'BasicInfo');

%  如果没有被试信息，新建被试信息
try
    load(SubjectFileName);
catch
    mkdir(SubjectFilePath);
    Sub.Inform.Id = subName;
    Sub.Inform.n = TagList.n; % 被试信息中对应的信号数目
    Sub.Inform.ConfusionMat = []; % 每个信号再次出现的权重
    Sub.Inform.IsOld = ones(1, Sub.Inform.n)*-1; % 这个信号是否是新信号,-1表示还没学，1表示已学会，0表示还未学会
    Sub.Inform.Day = 1;  % 学习的天数
    Sub.Inform.isFinish = 1; % 如果中间退出，将该值赋为0
    Sub.Inform.currDate = date; % 当前时间，用于判断是否是第二天
    Sub.Inform.LastGroup = [Sub.Inform.Day, 1];
    save(SubjectFileName, 'Sub');
end

if ~strcmp(date, Sub.Inform.currDate)
    Sub.Inform.Day = Sub.Inform.Day +1 ;  % 学习的天数
end


% 检查之前大组是否学完
reviewDay = Sub.Inform.Day;
while ~isfield(Sub, ['D' num2str(reviewDay)])
    if reviewDay <= 1
        break;
    end
    reviewDay = reviewDay - 1;
end

reviewDayName = num2str(reviewDay);
if reviewDay ~=  Sub.Inform.Day && ~isfield(eval(['Sub.D' num2str(reviewDay)]), 'IsOld')
     errstr = '前一大组未学完，继续前一大组的学习';
     h = errordlg(errstr,'确认');
     ha = get(h,'children');
     ht = findall(ha,'type','text');
     set(ht,'fontsize',8);
     Sub.Inform.Day = reviewDay;
     eval(sprintf('Sub.Inform.currDate = Sub.D%d.date;', reviewDay));
end
%% 如果是之前未分组，则进行分组
if ~isfield(Sub, ['D' num2str(Sub.Inform.Day)]) || (isfield(Sub, ['D' num2str(Sub.Inform.Day)]) && ~isfield(eval(['Sub.D' num2str(Sub.Inform.Day)]), 'groupIdx') )
    
    numGroup = 2;  %% 把所有信号分成两组
    if signalNum < minGroupnum  %% 如果信号数小于n个，则只分为一组
        numGroup = 1;
    end
    numSig_Group(1) = round(signalNum/numGroup); % 第一组的信号数
    numSig_Group(2) = signalNum - numSig_Group(1);% 第二组的信号数
    
    temp = randperm(signalNum);
    groupIdx{1} = temp(1:numSig_Group(1));
    groupIdx{2} = temp(numSig_Group(1)+1:end);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.groupIdx = groupIdx;']);
    
    lastDay = Sub.Inform.Day - 1;
    if lastDay == 0  % 如果当前是第一天,则从所有信号中选择signalNum作为新信号
        signalIdx = 1:signalNum;
    else  % 如果当前不是第一天，则先将过去未学会的信号加入本次学习的信号列表
        signalIdx_old = find(Sub.Inform.IsOld == 0);
        new_idx = find(Sub.Inform.IsOld == -1);
        signalIdx_new = new_idx(1:signalNum-length(signalIdx_old));
        signalIdx = [signalIdx_old signalIdx_new];
    end
    
    SignalList_Group = SignalList(1, signalIdx);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.SignalList_Group = SignalList_Group;']);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.GAll.signalList = SignalList_Group;']);
    
    % 每组的信号
    for i = 1:numGroup
        temp_SignalList = SignalList_Group(groupIdx{i});
        eval(['Sub.D' num2str(Sub.Inform.Day) '.G' num2str(i) '.signalList = temp_SignalList;']);
    end
    
else
    eval(['groupIdx = Sub.D' num2str(Sub.Inform.Day) '.groupIdx;']);
    eval(['SignalList_Group = Sub.D' num2str(Sub.Inform.Day) '.SignalList_Group;']);
    
end

%% ****** 是否要继续上次的任务
selectOld = 0;

if Sub.Inform.isFinish == 0
    lastDay = Sub.Inform.LastGroup{1};
    lastGroup = Sub.Inform.LastGroup{2};
    
    button = questdlg('上一次的学习任务还未完成，请继续上次的学习','提示','确定','取消','确定');
    
    if strcmp(button, '确定')
        selectOld = 1;
        eval(['Curr_SignalList = Sub.D' lastDay '.G' lastGroup '.signalList;']);
        eval(['P.SigSeq = Sub.D' lastDay '.G' lastGroup '.SigSeq;']);
        eval(['P.ScoreSeq = Sub.D' lastDay '.G' lastGroup '.ScoreSeq;']);
        eval(['P.ResponseSeq = Sub.D' lastDay '.G' lastGroup '.ResponseSeq;']);
        eval(['P.IsLearned = Sub.D' lastDay '.isLearned;']);
        eval(['groupIdx = Sub.D' lastDay '.groupIdx;']);
        group = lastGroup;
        P.IsLearned = P.IsLearned(groupIdx{str2double(group)});

    elseif strcmp(button, '取消')
        error('Aborted by Users');
    end
end

%% 当前信号列表
if  selectOld
    eval(['Curr_SignalList = Sub.D' num2str(lastDay) '.G' num2str(lastGroup) '.signalList;']);
else
    if strcmp(group, 'All')
        Curr_SignalList = SignalList_Group;
    else
        Curr_SignalList = SignalList_Group(groupIdx{str2double(group)});
    end
end

numSig = size(Curr_SignalList, 2);
for s = 1:numSig
    curr_signalIdx(s) = Curr_SignalList(1, s).Index;
end

%% 检查每个小组是否有学习
if isfield(eval(['Sub.D' num2str(Sub.Inform.Day)]), 'isLearned')
    eval(['isLearned = Sub.D' num2str(Sub.Inform.Day) '.isLearned;']);
else
    isLearned = zeros(1,signalNum);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.isLearned = isLearned;']);
end

if strcmp(group, 'All')
    if  isLearned == 1
        GameType = 'Rev';
    else
        h = errordlg('所选大组信号尚未学完，请选择小组开始学习','错误');
        ha = get(h,'children');
        ht = findall(ha,'type','text');
        set(ht,'fontsize',8);
        error('Not finish learning')
    end
else
    eval(sprintf('GAlldata = Sub.D%d.GAll;', Sub.Inform.Day));
    if sum(isLearned) == length(isLearned) && isfield(GAlldata, 'ScoreSeq')
        button = questdlg('前面已学完一大组，是否进行新的学习','提示','确定','取消','确定');
        
        if strcmp(button, '确定')
            Sub.Inform.Day = Sub.Inform.Day +1 ;  % 学习的天数
            
            % 重新分组
            
            numGroup = 2;  %% 把所有信号分成两组
            if signalNum < minGroupnum  %% 如果信号数小于n个，则只分为一组
                numGroup = 1;
            end
            numSig_Group(1) = round(signalNum/numGroup); % 第一组的信号数
            numSig_Group(2) = signalNum - numSig_Group(1);% 第二组的信号数
            
            temp = randperm(signalNum);
            groupIdx{1} = temp(1:numSig_Group(1));
            groupIdx{2} = temp(numSig_Group(1)+1:end);
            eval(['Sub.D' num2str(Sub.Inform.Day) '.groupIdx = groupIdx;']);
            
            lastDay = Sub.Inform.Day - 1;
            if lastDay == 0  % 如果当前是第一天,则从所有信号中选择signalNum作为新信号
                signalIdx = 1:signalNum;
            else  % 如果当前不是第一天，则先将过去未学会的信号加入本次学习的信号列表
                signalIdx_old = find(Sub.Inform.IsOld == 0);
                new_idx = find(Sub.Inform.IsOld == -1);
                signalIdx_new = new_idx(1:signalNum-length(signalIdx_old));
                signalIdx = [signalIdx_old signalIdx_new];
            end
            
            SignalList_Group = SignalList(1, signalIdx);
            eval(['Sub.D' num2str(Sub.Inform.Day) '.SignalList_Group = SignalList_Group;']);
            eval(['Sub.D' num2str(Sub.Inform.Day) '.GAll.signalList = SignalList_Group;']);
            
            % 每组的信号
            for i = 1:numGroup
                temp_SignalList = SignalList_Group(groupIdx{i});
                eval(['Sub.D' num2str(Sub.Inform.Day) '.G' num2str(i) '.signalList = temp_SignalList;']);
            end
            
            Curr_SignalList = SignalList_Group(groupIdx{str2double(group)});
            GameType = 'New';
        else
            h = errordlg('所选大组已经完成学习，请休息！','错误');
            ha = get(h,'children');
            ht = findall(ha,'type','text');
            set(ht,'fontsize',8);
            error('Already learned')
        end
    elseif  sum(isLearned(groupIdx{str2double(group)}) ~= 1)==0 && selectOld == 0
        h = errordlg('所选小组已经完成学习，请选择新的小组','错误');
        ha = get(h,'children');
        ht = findall(ha,'type','text');
        set(ht,'fontsize',8);
        error('Already learned')
    elseif sum(isLearned(groupIdx{str2double(group)}) ~= 1)==0 && selectOld == 1
        GameType = 'Old';
    else
        GameType = 'New';
    end
end

%% %%%%%%%进入主程序%%%%%%%%%%%%%%%%
[SigSeq, ScoreSeq, ResponseSeq, ConfusionMat, isLearned, IsOld, isFinish] = ...
    SoundLearning_gui(Curr_SignalList, TagList, tagNum, GameType, selectOld, SoundType, P);


%% 保存数据
t2 = GetSecs;

timep = t2-t1;
if isempty(Sub.Inform.ConfusionMat) 
    Sub.Inform.ConfusionMat = ConfusionMat;
elseif  size(Sub.Inform.ConfusionMat, 1) ~= size(ConfusionMat, 1)
    errordlg('信号列表发生改变，请检查！此次数据不保存', '确定');
else
    Sub.Inform.ConfusionMat = Sub.Inform.ConfusionMat + ConfusionMat;
end
Sub.Inform.LastGroup = {num2str(Sub.Inform.Day), group};

if strcmp(group, 'All')
    Sub.Inform.IsOld(1, curr_signalIdx) = IsOld;
    eval(['Sub.D' num2str(Sub.Inform.Day) '.IsOld = IsOld;']);
else
    eval(['Sub.D' num2str(Sub.Inform.Day) '.isLearned(groupIdx{str2double(group)}) = isLearned;']);
end

Sub.Inform.isFinish = isFinish;
Sub.Inform.currDate = date;

if isfield(Sub.Inform, 'totalTime')
    Sub.Inform.totalTime =[Sub.Inform.totalTime timep];
    Sub.Inform.totalAcc = [Sub.Inform.totalAcc mean(Sub.Inform.IsOld > 0)];
else
    Sub.Inform.totalTime = timep;
    Sub.Inform.totalAcc = mean(Sub.Inform.IsOld > 0);
end

eval(['Sub.D' num2str(Sub.Inform.Day) '.date = date;']);
eval(['Sub.D' num2str(Sub.Inform.Day) '.G' group '.SigSeq = SigSeq;']);
eval(['Sub.D' num2str(Sub.Inform.Day) '.G' group '.ScoreSeq = ScoreSeq;']);
eval(['Sub.D' num2str(Sub.Inform.Day) '.G' group '.ResponseSeq = ResponseSeq;']);

save(SubjectFileName, 'Sub');

%% 结果作图
if isFinish
    PlotFigure('subName', subName, 'group', group, 'DayName', Sub.Inform.Day, ...
        'SigSeq', SigSeq, 'ScoreSeq', ScoreSeq, 'signalIdx', curr_signalIdx, ...
        'IsOld', IsOld);
end