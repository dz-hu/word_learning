function signallist1 = importfile(filename, startRow, endRow)
%IMPORTFILE ���ı��ļ��е���ֵ������Ϊ�����롣
%   SIGNALLIST1 = IMPORTFILE(FILENAME) ��ȡ�ı��ļ� FILENAME ��Ĭ��ѡ����Χ�����ݡ�
%
%   SIGNALLIST1 = IMPORTFILE(FILENAME, STARTROW, ENDROW) ��ȡ�ı��ļ� FILENAME ��
%   STARTROW �е� ENDROW ���е����ݡ�
%
% Example:
%   signallist1 = importfile('signal_list.csv', 1, 12);
%
%    ������� TEXTSCAN��

% �� MATLAB �Զ������� 2017/06/01 11:15:40

%% ��ʼ��������
delimiter = ',';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% ÿ���ı��еĸ�ʽ:
%   ��1: �ı� (%s)
%	��2: �ı� (%s)
%   ��3: �ı� (%s)
%	��4: �ı� (%s)
%   ��5: �ı� (%s)
%	��6: �ı� (%s)
%   ��7: �ı� (%s)
%	��8: �ı� (%s)
%   ��9: �ı� (%s)
% �й���ϸ��Ϣ������� TEXTSCAN �ĵ���
% formatSpec = '%s%s%s%s%s%s%s%s%s%[^\n\r]';
formatSpec = '%s%s%s%s%s%s%[^\n\r]';   %%%%%%%%%%5����ǩ��һ���ļ���

%% ���ı��ļ���
fileID = fopen(filename,'r');

%% ���ݸ�ʽ��ȡ�����С�
% �õ��û������ɴ˴������õ��ļ��Ľṹ����������ļ����ִ����볢��ͨ�����빤���������ɴ��롣
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% �ر��ı��ļ���
fclose(fileID);

%% ���޷���������ݽ��еĺ���
% �ڵ��������δӦ���޷���������ݵĹ�����˲�����������롣Ҫ�����������޷���������ݵĴ��룬�����ļ���ѡ���޷������Ԫ����Ȼ���������ɽű���

%% �����������
signallist1 = [dataArray{1:end-1}];
