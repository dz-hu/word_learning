function     [actualResp, isEscape] = PresentSignal_try(soundfile, otherchoicefile, textTag, rightChoiceIdx, SoundType)
actualResp = zeros(5, 1);
for i = 1:4
actualResp(i, 1) = randsample(4,1);
end
actualResp(5, 1) = rightChoiceIdx(5)*(1+rand*0.6-0.3);
isEscape = 1;

