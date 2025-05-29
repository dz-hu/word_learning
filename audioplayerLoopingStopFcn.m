function audioplayerLoopingStopFcn(haudioplayer, eventStruct)
if ~ haudioplayer.UserData.stopPlayback
  play(haudioplayer);
end