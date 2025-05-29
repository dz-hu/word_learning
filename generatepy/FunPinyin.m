function [quanpin,firstword] = FunPinyin(w)

error(nargchk(1,1, nargin, 'struct'));

[pinyin,word] = FunDictionary;

n = length(w);

quanpin = [];
for i = 1:n
    for j = 1:399
       if regexp(word(j),w(i))
           quanpin = [quanpin,pinyin(j)];  
       else
           continue;
       end
    end
end;clear i j

if isempty(quanpin)
    firstword = [];
    warning('Please check the input message.');
    return;
end

quanpin = quanpin';

m = length(quanpin);

for i = 1:m
    single = char(quanpin(i));
    firstword(i) = upper(single(1));
end;clear i