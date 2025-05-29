SoundFile = 'D:\hdz\sound_learning_word\SoundandVideo\³¬¸Ùµ¥´Ê.262.mp3';
[y_all, fs] =  audioread(SoundFile);

player = audioplayer(y_all, fs);

player.Userdata.stopPlayback = false;
player.stopfcn = @audioplayerLoopingStopFcn;

play(player);

WaitSecs(0.2);


