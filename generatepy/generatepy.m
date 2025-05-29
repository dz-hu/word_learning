a = readtable('国家.csv');


for i = 1 : height(a)
    [all,a.py{i}] = FunPinyin(a.nation{i});
end

writetable(a, '国家.csv')