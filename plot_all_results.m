function plot_all_results(h_axes, subName)
% ��ÿ�����Ե�ѵ����չ

%   Created by Xinyu Xie, 2017.7.10


subFileName = fullfile(pwd, 'Subject', subName, 'BasicInfo.mat');
try
    load(subFileName);
catch
    h = errordlg('�ñ�����Ϣ�����ڣ�','����');
    ha = get(h,'children');
    ht = findall(ha,'type','text');
    set(ht,'fontsize',10);
    error('No information!')
end

axes(h_axes);

IsOld_all = Sub.Inform.IsOld;

% ����ÿ���źŵ���ȷ
numSig = length(IsOld_all);
n = 100;
figNum = ceil(numSig/n);

learnedColor = [59 155 183] / 255; % dark blue
unlearnedColor = [204 88 69] / 255; % dark red
newColor = [0 0 0]; % black

for i = 1:figNum
    h = subplot(figNum, 1, i);
    
    if i == 1
        htitle = h;
    end
    if i*n > numSig
        IsOld = IsOld_all((i-1)*n + 1: end);
        signalIdx = (i-1)*n + 1: numSig;
    else
        IsOld = IsOld_all((i-1)*n + 1: i*n);
        signalIdx = (i-1)*n + 1: i*n;
    end
    xL = length(signalIdx);
    
    learned = find(IsOld >= 1);
    learnedNum = length(learned);
    unlearned = find(IsOld == 0);
    unlearnedNum = length(unlearned);
    new = find(IsOld == -1);
    newNum = length(new);
    
    ringnum = 10; % ÿ��������ɿ���
    msize = 4;
    
    hold on;
    selectidx = mod(learned,ringnum) ~= 0;
    plot(learned(selectidx), ones(1,sum(selectidx)), 'o','MarkerEdgeColor','k','MarkerSize',msize,'MarkerFaceColor',learnedColor);
    selectidx = mod(learned,ringnum) == 0;
    plot(learned(selectidx), ones(1,sum(selectidx)), 'o','MarkerEdgeColor',learnedColor,'MarkerSize',msize);
    
    selectidx = mod(unlearned,ringnum) ~= 0;
    plot(unlearned(selectidx), zeros(1,sum(selectidx)), 'o','MarkerEdgeColor','k','MarkerSize',msize,'MarkerFaceColor',unlearnedColor);
    selectidx = mod(unlearned,ringnum) == 0;
    plot(unlearned(selectidx), zeros(1,sum(selectidx)), 'o','MarkerEdgeColor',unlearnedColor,'MarkerSize',msize);
    
    selectidx = mod(new,ringnum) ~= 0;
    plot(new(selectidx), -ones(1,sum(selectidx)), 'o','MarkerEdgeColor','k','MarkerSize',msize,'MarkerFaceColor',newColor);
    selectidx = mod(new,ringnum) == 0;
    plot(new(selectidx), -ones(1,sum(selectidx)), 'o','MarkerEdgeColor',newColor,'MarkerSize',msize);
    
    ylim([-1.5 1.5])
    xlim([0 n+1]);
    set(gca,'box','off');
    set(gca,'YTick',-1:1,'box','off');
    set(gca,'XTick',5:5:n,'box','off');
    set(gca,'YTickLabel',{'δѧ' 'δ �� ��','�� �� ��'},...
        'XTickLabel',signalIdx(5:5:end),'fontSize',8);
end
xlabel('�źű��','fontSize',16);
title(htitle, [subName ': ѵ������'],'fontSize',16);




