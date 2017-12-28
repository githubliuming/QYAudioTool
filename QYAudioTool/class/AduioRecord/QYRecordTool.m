//
//  QYRecordTool.m
//  QYAudioTool
//
//  Created by liuming on 2017/12/26.
//  Copyright © 2017年 yoyo. All rights reserved.
//

#import "QYRecordTool.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface QYRecordTool()<AVAudioRecorderDelegate>
@property(nonatomic,strong) AVAudioRecorder  * recorder;
@end
@implementation QYRecordTool
- (instancetype) init{
    
    self = [super init];
    if (self)
    {
        
    }
    return self;
}
- (BOOL)configAudioSession
{
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError * error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setActive:YES error:&error];
    if (error)
    {
        
        NSLog(@"配置失败 当前使用的模式是 :%@  error info = %@",session.mode,error);
    } else {
        
        NSLog(@"配置成功，当前使用的模式是 AVAudioSessionCategoryPlayAndRecord");
    }
    
    return (error == nil);
}
- (void)confingRecorderWithSettingDic:(NSDictionary<NSString * ,id> *)settingDic
                             filePath:(NSString *)filePath{
    
    [self configAudioSession];
    if (!settingDic)
    {
        
        /////LinearPCM 是iOS的一种无损编码格式,但是体积较为庞大
        //录音设置
       // NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
        //录音格式 无法使用
       // [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        //采样率
       // [recordSettings setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];//44100.0
        //通道数
      //  [recordSettings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
        //线性采样位数
        //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
        //音频质量,采样质量
        //[recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
        
        NSLog(@"配置字典wei nil 使用默认配置字典");
        settingDic = @{AVFormatIDKey:@(kAudioFormatLinearPCM),
                       AVSampleRateKey:@(8000),
                       AVNumberOfChannelsKey:@1,
                       AVEncoderAudioQualityKey:@(AVAudioQualityMin),
                       AVLinearPCMBitDepthKey:@(8),
                       AVLinearPCMIsFloatKey:@(YES)
                       };
    }
    if (filePath.length == 0)
    {
        NSLog(@"文件输出路径为空，使用默认路径");
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
        filePath = [documentPath stringByAppendingPathComponent:@"audioRecord/"];
        
        if (![[NSFileManager  defaultManager] fileExistsAtPath:filePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        filePath = [NSString stringWithFormat:@"%@/record.caf",filePath];
    }
    NSError * error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath]
                                                settings:settingDic error:&error];
    self.recorder.meteringEnabled = YES;
    self.recorder.delegate = self;
    if (error)
    {
        NSLog(@"初始化 recorder 失败 ,error info = %@",[error userInfo]);
    } else {
        
        NSLog(@"初始化 recorder 成功");
    }
}

- (void)startRecord
{
    BOOL result = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(qyRecorderWillRecording:)])
    {
       result = [self.delegate qyRecorderWillRecording:self.recorder];
    }
    
    if (result)
    {
        _status = QYRecordStatusWillRecord;
        if ([self.recorder prepareToRecord])
        {
            [self micPhonePermissions:^(BOOL ishave)
             {
                 _status = QYRecordStatusRecording;
                 [self.recorder record];
                 if (self.delegate && [self.delegate respondsToSelector:@selector(qyRecorderDidRecording:)])
                 {
                     [self.delegate qyRecorderDidRecording:self.recorder];
                 }
             }];
        } else {
            
            NSLog(@"prepare to recrod error");
        }
    }
    
}

/**
 结束录制
 */
- (void)endRecord
{
    [self.recorder stop];
}

/**
 暂停录制
 */
- (void) pauseRecord
{
    if ([self.recorder isRecording])
    {
        _status = QYRecordStatusPause;
        [self.recorder pause];
    }
}

- (void)resumeRecord{
    
    if (_status == QYRecordStatusPause)
    {
        _status = QYRecordStatusRecording;
        [self.recorder record];
    }
    
}
/**
 取消录制
 */
- (void) cancelRecord
{
    [self.recorder stop];
    [self.recorder deleteRecording];
    _status = QYRecordStatusRest;
}

#pragma mark - AVAudioRecorderDelegate代理方法
/* 完成录音会调用 */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    //录音完成后自动播放录音
    if (flag)
    {
        _status = QYRecordStatusRest;
        if (self.delegate &&  [self.delegate respondsToSelector:@selector(qyRecorderFinishRecord:fileUrl:)])
        {
            [self.delegate qyRecorderFinishRecord:self.recorder fileUrl:self.recorder.url];
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    //录音编码出错信息
    if (self.delegate && [self.delegate respondsToSelector:@selector(qyRecorder:error:)])
    {
        _status = QYRecordStatusRest;
        [self.delegate qyRecorder:recorder error:error];
    }
}

// 判断麦克风权限
- (void)micPhonePermissions:(void (^)(BOOL ishave))block  {
    __block BOOL ret = NO;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if (available) ret = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block(ret);
            });
        }];
    }
}

- (void)showPermissionsAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法录音" message:@"请在“设置-隐私-麦克风”中允许访问麦克风。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
