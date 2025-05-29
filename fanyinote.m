

a = readtable('D:\hdz\sound_learning_word\SoundandVideo\note.csv');

allC = {};
for i = 2 : height(a)
    word= a.distance{i};
    fanyiall = lookupword(word);
    
    [C,matches] = strsplit(fanyiall, {'£»', '\n'}, 'CollapseDelimiters',true);
    
    if length(C) >= 3
        C = C(1:3);
    else
        C = repmat(C, 1, 3);
        C = C(1:3);
    end
    
    allC = [allC; C];
    
end

writetable(a, 'D:\hdz\sound_learning_word\SoundandVideo\note.csv');



