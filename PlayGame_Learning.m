function [] = PlayGame_Learning(subName, group, signalNum, minGroupnum)
% �ź�ʶ��ѵ����ÿ��ѧϰsignalNum���źţ���Ϊ2��С��
% PlayGame_Learning(subName, group, signalNum)
% subName = 'test';
% group = 1;
% signalNum = 20;

%   Created by Diana, Hu, 2017.6.1
%   Updated by Xinyu Xie, 2017.7.10

t1 = GetSecs;
%% ����Ƿ�������Name��signal number�����û�����뱨��
if isempty(subName)
    h = errordlg('������������','����');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',10);
    error('Please Enter your NAME!')
end

if isempty(signalNum)
    h = errordlg('�����뱾��ѧϰ���ź�������','����');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',10);
    error('Please Enter the signal numeber!')
end

%% ��������
P.maxTimes = 2;  %% ÿ��С��ÿ���ź������ֶ��ٴ�,8
P.minTimes = 1;  %% ÿ��С��ÿ���ź����ٳ��ֶ��ٴ�,5
P.ReviewTimes = 2;  %% ÿ������ÿ���źų��ִ���,3
P.RightTimes = 1;  %% ÿ���ź��������ٴδﵽScoreBound����ͨ����������GameType = New & Old,3
P.maxCorrTimes = 1; %% ÿ���ź��ܹ����ٴδﵽScoreBound����ͨ����������GameType = Rev,2

P.ScoreBound = 90; % ��Եķ�����׼
P.TagWeight = [0 80 0 10 10]';  % ��ǩȨ��
P.impTagNum = 2; % ��Ҫ�ı�ǩ���

SoundType = 2;  % ���������ķ�ʽ��1��Ӧ.mat�ļ���2����������Ƶ�ļ�
minGroupnum = minGroupnum; % ���ٷ�����Ŀ��С�ڴ���Ŀ�򲻷���ѧϰ�ź� ��Welcom Line 62 �޸�

%% �����ź��б�
ListFielName = fullfile(pwd, 'Process_data', 'signal_list');
load(ListFielName);

% ���Եļ����ǩ����
tagNum = length(fieldnames(TagList)) - 4;  %5��

%% ���ݴ洢
% ���뱻����Ϣ
SubjectFilePath = fullfile(pwd, 'Subject', subName);
SubjectFileName = fullfile(SubjectFilePath, 'BasicInfo');

%  ���û�б�����Ϣ���½�������Ϣ
try
    load(SubjectFileName);
catch
    mkdir(SubjectFilePath);
    Sub.Inform.Id = subName;
    Sub.Inform.n = TagList.n; % ������Ϣ�ж�Ӧ���ź���Ŀ
    Sub.Inform.ConfusionMat = []; % ÿ���ź��ٴγ��ֵ�Ȩ��
    Sub.Inform.IsOld = ones(1, Sub.Inform.n)*-1; % ����ź��Ƿ������ź�,-1��ʾ��ûѧ��1��ʾ��ѧ�ᣬ0��ʾ��δѧ��
    Sub.Inform.Day = 1;  % ѧϰ������
    Sub.Inform.isFinish = 1; % ����м��˳�������ֵ��Ϊ0
    Sub.Inform.currDate = date; % ��ǰʱ�䣬�����ж��Ƿ��ǵڶ���
    Sub.Inform.LastGroup = [Sub.Inform.Day, 1];
    save(SubjectFileName, 'Sub');
end

if ~strcmp(date, Sub.Inform.currDate)
    Sub.Inform.Day = Sub.Inform.Day +1 ;  % ѧϰ������
end


% ���֮ǰ�����Ƿ�ѧ��
reviewDay = Sub.Inform.Day;
while ~isfield(Sub, ['D' num2str(reviewDay)])
    if reviewDay <= 1
        break;
    end
    reviewDay = reviewDay - 1;
end

