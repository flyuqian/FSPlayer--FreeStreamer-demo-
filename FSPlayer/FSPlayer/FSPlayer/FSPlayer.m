//
//  FSPlayer.m
//  ProjectDemo
//
//  Created by IOS3 on 2018/11/15.
//  Copyright © 2018 IOS3. All rights reserved.
//

#import "FSPlayer.h"
#import <FSAudioStream.h>

#ifdef DEBUG
#define fsp_log(fmt, ...) NSLog((@"\n ####### FSPlayer: " fmt),  ##__VA_ARGS__);
#else
#define fsp_log(...)
#endif
@interface FSPlayer ()

/// 总时长
@property (nonatomic, strong) NSString *totalTime;
/// 已经播放时长
@property (nonatomic, strong) NSString *passedTime;
/// 剩余时长
@property (nonatomic, strong) NSString *residualTime;
/// 播放进度, 百分百
@property (nonatomic, assign) CGFloat progress;


@property (nonatomic, strong) FSAudioStream *audioStream;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) float volume;

@end


@implementation FSPlayer

+ (instancetype)sharedInstance {
    static FSPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}


#pragma mark - initial

// 初始化音频资源, 默认播放
- (void)startAudioStreamPlayedWithSource:(NSURL *)source {
    [self startAudioStreamStopedWithSource:source];
    [self initialPaly];
}

// 初始化音频资源, 默认音频停止
- (void)startAudioStreamStopedWithSource:(NSURL *)source {
    if (self.audioStream) {
        [self.audioStream stop];
        self.audioStream = nil;
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.audioStream = FSAudioStream.new;
    // 播放失败的回调
    self.audioStream.onFailure = ^(FSAudioStreamError error, NSString *errorDescription) {
        fsp_log(@"播放失败: %@", errorDescription);
    };
    // 播放完成的回调
    __weak typeof(self)weakSelf = self;
    self.audioStream.onCompletion = ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        fsp_log(@"播放完成");
        if (strongSelf.shouldPlayNext) {
            strongSelf.shouldPlayNext();
        }
    };
    // FreeStreamAudio 的转态回调
    self.audioStream.onStateChange = ^(FSAudioStreamState state) {
        // kFsAudioStreamStopped kFsAudioStreamBuffering kFSAudioStreamEndOfFile kFsAudioStreamPlaying  ...
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (state == kFsAudioStreamFailed || state == kFsAudioStreamRetryingFailed) {
            if (strongSelf.shouldPlayNext) {
                strongSelf.shouldPlayNext();
            }
        }
    };
    
    
    self.audioStream.url = source;
    [self.audioStream preload];
    _progress = 0.0;
    _playing = false;
    _initialCompleted = false;
}


/**
 初始化播放, 默认播放的音频已内部调用
 */
- (void)initialPaly {
    [self.audioStream play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(playArguments) userInfo:nil repeats:YES];
    _playing = true;
    _initialCompleted = true;
}




- (void)playArguments {
    FSStreamPosition position = self.audioStream.currentTimePlayed;
    
    _progress = position.position;
    
    if (self.progress == 1) {
        if (self.shouldPlayNext) {
            self.shouldPlayNext();
        }
    }
    float playbackTime = position.playbackTimeInSeconds/1;
    double hourElapsed = floor(playbackTime/(60*60.0));
    double minutesElapsed =floor(fmod(playbackTime/60.0,60.0));
    double secondsElapsed =floor(fmod(playbackTime,60.0));
    if (hourElapsed > 0) {
        _passedTime = [NSString stringWithFormat:@"播放: %02.0f:%02.0f:%02.0f",hourElapsed, minutesElapsed, secondsElapsed];
    }
    else {
        _passedTime = [NSString stringWithFormat:@"播放: %02.0f:%02.0f",minutesElapsed, secondsElapsed];
    }
    
    float total = position.playbackTimeInSeconds / position.position;
    double totalHour = floor(total / (60 * 60.0));
    double totalMinutes =floor(fmod(total/60.0,60.0));
    double totalSeconds =floor(fmod(total,60.0));
    if (total > 0) {
        _totalTime = [NSString stringWithFormat:@"播放: %02.0f:%02.0f:%02.0f", totalHour, totalMinutes, totalSeconds];
    }
    else {
        _totalTime = [NSString stringWithFormat:@"播放: %02.0f:%02.0f",totalMinutes, totalSeconds];
    }
    
    // 剩余总时长
    float residualTime = position.playbackTimeInSeconds / position.position - position.playbackTimeInSeconds;
    float residualHour = floor(residualTime / (60 * 60));
    float residualMinutes = floor(fmod(residualTime / 60.0, 60.0));
    float residualSeconds = floorf(fmod(residualTime, 60.0));
    NSString *residualStr = [NSString stringWithFormat:@"%02.0f:%02.0f", residualMinutes, residualSeconds];
    if (residualHour > 0) {
         residualStr = [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f", residualHour, residualMinutes, residualSeconds];
    }
    
    if ([residualStr isEqualToString:@"nan:nan"]) {
        residualStr = @"00:00";
    }
    _residualTime = residualStr;
    
    if (self.playArgumentsChanged) {
        self.playArgumentsChanged(self.totalTime, self.passedTime, self.residualTime, self.progress);
    }
    if (self.playArgumentsValueChanged) {
        self.playArgumentsValueChanged(position.playbackTimeInSeconds, position.position);
    }
}






#pragma mark - play control
- (void)playPaus {
    
    if (self.audioStream.isPlaying) {
        [self.audioStream pause];
        [self.timer setFireDate:[NSDate distantFuture]];
        _playing = false;
    }
    else {
        [self.audioStream pause];
        [self.timer setFireDate:[NSDate distantPast]];
        _playing = true;
    }
}

- (void)changeProgress:(float)progress {
    if (progress == 1) {
        if (self.shouldPlayNext) {
            self.shouldPlayNext();
        }
    }
    else if (progress >= 0) {
        FSStreamPosition position = {0};
        position.position = progress;
        [self.audioStream seekToPosition:position];
        
//        FSSeekByteOffset offset = {0};
//        offset.position = progress;
//        [self.audioStream playFromOffset:offset];
    }
}

- (void)clearCaches {
    [self.audioStream expungeCache];
}

- (void)stop {
    if (self.audioStream) {
        [self.audioStream stop];
        self.audioStream = nil;
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}




@end
