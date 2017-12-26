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

//- (instancetype) shareInstanced
//{
//    static QYRecordTool * tool;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (!tool)
//        {
//            tool = [[QYRecordTool alloc] init];
//        }
//    });
//    return tool;
//}
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
  BOOL result = [session setMode:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!result)
    {
        
        NSLog(@"配置失败 当前使用的模式是 :%@  error info = %@",session.mode,[error userInfo]);
    } else {
        
        NSLog(@"配置成功，当前使用的模式是 AVAudioSessionCategoryPlayAndRecord");
    }
    
    return result;
}
- (void)confingRecorderWithSettingDic:(NSDictionary<NSString * ,id> *)settingDic
                             filePath:(NSString *)filePath{
    
    if (!settingDic)
    {
        NSLog(@"配置字典wei nil 使用默认配置字典");
        settingDic = @{AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                       AVSampleRateKey:@22050.0f,
                       AVNumberOfChannelsKey:@1,
                       AVEncoderAudioQualityKey:@(AVAudioQualityMin)
                       };
    }
    if (filePath.length == 0)
    {
        NSLog(@"文件输出路径为空，使用默认路径");
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
        filePath = [documentPath stringByAppendingPathComponent:@"audioRecord/record.mp3"];
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
        [self micPhonePermissions:^(BOOL ishave) {
           
            
        }];
    }
    if ([self.recorder prepareToRecord])
    {
        
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