reviewDayName = num2str(reviewDay);
if reviewDay ~=  Sub.Inform.Day && ~isfield(eval(['Sub.D' num2str(reviewDay)]), 'IsOld')
     errstr = 'ǰһ����δѧ�꣬����ǰһ�����ѧϰ';
     h = errordlg(errstr,'ȷ��');
     ha = get(h,'children');
     ht = findall(ha,'type','text');
     set(ht,'fontsize',8);
     Sub.Inform.Day = reviewDay;
     eval(sprintf('Sub.Inform.currDate = Sub.D%d.date;', reviewDay));
end
%% �����֮ǰδ���飬����з���
if ~isfield(Sub, ['D' num2str(Sub.Inform.Day)]) || (isfield(Sub, ['D' num2str(Sub.Inform.Day)]) && ~isfield(eval(['Sub.D' num2str(Sub.Inform.Day)]), 'groupIdx') )
    
    numGroup = 2;  %% �������źŷֳ�����
    if signalNum < minGroupnum  %% ����ź���С��n������ֻ��Ϊһ��
        numGroup = 1;
    end
    numSig_Group(1) = round(signalNum/numGroup); % ��һ����ź���
    numSig_Group(2) = signalNum - numSig_Group(1);% �ڶ�����ź���
    
    temp = randperm(signalNum);
    groupIdx{1} = temp(1:numSig_Group(1));
    groupIdx{2} = temp(numSig_Group(1)+1:end);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.groupIdx = groupIdx;']);
    
    lastDay = Sub.Inform.Day - 1;
    if lastDay == 0  % �����ǰ�ǵ�һ��,��������ź���ѡ��signalNum��Ϊ���ź�
        signalIdx = 1:signalNum;
    else  % �����ǰ���ǵ�һ�죬���Ƚ���ȥδѧ����źż��뱾��ѧϰ���ź��б�
        signalIdx_old = find(Sub.Inform.IsOld == 0);
        new_idx = find(Sub.Inform.IsOld == -1);
        signalIdx_new = new_idx(1:signalNum-length(signalIdx_old));
        signalIdx = [signalIdx_old signalIdx_new];
    end
    
    SignalList_Group = SignalList(1, signalIdx);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.SignalList_Group = SignalList_Group;']);
    eval(['Sub.D' num2str(Sub.Inform.Day) '.GAll.signalList = SignalList_Group;']);
    
    % ÿ����ź�
    for i = 1:numGroup
        temp_SignalList = SignalList_Group(groupIdx{i});
        eval(['Sub.D' num2str(Sub.Inform.Day) '.G' num2str(i) '.signalList = temp_SignalList;']);
    end
    
else
    eval(['groupIdx = Sub.D' num2str(Sub.Inform.Day) '.groupIdx;']);
    eval(['SignalList_Group = Sub.D' num2str(Sub.Inform.Day) '.SignalList_Group;']);
    
end

%% ****** �Ƿ�Ҫ�����ϴε�����
selectOld = 0;

if Sub.Inform.isFinish == 0
    lastDay = Sub.Inform.LastGroup{1};
    lastGroup = Sub.Inform.LastGroup{2};
    
    button = questdlg('��һ�ε�ѧϰ����δ��ɣ�������ϴε�ѧϰ','��ʾ','ȷ��','ȡ��','ȷ��');
    
    if strcmp(button, 'ȷ��')
        selectOld = 1;
        eval(['Curr_SignalList = Sub.D' lastDay '.G' lastGroup '.signalList;']);
        eval(['P.SigSeq = Sub.D' lastDay '.G' lastGroup '.SigSeq;']);
        eval(['P.ScoreSeq = Sub.D' lastDay '.G' lastGroup '.ScoreSeq;']);
        eval(['P.ResponseSeq = Sub.D' lastDay '.G' lastGroup '.ResponseSeq;']);
        eval(['P.IsLearned = Sub.D' lastDay '.isLearned;']);
        eval(['groupIdx = Sub.D' lastDay '.groupIdx;']);
        group = lastGroup;
        P.IsLearned = P.IsLearned(groupIdx{str2double(group)});

    elseif strcmp(button, 'ȡ��')
        error('Aborted by Users');
    end
end

%% ��ǰ�ź��б�
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

%% ���ÿ��С���Ƿ���ѧϰ
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
        h = errordlg('��ѡ�����ź���δѧ�꣬��ѡ��С�鿪ʼѧϰ','����');
        ha = get(h,'children');
        ht = findall(ha,'type','text');
        set(ht,'fontsize',8);
        error('Not finish learning')
    end
