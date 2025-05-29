function [SigSeq, ScoreSeq, ResponseSeq, isFinish] = SoundReview_gui(Curr_SignalList, TagList, tagNum, SoundType, P)
% 信号识别训练复习部分主程序
% SoundReview_gui(Curr_SignalList, TagList, tagNum, GameType, SelectOld, SoundType, P)
%   Curr_SignalList: 当前的信号列表
%   TagList：所有标签列表
%   tagNum： 标签总数
%   GameType：任务类型，'New'表示学习新信号，'Old'表示已学信号的再次学习，'Rev'表示复习
%   SelectOld：是否从上次学习的信号继续
%   SoundType：1表示声音文件为.mat格式，2表示其他音频文件格式
% 返回: SigSeq(信号), ScoreSeq(得分), ResponseSeq(每个标签的反应), ConfusionMat(重要标签的混淆矩阵),
%       isLearned(每个信号是否有学习), IsOld(每个信号复习阶段得分是否通过), isFinish(当前任务是否完成)

%   Created by Xinyu Xie, 2017.7.8
%   Copyright: Peking University, YuLab


%% 参数设置
audiofilepath = fullfile(pwd, 'SoundandVideo');

numSig = size(Curr_SignalList, 2);  % 信号数量

TagWeight = P.TagWeight; % 标签权重
ScoreBound = P.ScoreBound; % 答对的分数标准

impTagNum = P.impTagNum;  % 重要的标签编号
deTagChoiceNum = 4; % 每个标签默认的选项数目

% 记录成绩
SigSeq = [];
ScoreSeq = [];
ResponseSeq = [];

% 每一个标签的所有取值
tagNames = fieldnames(TagList);
tagStartIdx = length(tagNames) - tagNum;

TestTagList = cell(tagNum-1, 1); % 每一个标签的所有取值
tagName = cell(tagNum,1); % 每个标签的名字
for i = 1:tagNum
    tagName{i} = tagNames{tagStartIdx+i,1};
    eval(['tagNameStr{i, 1} = TagList.' tagName{i, 1} '.name;']);
    eval(['TestTagList{i, 1} = TagList.' tagName{i} '.list.value;']);
end

impTagList = TestTagList{impTagNum, 1};   % 需要重点计算的标签
impTagLenght = length(impTagList);


TimesPerSignal = zeros(1, numSig); % 每个信号出现了几次
PassSignal = zeros(1, numSig); % 每个信号是否通过

%%
try
    isFinish = 1;
    while 1
        % 呈现指导语
        SBfhandle = SayBye('Words','根据听到的声音进行填空');
        
        for i = 1:numSig
            
            % 先进行记忆模式，并依此计分
            if sum(PassSignal ~= 1) == 0 % 如果达到一定标准，退出循环
                break
            end
            
            sigIdxList = find(PassSignal == 0); % 从未通过的信号中选择
            if length(sigIdxList) > 1
                sigIdx = randsample(sigIdxList, 1); % 每次随机选择一个信号
            else
                sigIdx = sigIdxList;
            end
            
            TimesPerSignal(1, sigIdx) = TimesPerSignal(1, sigIdx) + 1;
            signal = Curr_SignalList(sigIdx);
            
            soundfile = fullfile(audiofilepath, signal.soundfile);
            videofile = fullfile(audiofilepath, signal.videofile);
            
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
                otherchoicefile{1, t} = fullfile(audiofilepath, otherchoice{1, t});
            end
            
            % 进入实验界面  %%%%%%%%%%
            %             [actualResp, isEscape] = PresentSignal_try(soundfile, otherchoicefile, textTag, rightChoiceIdx, SoundType);
            
            
            [B, hfigure] = soundplay('SoundFile', soundfile, 'OtherChoiceFile', otherchoicefile,...
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
            
            firstScore = Score;
            firstResponse = response;
            
            while right == 0
                [B, hfigure] = soundplay('SoundFile', soundfile, 'OtherChoiceFile', otherchoicefile,...
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
            end
            
            SigSeq = [SigSeq sigIdx];
            ScoreSeq = [ScoreSeq firstScore];
            ResponseSeq = [ResponseSeq firstResponse];
            
            PassSignal(1, sigIdx) = 1;
            
        end
        
        if isFinish
            SBfhandle = SayBye('Words', '本次复习完成！');
        end
        
        if ~isempty(SBfhandle)
            close(SBfhandle);
        end
        
        if ~isempty(hfigure)
            close(hfigure);
        end
        
        if isFinish == 0
            break
        end
        
        %% 学习结束
        isFinish = 1;
        break;
    end
    
catch Me
    rethrow(Me);
end