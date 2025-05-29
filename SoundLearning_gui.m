function [SigSeq, ScoreSeq, ResponseSeq, ConfusionMat, IsLearned, IsOld, isFinish] = SoundLearning_gui(Curr_SignalList, TagList, tagNum, GameType, SelectOld, SoundType, P)
% 信号识别训练学习部分主程序
% SoundLearning_gui(Curr_SignalList, TagList, tagNum, GameType, SelectOld, SoundType, P)
% Curr_SignalList: 当前的信号列表
% TagList：所有标签列表
% tagNum： 标签总数
% GameType：任务类型，'New'表示学习新信号，'Old'表示已学信号的再次学习，'Rev'表示复习
% SelectOld：是否从上次学习的信号继续
% SoundType：1表示声音文件为.mat格式，2表示其他音频文件格式
% 返回: SigSeq(信号), ScoreSeq(得分), ResponseSeq(每个标签的反应), ConfusionMat(重要标签的混淆矩阵),
% isLearned(每个信号是否有学习), IsOld(每个信号复习阶段得分是否通过), isFinish(当前任务是否完成)

%   Created by Xinyu Xie, 2017.7.8
%   Copyright: Peking University, YuLab


%% 参数设置
avfilepath = fullfile(pwd, 'SoundandVideo');

numSig = size(Curr_SignalList, 2);  % 信号数量

TagWeight = P.TagWeight; % 标签权重
ScoreBound = P.ScoreBound; % 答对的分数标准

maxTimes = P.maxTimes;  % 每个小组每个信号最多出现多少次
minTimes = P.minTimes;  % 每个小组每个信号最少出现多少次
ReviewTimes = P.ReviewTimes; % 每个大组每个信号出现次数
RightTimes = P.RightTimes;  % 每个信号连续多少次达到ScoreBound可以通过，适用于GameType = New & Old
maxCorrTimes = P.maxCorrTimes; % 每个信号总共多少次达到ScoreBound可以通过，适用于GameType = Rev

impTagNum = P.impTagNum;  % 重要的标签编号
deTagChoiceNum = 4; % 每个标签默认的选项数目

% 如果用了上一个的序列
if SelectOld
    SigSeq = P.SigSeq;
    ScoreSeq = P.ScoreSeq;
    ResponseSeq = P.ResponseSeq;
    IsLearned = P.IsLearned; % 每个信号是否有学习
else
    SigSeq = [];   % 记录每个试次的信号编号
    ScoreSeq = []; % 记录每个试次的得分
    ResponseSeq = []; % 记录每个试次的反应正确与否
    IsLearned = zeros(1, numSig); % 每个信号是否有学习
end

% 每一个标签的所有取值
tagNames = fieldnames(TagList);
tagStartIdx = length(tagNames) - tagNum;

TestTagList = cell(tagNum-1, 1); % 每一个标签的所有取值
tagName = cell(tagNum,1); % 每个标签的名字
for i = 1:tagNum
    tagName{i, 1} = tagNames{tagStartIdx+i,1};
    eval(['tagNameStr{i, 1} = TagList.' tagName{i, 1} '.name;']); % 每个标签的中文名，用于显示
    eval(['TestTagList{i, 1} = TagList.' tagName{i, 1} '.list.value;']);
end

impTagList = TestTagList{impTagNum, 1};   % 需要重点计算的标签
impTagLenght = length(impTagList);


TimesPerSignal = zeros(1, numSig); % 每个信号出现了几次
PassSignal = zeros(1, numSig); % 每个信号是否通过
ContinueRight = zeros(1, numSig); % 每个信号连续答对的次数，适用于GameType = New & Old
CorrTimes = zeros(1, numSig); % 每个信号答对的次数, 适用于GameType = Rev
IsOld = ones(1, numSig)*0;   % 每个信号测试是否通过
ConfusionMat = zeros(impTagLenght, impTagLenght); % 混淆矩阵

if ~isempty(SigSeq)
    for s = 1:numSig
        lastTimes = sum(SigSeq == s);
        TimesPerSignal(1, s) =  TimesPerSignal(1, s)+lastTimes;
    end
