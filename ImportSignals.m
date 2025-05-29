% function [] = ImportSignals(csvfile)
% 将声音文件名及其对应的标签生成signal_list.mat文件
% 输出数据包括TagList和SignalList；
% Created by Dingzhi Hu
% Updated by Xinyu Xie, 2017.6.27
% 
clear;
csvfile = 'note.csv';

% 建立文件夹
csvfilename = fullfile(pwd, 'SoundandVideo', csvfile);
signals = readtable(csvfilename);

filepath = fullfile(pwd, 'Process_data');

if ~exist(filepath,'dir')
    mkdir(filepath)
end

Listfile = fullfile(filepath, 'signal_list');

% % 如果已经存在了signal_list,则运行程序时在已有数据上添加新的信号
% try  
%     load(Listfile);
% catch
%     TagList.n = 0;
%     SignalList = [];
% end;
TagList.n = 0;

% 第一行数据为中文描述
nSignals = height(signals)-1;
nTag = width(signals);


for i = 2 : nSignals+1
    TagList.n = TagList.n + 1;
    thissignal = TagList.n;
    
    for j = 1 : nTag
        varname = signals.Properties.VariableNames{j};
        
        try
            tmpstr = strrep(signals{i, j}{1}, ' ', '');
            eval(['Psignal.' varname '= signals{i, j}{1};']);
        catch
            % 如果是数字
            eval(['Psignal.' varname '= num2str(signals{i, j});']);
        end
        
       
        %%%%%%%%%%%%
        eval(['TagList.' varname '.value{thissignal} = signals{i, j}{1};']);
        eval(['TagList.' varname '.name = signals{1, j}{1};']);
        if TagList.n ==1
            eval(['TagList.' varname '.list.n = 1;']);
            eval(['TagList.' varname '.list.value{1} = signals{i, j}{1};']);
        else
            eval(['TagValue = TagList.' varname '.list.value;'])
            if find(strcmp(TagValue, signals{i, j}{1}))
            else
                eval(['nn = TagList.' varname '.list.n + 1;']);
                eval(['TagList.' varname '.list.n = nn;']);
                eval(['TagList.' varname '.list.value{nn} = signals{i, j}{1};']);
            end
        end
    end
    Psignal.Index = TagList.n;
    SignalList(TagList.n) = Psignal;
end

save(Listfile,'TagList', 'SignalList');

% end