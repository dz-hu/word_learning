function [SigSeq, ScoreSeq, ResponseSeq, ConfusionMat, IsLearned, IsOld, isFinish] = SoundLearning_gui(Curr_SignalList, TagList, tagNum, GameType, SelectOld, SoundType, P)
% �ź�ʶ��ѵ��ѧϰ����������
% SoundLearning_gui(Curr_SignalList, TagList, tagNum, GameType, SelectOld, SoundType, P)
% Curr_SignalList: ��ǰ���ź��б�
% TagList�����б�ǩ�б�
% tagNum�� ��ǩ����
% GameType���������ͣ�'New'��ʾѧϰ���źţ�'Old'��ʾ��ѧ�źŵ��ٴ�ѧϰ��'Rev'��ʾ��ϰ
% SelectOld���Ƿ���ϴ�ѧϰ���źż���
% SoundType��1��ʾ�����ļ�Ϊ.mat��ʽ��2��ʾ������Ƶ�ļ���ʽ
% ����: SigSeq(�ź�), ScoreSeq(�÷�), ResponseSeq(ÿ����ǩ�ķ�Ӧ), ConfusionMat(��Ҫ��ǩ�Ļ�������),
% isLearned(ÿ���ź��Ƿ���ѧϰ), IsOld(ÿ���źŸ�ϰ�׶ε÷��Ƿ�ͨ��), isFinish(��ǰ�����Ƿ����)

%   Created by Xinyu Xie, 2017.7.8
%   Copyright: Peking University, YuLab


%% ��������
avfilepath = fullfile(pwd, 'SoundandVideo');

numSig = size(Curr_SignalList, 2);  % �ź�����

TagWeight = P.TagWeight; % ��ǩȨ��
ScoreBound = P.ScoreBound; % ��Եķ�����׼

maxTimes = P.maxTimes;  % ÿ��С��ÿ���ź������ֶ��ٴ�
minTimes = P.minTimes;  % ÿ��С��ÿ���ź����ٳ��ֶ��ٴ�
ReviewTimes = P.ReviewTimes; % ÿ������ÿ���źų��ִ���
RightTimes = P.RightTimes;  % ÿ���ź��������ٴδﵽScoreBound����ͨ����������GameType = New & Old
maxCorrTimes = P.maxCorrTimes; % ÿ���ź��ܹ����ٴδﵽScoreBound����ͨ����������GameType = Rev

impTagNum = P.impTagNum;  % ��Ҫ�ı�ǩ���
deTagChoiceNum = 4; % ÿ����ǩĬ�ϵ�ѡ����Ŀ

% ���������һ��������
if SelectOld
    SigSeq = P.SigSeq;
    ScoreSeq = P.ScoreSeq;
    ResponseSeq = P.ResponseSeq;
    IsLearned = P.IsLearned; % ÿ���ź��Ƿ���ѧϰ
else
    SigSeq = [];   % ��¼ÿ���Դε��źű��
    ScoreSeq = []; % ��¼ÿ���Դεĵ÷�
    ResponseSeq = []; % ��¼ÿ���Դεķ�Ӧ��ȷ���
    IsLearned = zeros(1, numSig); % ÿ���ź��Ƿ���ѧϰ
end

% ÿһ����ǩ������ȡֵ
tagNames = fieldnames(TagList);
tagStartIdx = length(tagNames) - tagNum;

TestTagList = cell(tagNum-1, 1); % ÿһ����ǩ������ȡֵ
tagName = cell(tagNum,1); % ÿ����ǩ������
for i = 1:tagNum
    tagName{i, 1} = tagNames{tagStartIdx+i,1};
    eval(['tagNameStr{i, 1} = TagList.' tagName{i, 1} '.name;']); % ÿ����ǩ����������������ʾ
    eval(['TestTagList{i, 1} = TagList.' tagName{i, 1} '.list.value;']);
end

impTagList = TestTagList{impTagNum, 1};   % ��Ҫ�ص����ı�ǩ
impTagLenght = length(impTagList);


TimesPerSignal = zeros(1, numSig); % ÿ���źų����˼���
PassSignal = zeros(1, numSig); % ÿ���ź��Ƿ�ͨ��
ContinueRight = zeros(1, numSig); % ÿ���ź�������ԵĴ�����������GameType = New & Old
CorrTimes = zeros(1, numSig); % ÿ���źŴ�ԵĴ���, ������GameType = Rev
IsOld = ones(1, numSig)*0;   % ÿ���źŲ����Ƿ�ͨ��
ConfusionMat = zeros(impTagLenght, impTagLenght); % ��������

if ~isempty(SigSeq)
    for s = 1:numSig
        lastTimes = sum(SigSeq == s);
        TimesPerSignal(1, s) =  TimesPerSignal(1, s)+lastTimes;
    end
end

