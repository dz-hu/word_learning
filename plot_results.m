function plot_results(h_axes, subName, group, DayName, SigSeq, ScoreSeq, signalIdx, IsOld)
% ÿ�����껭��ʵ����
% �����Ƿ���һ������ѵ�����ò�ͬ�Ļ�ͼ��ʽ

%   Created by Xinyu Xie, 2017.7.10
axes(h_axes);

if strcmp(group,'All')
    plotType = 1;
elseif strcmp(group, '��ϰ')
    plotType = 3;
else
    plotType = 2;
end
fig = h_axes;

% if plotType == 1
%     set(fig,'outerposition',[300 100 700 700]);
% else
%     set(fig,'outerposition',[300 200 700 600]);
% end

% ����ÿ���źŵ���ȷ
numSig = length(signalIdx);

score = zeros(numSig, 1);
for i = 1:numSig
    score(i, 1) =  mean(ScoreSeq(SigSeq == i));
end

figcolor = [0.26 0.67 0.8];
barGap = 0.7;

if plotType == 1
    subplot(2,1,1)
else
    subplot(1,1,1)
end

if length(score)==1
    c = bar(score);  
else
    c = bar(diag(score),barGap,'stack');
end

set(c,'FaceColor',figcolor);
ylim([0,100]);
try
    yticks(0:10:100);
catch
    set(gca, 'YTick', 0:10:100);
end

hold on;
xlimdata = get(gca, 'xlim');
plot(xlimdata, [90 90], 'k--');

set(gca,'XTick',1:numSig,'box','off');
set(gca,'XTickLabel',signalIdx,'fontSize',14);
xlabel('�źű��','fontSize',16);
ylabel('ƽ����','fontSize',16);

if plotType == 2
    title([subName ': ��' num2str(DayName) '��, ��' group 'С��'], 'fontSize',18);
elseif plotType == 3
    title([subName ': ��' num2str(DayName) '��, ' group 'С��'], 'fontSize',18);
    
    for i = 1 : numSig
        text(i,10, num2str(IsOld(i)),  'fontSize',18, 'color', [1 1 1], 'HorizontalAlignment', 'center');
    end
else
    title([subName ': ��' num2str(DayName) '��'], 'fontSize',18);
end

if plotType == 1
    subplot(2,1,2)
    oldColor = [59 155 183] / 255; % dark blue
    newColor = [204 88 69] / 255; % dark red
    
    old = find(IsOld >= 1);
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
    set(gca,'YTickLabel',{'δ �� ��','�� �� ��'},'fontSize',14);
    set(gca,'XTickLabel',signalIdx,'fontSize',14);
    xlabel('�źű��','fontSize',16);
end



