function [] = PlayGame_Review(subName, backDay, signalNum)
% 信号识别复习
% 输入:
%   subName:被试姓名
%   backDay:复习时间，如果=3，表示从所有已学信号中随机选择
%   signalNum：复习信号数目，只对backDay=3有用

%       Created by Xinyu Xie, 2017.7.10


%% 检查是否有输入Name和signal number，如果没有输入报错
if isempty(subName)
    h = errordlg('请输入姓名！','错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',10);
    error('Please Enter your NAME!')
end

%% 参数设置
P.ReviewTimes = 1;

P.ScoreBound = 90; % 答对的分数标准  90
P.TagWeight = [20 20 20 20 20]';  % 标签权重 [20 20 20 20 20]'
P.impTagNum = 2; % 重要的标签编号 2

SoundType = 2;  % 播放声音的方式，1对应.mat文件，2对于其他音频文件

if backDay == 3
    reviewDayName = 'Rand';
    type = 1;
else
    type = 2;
end

%% 导入信号列表
ListFileName = fullfile(pwd, 'Process_data', 'signal_list');
load(ListFileName);

% 测试的记忆标签数量
tagNum = 5;  % 5个

%% 数据存储
% 导入被试信息
SubjectFilePath = fullfile(pwd, 'Subject', subName);
SubjectFileName = fullfile(SubjectFilePath, 'BasicInfo');

%  如果没有被试信息，报错
try
    load(SubjectFileName)
catch
    h = errordlg('该被试的信息不存在！','错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',8);
    error('No information');
end

if ~strcmp(date, Sub.Inform.currDate)
    Sub.Inform.Day = Sub.Inform.Day +1 ;  % 学习的天数
end

if type == 2
    reviewDay = Sub.Inform.Day;
    while ~isfield(Sub, ['D' num2str(reviewDay)])
        reviewDay = reviewDay - 1;
    end
    reviewDay = reviewDay - backDay + 1;
    reviewDayName = num2str(reviewDay);
else
    reviewDay =  Sub.Inform.Day - 1;
end

if reviewDay <= 0
    if type == 2
        errstr = [num2str(backDay) '次前的信息不存在，请选择正确的复习时间!'];
    else
        errstr ='尚未学习新的信号，请先开始学习！';
    end
    h = errordlg(errstr,'错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',8);
    error('Wrong review day');
end

if type == 2
    if isfield(Sub, ['D' num2str(Sub.Inform.Day)])
        if isfield(eval(['Sub.D' num2str(Sub.Inform.Day)]), ['R' reviewDayName])
            errstr = ['第' reviewDayName '次的信号已复习，请选择新的复习时间!'];
            h = errordlg(errstr,'错误');
            ha = get(h,'children');
            ht = findall(ha,'type','text');
            set(ht,'fontsize',8);
            error('Already reviewed');
        end
    end
end

%% 导入复习信号
if type == 2
    eval(['SignalList_Group = Sub.D' num2str(reviewDay) '.SignalList_Group;']);
    if isfield(eval(['Sub.D' num2str(reviewDay)]), 'IsOld')
        eval(['OldList = Sub.D' num2str(reviewDay) '.IsOld;']);
        sigIdx =1;
        Curr_SignalList = SignalList_Group(1, OldList == 1);
    else
        errstr = [num2str(backDay) '天前的学习任务未完成，请选择新的复习时间!'];
        h = errordlg(errstr,'错误');
        ha = get(h,'children');
        ht = findall(ha,'type','text');
        set(ht,'fontsize',8);
        error('Not Finish!');
    end
else
    OldList = find(Sub.Inform.IsOld >= 1);
    ReviewTimes = Sub.Inform.IsOld(OldList);
    Ranktable = table(OldList', ReviewTimes', 'VariableNames', {'idx', 'ReviewTimes'});
    
    Ranktable = sortrows(Ranktable, 'ReviewTimes', 'ascend');
    
    if length(OldList) < signalNum
        signalNum = length(OldList);
    end
    
    sigIdx = Ranktable.idx(1:signalNum);
    
    Curr_SignalList = SignalList(sigIdx);
    
end

if isempty(Curr_SignalList)
    errstr = '没有需要复习的信号，请先学习新信号!';
    h = errordlg(errstr,'错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',8);
    error('Already reviewed');
end
%% %%%%%%%进入主程序%%%%%%%%%%%%%%%%
[SigSeq, ScoreSeq, ResponseSeq, isFinish] = ...
    SoundReview_gui(Curr_SignalList, TagList, tagNum, SoundType, P);

if isFinish
    % 保存数据
    Sub.Inform.currDate = date;
    
    % 每天只记录最后一次复习的记录
    eval(['Sub.D' num2str(Sub.Inform.Day) '.R' reviewDayName '.reviewDay = reviewDay;']);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.R' reviewDayName '.SigSeq = SigSeq;']);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.R' reviewDayName '.ScoreSeq = ScoreSeq;']);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.R' reviewDayName '.ResponseSeq = ResponseSeq;']);
    
    % 但是每次复习次数都会增加
    curr_signalIdx = [Curr_SignalList(SigSeq).Index];
    Sub.Inform.IsOld(curr_signalIdx) = Sub.Inform.IsOld(curr_signalIdx) + 1;
    
    save(SubjectFileName, 'Sub');
    
    PlotFigure('subName', subName, 'group', '复习', 'DayName', Sub.Inform.Day, ...
        'SigSeq', SigSeq, 'ScoreSeq', ScoreSeq, 'signalIdx', curr_signalIdx, ...
        'IsOld', Sub.Inform.IsOld(curr_signalIdx));
    
else
    errstr = '本次复习尚未完成，请重新开始';
    h = errordlg(errstr,'错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',8);
    error('Not Finish!');
end

%% 结果作图
% if strcmp(group,'All')
%     plotType = 1;
% else
%     plotType = 2;
% end
% plot_results(orderSeq, AccSeq, SignalPerSession, timesPerSignal, group, block, plotType)