try
    isFinish = 1;
    while 1
       
        if strcmp(GameType,'New')  % ֻ�����ź�
            %% ��һ���֣� ��������
            SBfhandle = SayBye('Words','����ѧϰ�µ�����');
            
            % ��������
            for i = 1 : numSig  % ���γ���ÿ���ź�
                signal = Curr_SignalList(i);
                soundfile = fullfile(avfilepath, signal.soundfile);
                videofile = fullfile(avfilepath, signal.videofile);
                descriptions =  signal.description;
                
                % �����ǩ
                [textTag, rightChoiceIdx] = cal_Tag(tagNum, deTagChoiceNum, signal, TestTagList, tagName);
                
                % ��Ҫ�ı�ǩ��Ӧ���ļ���
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
        
        %% �ڶ�����
        % ����ָ����
        if strcmp(GameType, 'New')
            SBfhandle = SayBye('Words','���̸ղ�ѧϰ������');
        else
            SBfhandle = SayBye('Words','��������������ѡ���Ӧ�ı�ǩ');
        end
        
        while 1
            if sum(PassSignal ~= 1) == 0 % ����ﵽһ����׼���˳�ѭ��
                break
            end
            
            sigIdxList = find(PassSignal == 0); % ��δͨ�����ź���ѡ��
            if length(sigIdxList) > 1
                sigIdxList = sigIdxList(randperm(length(sigIdxList)));
                 [~, idx] = sort(TimesPerSignal(sigIdxList));
                sigIdx = sigIdxList(idx(1)); % ÿ�����ѡ��һ���ź�
            else
                sigIdx = sigIdxList;
            end
            
            TimesPerSignal(1, sigIdx) = TimesPerSignal(1, sigIdx) + 1;
            signal = Curr_SignalList(sigIdx);
            
            soundfile = fullfile(avfilepath, signal.soundfile);
            videofile = fullfile(avfilepath, signal.videofile);
            
            % �����ǩ
            [textTag, rightChoiceIdx] = cal_Tag(tagNum, deTagChoiceNum, signal, TestTagList, tagName);
            
            % ��Ҫ�ı�ǩ��Ӧ���ļ���
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
            
            % ����ʵ�����
            
            [B, hfigure] = soundplay('SoundFile', soundfile, 'VideoFile', videofile, 'OtherChoiceFile', otherchoicefile,...
                'TagName', tagNameStr, 'TagChoice', textTag, 'RightChoice', rightChoiceIdx, ...
                'Soundtype', SoundType);
            
            actualResp = B.MyChoice;
            isFinish = B.isComplete;

            if isFinish == 0
                break
            end
            
            % ����response
            response =(actualResp == rightChoiceIdx);
            
            % �������һ����ǩ�ĵ÷�
            lastTagResp = actualResp(end, 1);
            lastTagCorr = rightChoiceIdx(end, 1);
            if lastTagResp <= lastTagCorr*1.1 && lastTagResp >= lastTagCorr*0.9
                response(end, 1) = 1;
            elseif lastTagResp <= lastTagCorr*1.2 && lastTagResp >= lastTagCorr*0.8
                response(end, 1) = 0.5;
            else
                response(end, 1) = 0;
            end
            
            Score = sum(response .* TagWeight); % �ܵ÷�
            
            % �Ƿ���Ϊ��ȷ
            if Score >= ScoreBound
                right = 1;
            else
                right = 0;
            end
            
            % ����Confusion Matrix
            actualResp_ImpTag = actualResp(impTagNum);
            ImpTagChoice = textTag{impTagNum, 1}(actualResp_ImpTag);  % ѡ��ı�ǩ
            ImpTagRight = textTag{impTagNum, 1}(rightChoiceIdx(impTagNum)); % ��ȷ�ı�ǩ
            
            a = ismember(impTagList, ImpTagChoice);
            b = ismember(impTagList, ImpTagRight);
            ConfusionMat(b, a) = ConfusionMat(b, a) + 1;
            
            
            if ~strcmp(GameType, 'Rev') % ��New��Old
                ContinueRight(1, sigIdx) = ContinueRight(1, sigIdx) .* right + right; % ����ÿ���ź������õ���׼�Ĵ���
                
                % �������һ���������ܴ�������minTimes��ͨ��
                if ContinueRight(1, sigIdx) >= RightTimes && TimesPerSignal(1, sigIdx) >= minTimes
                    PassSignal(1, sigIdx) = 1;
                end
                
                if TimesPerSignal(1, sigIdx) >= maxTimes
                    PassSignal(1, sigIdx) = 1;
                end
                
            else % ��Rev
                if TimesPerSignal(1, sigIdx) >= ReviewTimes
                    PassSignal(1, sigIdx) = 1;
                end
            end
            
            % ��¼�ɼ�
            SigSeq = [SigSeq sigIdx];
            ScoreSeq = [ScoreSeq Score];
            ResponseSeq = [ResponseSeq response];
            
        end %% while
        
        if isFinish
            SBfhandle = SayBye('Words', '����ѵ����ɣ�');
        end
        
        if strcmp(GameType,'New') 
            if ishandle(hfigure1)
                close(hfigure1);
            end
        end
        
        if ishandle(hfigure)
            close(hfigure);
        end
                     
        
        % ����Rev������ÿ���źŴ�ԵĴ������IsOld
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
        
        %% ѧϰ����
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