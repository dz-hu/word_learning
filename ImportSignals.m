% function [] = ImportSignals(csvfile)
% �������ļ��������Ӧ�ı�ǩ����signal_list.mat�ļ�
% ������ݰ���TagList��SignalList��
% Created by Dingzhi Hu
% Updated by Xinyu Xie, 2017.6.27
% 
clear;
csvfile = 'note.csv';

% �����ļ���
csvfilename = fullfile(pwd, 'SoundandVideo', csvfile);
signals = readtable(csvfilename);

filepath = fullfile(pwd, 'Process_data');

if ~exist(filepath,'dir')
    mkdir(filepath)
end

Listfile = fullfile(filepath, 'signal_list');

% % ����Ѿ�������signal_list,�����г���ʱ����������������µ��ź�
% try  
%     load(Listfile);
% catch
%     TagList.n = 0;
%     SignalList = [];
% end;
TagList.n = 0;

% ��һ������Ϊ��������
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
            % ���������
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