else
    eval(sprintf('GAlldata = Sub.D%d.GAll;', Sub.Inform.Day));
    if sum(isLearned) == length(isLearned) && isfield(GAlldata, 'ScoreSeq')
        button = questdlg('ǰ����ѧ��һ���飬�Ƿ�����µ�ѧϰ','��ʾ','ȷ��','ȡ��','ȷ��');
        
        if strcmp(button, 'ȷ��')
            Sub.Inform.Day = Sub.Inform.Day +1 ;  % ѧϰ������
            
            % ���·���
            
            numGroup = 2;  %% �������źŷֳ�����
            if signalNum < minGroupnum  %% ����ź���С��n������ֻ��Ϊһ��
                numGroup = 1;
            end
            numSig_Group(1) = round(signalNum/numGroup); % ��һ����ź���
            numSig_Group(2) = signalNum - numSig_Group(1);% �ڶ�����ź���
            
            temp = randperm(signalNum);
            groupIdx{1} = temp(1:numSig_Group(1));
            groupIdx{2} = temp(numSig_Group(1)+1:end);
            eval(['Sub.D' num2str(Sub.Inform.Day) '.groupIdx = groupIdx;']);
            
            lastDay = Sub.Inform.Day - 1;
            if lastDay == 0  % �����ǰ�ǵ�һ��,��������ź���ѡ��signalNum��Ϊ���ź�
                signalIdx = 1:signalNum;
            else  % �����ǰ���ǵ�һ�죬���Ƚ���ȥδѧ����źż��뱾��ѧϰ���ź��б�
                signalIdx_old = find(Sub.Inform.IsOld == 0);
                new_idx = find(Sub.Inform.IsOld == -1);
                signalIdx_new = new_idx(1:signalNum-length(signalIdx_old));
                signalIdx = [signalIdx_old signalIdx_new];
            end
            
            SignalList_Group = SignalList(1, signalIdx);
            eval(['Sub.D' num2str(Sub.Inform.Day) '.SignalList_Group = SignalList_Group;']);
            eval(['Sub.D' num2str(Sub.Inform.Day) '.GAll.signalList = SignalList_Group;']);
            
            % ÿ����ź�
            for i = 1:numGroup
                temp_SignalList = SignalList_Group(groupIdx{i});
                eval(['Sub.D' num2str(Sub.Inform.Day) '.G' num2str(i) '.signalList = temp_SignalList;']);
            end
            
            Curr_SignalList = SignalList_Group(groupIdx{str2double(group)});
            GameType = 'New';
        else
            h = errordlg('��ѡ�����Ѿ����ѧϰ������Ϣ��','����');
            ha = get(h,'children');
            ht = findall(ha,'type','text');
            set(ht,'fontsize',8);
            error('Already learned')
        end
    elseif  sum(isLearned(groupIdx{str2double(group)}) ~= 1)==0 && selectOld == 0
        h = errordlg('��ѡС���Ѿ����ѧϰ����ѡ���µ�С��','����');
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

%% %%%%%%%����������%%%%%%%%%%%%%%%%
[SigSeq, ScoreSeq, ResponseSeq, ConfusionMat, isLearned, IsOld, isFinish] = ...
    SoundLearning_gui(Curr_SignalList, TagList, tagNum, GameType, selectOld, SoundType, P);


%% ��������
t2 = GetSecs;

timep = t2-t1;
if isempty(Sub.Inform.ConfusionMat) 
    Sub.Inform.ConfusionMat = ConfusionMat;
elseif  size(Sub.Inform.ConfusionMat, 1) ~= size(ConfusionMat, 1)
    errordlg('�ź��б����ı䣬���飡�˴����ݲ�����', 'ȷ��');
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

%% �����ͼ
if isFinish
    PlotFigure('subName', subName, 'group', group, 'DayName', Sub.Inform.Day, ...
        'SigSeq', SigSeq, 'ScoreSeq', ScoreSeq, 'signalIdx', curr_signalIdx, ...
        'IsOld', IsOld);
end