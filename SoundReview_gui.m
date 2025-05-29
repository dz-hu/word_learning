function [SigSeq, ScoreSeq, ResponseSeq, isFinish] = SoundReview_gui(Curr_SignalList, TagList, tagNum, SoundType, P)
% �ź�ʶ��ѵ����ϰ����������
% SoundReview_gui(Curr_SignalList, TagList, tagNum, GameType, SelectOld, SoundType, P)
%   Curr_SignalList: ��ǰ���ź��б�
%   TagList�����б�ǩ�б�
%   tagNum�� ��ǩ����
%   GameType���������ͣ�'New'��ʾѧϰ���źţ�'Old'��ʾ��ѧ�źŵ��ٴ�ѧϰ��'Rev'��ʾ��ϰ
%   SelectOld���Ƿ���ϴ�ѧϰ���źż���
%   SoundType��1��ʾ�����ļ�Ϊ.mat��ʽ��2��ʾ������Ƶ�ļ���ʽ
% ����: SigSeq(�ź�), ScoreSeq(�÷�), ResponseSeq(ÿ����ǩ�ķ�Ӧ), ConfusionMat(��Ҫ��ǩ�Ļ�������),
%       isLearned(ÿ���ź��Ƿ���ѧϰ), IsOld(ÿ���źŸ�ϰ�׶ε÷��Ƿ�ͨ��), isFinish(��ǰ�����Ƿ����)

%   Created by Xinyu Xie, 2017.7.8
%   Copyright: Peking University, YuLab


%% ��������
audiofilepath = fullfile(pwd, 'SoundandVideo');

numSig = size(Curr_SignalList, 2);  % �ź�����

TagWeight = P.TagWeight; % ��ǩȨ��
ScoreBound = P.ScoreBound; % ��Եķ�����׼

impTagNum = P.impTagNum;  % ��Ҫ�ı�ǩ���
deTagChoiceNum = 4; % ÿ����ǩĬ�ϵ�ѡ����Ŀ

% ��¼�ɼ�
SigSeq = [];
ScoreSeq = [];
ResponseSeq = [];

% ÿһ����ǩ������ȡֵ
tagNames = fieldnames(TagList);
tagStartIdx = length(tagNames) - tagNum;

TestTagList = cell(tagNum-1, 1); % ÿһ����ǩ������ȡֵ
tagName = cell(tagNum,1); % ÿ����ǩ������
for i = 1:tagNum
    tagName{i} = tagNames{tagStartIdx+i,1};
    eval(['tagNameStr{i, 1} = TagList.' tagName{i, 1} '.name;']);
    eval(['TestTagList{i, 1} = TagList.' tagName{i} '.list.value;']);
end

impTagList = TestTagList{impTagNum, 1};   % ��Ҫ�ص����ı�ǩ
impTagLenght = length(impTagList);


TimesPerSignal = zeros(1, numSig); % ÿ���źų����˼���
PassSignal = zeros(1, numSig); % ÿ���ź��Ƿ�ͨ��

%%
try
    isFinish = 1;
    while 1
        % ����ָ����
        SBfhandle = SayBye('Words','���������������������');
        
        for i = 1:numSig
            
            % �Ƚ��м���ģʽ�������˼Ʒ�
            if sum(PassSignal ~= 1) == 0 % ����ﵽһ����׼���˳�ѭ��
                break
            end
            
            sigIdxList = find(PassSignal == 0); % ��δͨ�����ź���ѡ��
            if length(sigIdxList) > 1
                sigIdx = randsample(sigIdxList, 1); % ÿ�����ѡ��һ���ź�
            else
                sigIdx = sigIdxList;
            end
            
            TimesPerSignal(1, sigIdx) = TimesPerSignal(1, sigIdx) + 1;
            signal = Curr_SignalList(sigIdx);
            
            soundfile = fullfile(audiofilepath, signal.soundfile);
            videofile = fullfile(audiofilepath, signal.videofile);
            
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
                otherchoicefile{1, t} = fullfile(audiofilepath, otherchoice{1, t});
            end
            
            % ����ʵ�����  %%%%%%%%%%
            %             [actualResp, isEscape] = PresentSignal_try(soundfile, otherchoicefile, textTag, rightChoiceIdx, SoundType);
            
            
            [B, hfigure] = soundplay('SoundFile', soundfile, 'OtherChoiceFile', otherchoicefile,...
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
            end
            
            SigSeq = [SigSeq sigIdx];
            ScoreSeq = [ScoreSeq firstScore];
            ResponseSeq = [ResponseSeq firstResponse];
            
            PassSignal(1, sigIdx) = 1;
            
        end
        
        if isFinish
            SBfhandle = SayBye('Words', '���θ�ϰ��ɣ�');
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
        
        %% ѧϰ����
        isFinish = 1;
        break;
    end
    
catch Me
    rethrow(Me);
end