function [textTag, rightChoiceIdx] = cal_Tag(tagNum, deTagChoiceNum, signal, TestTagList, tagName)
% 计算标签
% 返回每次呈现的标签选项和正确的选项编号

%   Created by Xinyu Xie, 2017.7.8

thisTag = cell(tagNum-1, 1); % 该刺激的标签
otherTag = cell(tagNum-1, 1); % 每个标签的其他选项
tempOtherTag = cell(tagNum-1, 1);% 每个标签的其他选项的临时变量
rightChoiceIdx = zeros(tagNum, 1); % 正确选项的index
choiceNum = ones(tagNum, 1)*deTagChoiceNum; % 每个标签的选项个数，默认为4
textTag = cell(tagNum-1, 1); % 呈现的每个标签的选项
choiceTagListIdx = cell(tagNum-1, 1); % 每个标签的选项随机排序

for j = 1:tagNum-1  %%% 最后一个标签不用给选项
    % 该刺激的标签
    eval(['thisTag{j, 1} = signal.' tagName{j} ';']);
   
    % 计算每个标签的其他选项
    tempOtherTag{j, 1} = TestTagList{j, 1}( ~ismember(TestTagList{j, 1}, thisTag{j, 1}));
    lengthOtherTag = length(tempOtherTag{j, 1});
    if lengthOtherTag > deTagChoiceNum - 1
        Idx = randsample(length(tempOtherTag{j, 1}), deTagChoiceNum-1);
        otherTag{j, 1} = tempOtherTag{j, 1}(Idx);
    else
        otherTag{j, 1} = tempOtherTag{j, 1};
    end
    
    % 呈现的每个标签的选项
    textTagList = [thisTag{j, 1}, otherTag{j, 1}];
    tagLength = length(textTagList);
    
    if tagLength < deTagChoiceNum
        choiceNum(j, 1) = tagLength;  % 每个标签的选项个数
    end
    
    % 选项随机排序
    choiceTagListIdx{j, 1} = randperm(tagLength, choiceNum(j,1)); 
    for choice = 1 : choiceNum(j, 1)
        textTag{j, 1}(choice) = textTagList(choiceTagListIdx{j, 1}(choice));
        if strcmp(textTag{j, 1}(choice), thisTag{j, 1})
            rightChoiceIdx(j, 1) = choice;  % 正确选项
        end
    end
end

% 最后一个标签的正确选项编号为具体数值
eval(['num = signal.' tagName{5} ';'])
rightChoiceIdx(5, 1) = str2double(num); 


