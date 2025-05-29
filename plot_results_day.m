function plot_results_day(subName, resultsDay)
% 通过seeresults界面画出某天的实验结果
%

%   Created by Xinyu Xie, 2017.7.17

%% 检查数据是否存在
if isempty(subName)
    h = errordlg('请输入姓名！','错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',8);
    error('Please Enter your NAME!')
end;

SubjectFilePath = fullfile(pwd, 'Subject', subName);
SubjectFileName = fullfile(SubjectFilePath, 'BasicInfo');

try
    load(SubjectFileName);
catch
    h = errordlg('该被试的信息不存在','错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',8);
    error('No Information')
end

try
    eval(['curr_Data = Sub.D',resultsDay, ';']);
catch
    errstr = ['第' resultsDay '天前的数据不存在，请输入新的时间!'];
    h = errordlg(errstr,'错误');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',8);
    error('No Information')
end


fig = figure;
set(fig,'outerposition',[200 100 1000 650]);


%%
for g = 1:2 % 分两组呈现结果
    eval(['groupData = curr_Data.G' num2str(g) ';']);
    signalList = groupData.signalList;
    numSig = length(signalList);
    try
        SigSeq = groupData.SigSeq;
        ScoreSeq = groupData.ScoreSeq;
        
        % 计算每个信号的正确
        score = zeros(numSig, 1);
        signalIdx = zeros(numSig, 1);
        for i = 1:numSig
            signalIdx(i, 1) = signalList(1, i).Index;
            score(i, 1) =  mean(ScoreSeq(SigSeq == i));
        end
        
        figcolor = [0.26 0.67 0.8];
        barGap = 0.8;
        
        subplot(2,2,g)
        
        if length(score)==1
            c = bar(score);
        else
            c = bar(diag(score),barGap,'stack');
        end
        
        set(c,'FaceColor',figcolor);
        ylim([0,100]);
        set(gca,'XTick',1:numSig,'box','off');
        set(gca,'XTickLabel',signalIdx,'fontSize',14);
        %         xlabel('信号编号','fontSize',16);
        ylabel('平均分','fontSize',16);
        title([subName ': 第' resultsDay '天, 第' num2str(g) '小组'], 'fontSize',18);
    catch
        
    end
end



try
    % 画一个大组的数据
    groupData = curr_Data.GAll;
    signalList = groupData.signalList;
    numSig = length(signalList);
    
    SigSeq = groupData.SigSeq;
    ScoreSeq = groupData.ScoreSeq;
    IsOld = curr_Data.IsOld;
    
    % 计算每个信号的正确
    score = zeros(numSig, 1);
    signalIdx = zeros(numSig, 1);
    for i = 1:numSig
        signalIdx(i, 1) = signalList(1, i).Index;
        score(i, 1) =  mean(ScoreSeq(SigSeq == i));
    end
    
    figcolor = [0.26 0.67 0.8];
    barGap = 0.7;
    
    subplot(2,2,3)
    
    if length(score)==1
        c = bar(score);
    else
        c = bar(diag(score),barGap,'stack');
    end
    
    set(c,'FaceColor',figcolor);
    ylim([0,100]);
    set(gca,'XTick',1:numSig,'box','off');
    set(gca,'XTickLabel',signalIdx,'fontSize',14);
    xlabel('信号编号','fontSize',16);
    ylabel('平均分','fontSize',16);
    title([subName ': 第' resultsDay '天测试'], 'fontSize',18);
    
    
    subplot(2,2,4)
    oldColor = [59 155 183] / 255; % dark blue
    newColor = [204 88 69] / 255; % dark red
    
    old = find(IsOld == 1);
    oldNum = length(old);
    new = find(IsOld == 0);
    newNum = length(new);
    plot(old, ones(1,oldNum), 'o','MarkerEdgeColor','k','MarkerSize',10,'MarkerFaceColor',oldColor);
    hold on;
    plot(new, zeros(1,newNum), 'o','MarkerEdgeColor','k','MarkerSize',10,'MarkerFaceColor',newColor);
    ylim([-0.5 1.5])
    xlim([0.5 numSig+0.5]);
    set(gca,'box','off');
    set(gca,'YTick',0:1,'box','off');
    set(gca,'XTick',1:numSig,'box','off');
    set(gca,'YTickLabel',{'未 掌 握','已 掌 握'},'fontSize',14);
    set(gca,'XTickLabel',signalIdx,'fontSize',14);
    xlabel('信号编号','fontSize',16);
catch
end