end

try
    isFinish = 1;
    while 1
       
        if strcmp(GameType,'New')  % 只对新信号
            %% 第一部分： 概览声音
            SBfhandle = SayBye('Words','首先学习新的声音');
            
            % 播放声音
            for i = 1 : numSig  % 依次出现每个信号
                signal = Curr_SignalList(i);
                soundfile = fullfile(avfilepath, signal.soundfile);
                videofile = fullfile(avfilepath, signal.videofile);
                descriptions =  signal.description;
                
                % 计算标签
                [textTag, rightChoiceIdx] = cal_Tag(tagNum, deTagChoiceNum, signal, TestTagList, tagName);
                
                % 重要的标签对应的文件名
                ImpTag = textTag{impTagNum, 1};
                eval(['ImpTagListAll = TagList.' tagName{impTagNum} '.value;']);
                otherchoice = cell(1, length(ImpTag));
                otherchoicefile = cell(1, length(ImpTag));
                for t = 1:length(ImpTag)
                    temp = find(ismember(ImpTagListAll,ImpTag(t)));
                    if length(temp) == 1
                        otherIdx = temp;
                    else
                    otherIdx = randsample(temp,1);
                    end
                    otherchoice{1, t} = TagList.soundfile.value(otherIdx);
                    otherchoicefile{1, t} = fullfile(avfilepath, otherchoice{1, t});
                end
                              
                %                 [~, isFinish] = PresentSignal_try(soundfile, [], textTag, rightChoiceIdx, SoundType);
                
                [B, hfigure1] = overview('SoundFile', soundfile, 'VideoFile', videofile, 'TagName', tagNameStr, 'TagChoice', textTag,...
                    'RightChoice', rightChoiceIdx, 'Soundtype', SoundType, 'Descriptions', descriptions);
                
                if B.isComplete == 0
                    isFinish = 0;
                    break
                end
                
                [B, hfigure2] = soundplay('SoundFile', soundfile, 'VideoFile', videofile, 'OtherChoiceFile', otherchoicefile,...
                    'TagName', tagNameStr, 'TagChoice', textTag, 'RightChoice', rightChoiceIdx, ...
                    'Soundtype', SoundType);
                
                if B.isComplete == 0
                    isFinish = 0;
                    break;
                end
                
                IsLearned(1, i) = 1;
                
            end
                       
                      
        end
        
        if isFinish == 0
            try
                if ~isempty(hfigure1)
                    close(hfigure1);
                end
            catch
            end
            try
                if ~isempty(hfigure2)
                    close(hfigure2);
                end
            catch
            end
            break
        end
        
        %% 第二部分
        % 呈现指导语
        if strcmp(GameType, 'New')
            SBfhandle = SayBye('Words','巩固刚才学习的声音');
        else
            SBfhandle = SayBye('Words','根据听到的声音选择对应的标签');
        end
        
        while 1
            if sum(PassSignal ~= 1) == 0 % 如果达到一定标准，退出循环
                break
            end
            
            sigIdxList = find(PassSignal == 0); % 从未通过的信号中选择
            if length(sigIdxList) > 1
                sigIdxList = sigIdxList(randperm(length(sigIdxList)));
                 [~, idx] = sort(TimesPerSignal(sigIdxList));
                sigIdx = sigIdxList(idx(1)); % 每次随机选择一个信号
            else
                sigIdx = sigIdxList;
            end
            
            TimesPerSignal(1, sigIdx) = TimesPerSignal(1, sigIdx) + 1;
            signal = Curr_SignalList(sigIdx);
            
            soundfile = fullfile(avfilepath, signal.soundfile);
            videofile = fullfile(avfilepath, signal.videofile);
            
            % 计算标签
            [textTag, rightChoiceIdx] = cal_Tag(tagNum, deTagChoiceNum, signal, TestTagList, tagName);
            
            % 重要的标签对应的文件名
            ImpTag = textTag{impTagNum, 1};
            eval(['ImpTagListAll = TagList.' tagName{impTagNum} '.value;']);
            otherchoice = cell(1, length(ImpTag));
            otherchoicefile = cell(1, length(ImpTag));
            for t = 1:length(ImpTag)
                temp = find(ismember(ImpTagListAll,ImpTag(t)));
                if length(temp) == 1
                    otherIdx = temp;
                else
                    otherIdx = randsample(temp,1);
                end
                otherchoice{1, t} = TagList.soundfile.value(otherIdx);
                otherchoicefile{1, t} = fullfile(avfilepath, otherchoice{1, t});
            end
            
            % 进入实验界面
            
            [B, hfigure] = soundplay('SoundFile', soundfile, 'VideoFile', videofile, 'OtherChoiceFile', otherchoicefile,...
                'TagName', tagNameStr, 'TagChoice', textTag, 'RightChoice', rightChoiceIdx, ...
                'Soundtype', SoundType);
            
            actualResp = B.MyChoice;
            isFinish = B.isComplete;

            if isFinish == 0
                break
            end
            
            % 计算response
            response =(actualResp == rightChoiceIdx);
            
            % 计算最后一个标签的得分
            lastTagResp = actualResp(end, 1);
            lastTagCorr = rightChoiceIdx(end, 1);
            if lastTagResp <= lastTagCorr*1.1 && lastTagResp >= lastTagCorr*0.9
                response(end, 1) = 1;
            elseif lastTagResp <= lastTagCorr*1.2 && lastTagResp >= lastTagCorr*0.8
                response(end, 1) = 0.5;
            else
                response(end, 1) = 0;
            end
            
            Score = sum(response .* TagWeight); % 总得分
            
            % 是否标记为正确
            if Score >= ScoreBound
                right = 1;
            else
                right = 0;
            end
            
            % 计算Confusion Matrix
            actualResp_ImpTag = actualResp(impTagNum);
            ImpTagChoice = textTag{impTagNum, 1}(actualResp_ImpTag);  % 选择的标签
            ImpTagRight = textTag{impTagNum, 1}(rightChoiceIdx(impTagNum)); % 正确的标签
            
            a = ismember(impTagList, ImpTagChoice);
            b = ismember(impTagList, ImpTagRight);
            ConfusionMat(b, a) = ConfusionMat(b, a) + 1;
            
            
            if ~strcmp(GameType, 'Rev') % 对New和Old
                ContinueRight(1, sigIdx) = ContinueRight(1, sigIdx) .* right + right; % 计算每个信号连续得到标准的次数
                
                % 连续答对一定次数且总次数大于minTimes则通过
                if ContinueRight(1, sigIdx) >= RightTimes && TimesPerSignal(1, sigIdx) >= minTimes
                    PassSignal(1, sigIdx) = 1;
                end
                
                if TimesPerSignal(1, sigIdx) >= maxTimes
                    PassSignal(1, sigIdx) = 1;
                end
                
            else % 对Rev
                if TimesPerSignal(1, sigIdx) >= ReviewTimes
                    PassSignal(1, sigIdx) = 1;
                end
            end
            
            % 记录成绩
            SigSeq = [SigSeq sigIdx];
            ScoreSeq = [ScoreSeq Score];
            ResponseSeq = [ResponseSeq response];
            
        end %% while
        
        if isFinish
            SBfhandle = SayBye('Words', '本次训练完成！');
        end
        
        if strcmp(GameType,'New') 
            if ishandle(hfigure1)
                close(hfigure1);
            end
        end
        
        if ishandle(hfigure)
            close(hfigure);
        end
                     
        
        % 对于Rev，根据每个信号答对的次数标记IsOld
        if strcmp(GameType, 'Rev')
            for s = 1:numSig
                CorrTimes(1, s) = sum(ScoreSeq(SigSeq == s) >= ScoreBound);
                if CorrTimes(1, s) >= maxCorrTimes
                    IsOld(1, s) = 1;
                else
                    IsOld(1, s) = 0;
                end
            end

        end
        
        if isFinish == 0
            break
        end
        
        %% 学习结束
        isFinish = 1;
        break
    end
    try
        if ~isempty(SBfhandle)
            close(SBfhandle);
        end
    catch
    end
    
catch Me
    rethrow(Me);
end