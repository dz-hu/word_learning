function [textTag, rightChoiceIdx] = cal_Tag(tagNum, deTagChoiceNum, signal, TestTagList, tagName)
% �����ǩ
% ����ÿ�γ��ֵı�ǩѡ�����ȷ��ѡ����

%   Created by Xinyu Xie, 2017.7.8

thisTag = cell(tagNum-1, 1); % �ô̼��ı�ǩ
otherTag = cell(tagNum-1, 1); % ÿ����ǩ������ѡ��
tempOtherTag = cell(tagNum-1, 1);% ÿ����ǩ������ѡ�����ʱ����
rightChoiceIdx = zeros(tagNum, 1); % ��ȷѡ���index
choiceNum = ones(tagNum, 1)*deTagChoiceNum; % ÿ����ǩ��ѡ�������Ĭ��Ϊ4
textTag = cell(tagNum-1, 1); % ���ֵ�ÿ����ǩ��ѡ��
choiceTagListIdx = cell(tagNum-1, 1); % ÿ����ǩ��ѡ���������

for j = 1:tagNum-1  %%% ���һ����ǩ���ø�ѡ��
    % �ô̼��ı�ǩ
    eval(['thisTag{j, 1} = signal.' tagName{j} ';']);
   
    % ����ÿ����ǩ������ѡ��
    tempOtherTag{j, 1} = TestTagList{j, 1}( ~ismember(TestTagList{j, 1}, thisTag{j, 1}));
    lengthOtherTag = length(tempOtherTag{j, 1});
    if lengthOtherTag > deTagChoiceNum - 1
        Idx = randsample(length(tempOtherTag{j, 1}), deTagChoiceNum-1);
        otherTag{j, 1} = tempOtherTag{j, 1}(Idx);
    else
        otherTag{j, 1} = tempOtherTag{j, 1};
    end
    
    % ���ֵ�ÿ����ǩ��ѡ��
    textTagList = [thisTag{j, 1}, otherTag{j, 1}];
    tagLength = length(textTagList);
    
    if tagLength < deTagChoiceNum
        choiceNum(j, 1) = tagLength;  % ÿ����ǩ��ѡ�����
    end
    
    % ѡ���������
    choiceTagListIdx{j, 1} = randperm(tagLength, choiceNum(j,1)); 
    for choice = 1 : choiceNum(j, 1)
        textTag{j, 1}(choice) = textTagList(choiceTagListIdx{j, 1}(choice));
        if strcmp(textTag{j, 1}(choice), thisTag{j, 1})
            rightChoiceIdx(j, 1) = choice;  % ��ȷѡ��
        end
    end
end

% ���һ����ǩ����ȷѡ����Ϊ������ֵ
eval(['num = signal.' tagName{5} ';'])
rightChoiceIdx(5, 1) = str2double(num); 


