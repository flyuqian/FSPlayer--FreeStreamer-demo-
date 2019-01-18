//
//  ViewController.m
//  FSPlayer
//
//  Created by IOS3 on 2019/1/18.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import "ViewController.h"
#import "FSPlayer.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, strong) FSPlayer *player;

@property (nonatomic, strong) NSArray<NSURL *> *musics;
@property (nonatomic, assign) NSInteger playIndex;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    self.playIndex = 0;
    self.musics = @[
                    [NSURL URLWithString:@"http://1256014700.vod2.myqcloud.com/0b6a2d99vodgzp1256014700/d8cb4f3b7447398156679039248/f0.aac"],
                    [NSURL URLWithString:@"http://mr1.doubanio.com/f2b04c69eb8d93e3de4748e50e11600e/0/fm/song/p453_128k.mp4"],
                    [NSURL fileURLWithPath:[NSBundle.mainBundle pathForResource:@"秋意浓" ofType:@"mp3"]],
                    [NSURL fileURLWithPath:[NSBundle.mainBundle pathForResource:@"如果这都不算爱" ofType:@"mp3"]],
                    [NSURL fileURLWithPath:[NSBundle.mainBundle pathForResource:@"一路上有你" ofType:@"mp3"]],
                    [NSURL fileURLWithPath:[NSBundle.mainBundle pathForResource:@"一千个伤心的理由" ofType:@"mp3"]],
                    ];
    //    [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    //    [self.playButton setTitle:@"播放" forState:UIControlStateSelected];
    
    self.slider.value = 0.0;
    self.player = [FSPlayer sharedInstance];
    
    
    
    [self.player startAudioStreamStopedWithSource:self.musics[self.playIndex]];
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    
    //    [self.player startAudioStreamPlayedWithSource:self.musics[self.playIndex]];
    //    [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    
    
    __weak typeof(self)weakSelf = self;
    self.player.playArgumentsChanged = ^(NSString * _Nonnull totalTime, NSString * _Nonnull passedTime, NSString * _Nonnull residualTime, CGFloat progress) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.label1.text = totalTime;
        strongSelf.label2.text = passedTime;
        strongSelf.label3.text = residualTime;
        strongSelf.slider.value = progress;
    };
    self.player.shouldPlayNext = ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.playIndex++;
        [strongSelf.player startAudioStreamPlayedWithSource:strongSelf.musics[strongSelf.playIndex]];
    };
}



- (IBAction)playPausBtnClick:(UIButton *)sender {
    
    if (!self.player.isInitialCompleted) {
        [self.player initialPaly];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        return;
    }
    [self.player playPaus];
    if (self.player.isPlaying) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    }
    else {
        [sender setTitle:@"播放" forState:UIControlStateNormal];
    }
    
}
- (IBAction)lastBtnClick:(UIButton *)sender {
    self.playIndex--;
    [self.player startAudioStreamPlayedWithSource:self.musics[self.playIndex]];
    if (self.player.isPlaying) {
        [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
}
- (IBAction)nextBtnClick:(UIButton *)sender {
    self.playIndex++;
    [self.player startAudioStreamPlayedWithSource:self.musics[self.playIndex]];
    if (self.player.isPlaying) {
        [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
}
- (IBAction)sliderChanged:(UISlider *)sender {
    //    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeProgress:) object:nil];
    //    [self performSelector:@selector(changeProgress:) withObject:nil afterDelay:0.2];
    [self.player changeProgress:sender.value];
}

//- (void)playPauseAction:(UIButton *)sender {
//    [self.player playPaus];
//    sender.selected = !sender.selected;
//}
//- (void)changeProgressAction:(UISlider *)sender {
//    [self.player changeProgress:sender.value];
//}

- (void)setPlayIndex:(NSInteger)playIndex {
    if (playIndex < 0) {
        _playIndex = self.musics.count - 1;
    }
    else if (playIndex > (self.musics.count - 1)) {
        _playIndex = 0;
    }
    else {
        _playIndex = playIndex;
    }
}


- (void)dealloc {
    [self.player stop];
}



@end
