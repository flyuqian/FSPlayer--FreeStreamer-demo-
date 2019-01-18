//
// https://github.com/flyuqian/FSPlayer--FreeStreamer-demo-
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSPlayer : NSObject

/// 单例
+ (instancetype)sharedInstance;


/**
 初始化音频资源, 默认播放

 @param source URL, 播放资源
 */
- (void)startAudioStreamPlayedWithSource:(NSURL *)source;

/**
 初始化音频资源, 默认音频停止  ** 必须通过 initialPaly 方法开启播放 **

 @param source URL, 播放资源
 */
- (void)startAudioStreamStopedWithSource:(NSURL *)source;

/**
 初始化播放, 默认播放的音频已内部调用
 */
- (void)initialPaly;

/// 暂停和播放
- (void)playPaus;



/// 是否正在播放
@property (nonatomic, assign, getter=isPlaying, readonly) BOOL playing;
/// 是否初始化完成, 区别两个startAudioStream方法, 为初始化完成的, 通过initialPaly完成初始化
@property (nonatomic, assign, getter=isInitialCompleted, readonly) BOOL initialCompleted;

/// 每秒播放信息回调
@property (nonatomic, copy) void(^playArgumentsChanged)(NSString *totalTime, NSString *passedTime, NSString *residualTime, CGFloat progress);
/// 每秒播放信息回调
@property (nonatomic, copy) void(^playArgumentsValueChanged)(CGFloat playbackTimeInSecond, CGFloat progress);
/// 应该播放下一首歌曲
@property (nonatomic, copy) void(^shouldPlayNext)(void);



/**
 更改播放进度

 @param progress 0...1
 */
- (void)changeProgress:(float)progress;


/**
 清理 FSAudioStream 缓存
 */
- (void)clearCaches;



/**
 停止播放器, 将播放器和回调Timer 置空
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
