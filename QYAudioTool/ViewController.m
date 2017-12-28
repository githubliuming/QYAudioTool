//
//  ViewController.m
//  QYAudioTool
//
//  Created by liuming on 2017/12/26.
//  Copyright © 2017年 yoyo. All rights reserved.
//
// 1、音频的录制
#import "ViewController.h"
#import "QYRecordTool.h"
#import "ExtAudioConverter.h"
@interface ViewController ()<QYRecordToolDelegate>
@property(nonatomic,strong)QYRecordTool * recordTool;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.recordTool = [[QYRecordTool alloc] init];
    [self.recordTool confingRecorderWithSettingDic:nil filePath:nil];
    self.recordTool.delegate = self;
}

- (IBAction)startRecord:(id)sender
{
    [self.recordTool startRecord];
}
- (IBAction)endRecord:(id)sender
{
    [self.recordTool endRecord];
}

- (BOOL)qyRecorderWillRecording:(AVAudioRecorder *)recorder{
    
    //将要录音
    NSLog(@"将要录音");
    return YES;
}
- (void)qyRecorderDidRecording:(AVAudioRecorder *)recorder{
    
    NSLog(@"开始录音");
}
- (void)qyRecorderDidpauseRecord:(AVAudioRecorder *)recorder{
    
    NSLog(@"暂停录音");
    
}
- (void)qyRecorderCancelRecord:(AVAudioRecorder *)recorder{
    
    NSLog(@"取消录音");
}
- (void)qyRecorderFinishRecord:(AVAudioRecorder *)recorder
                       fileUrl:(NSURL *)fileUrl{
    NSURL * url = [fileUrl URLByDeletingPathExtension];
    url = [url URLByAppendingPathExtension:@"mp3"];
    NSLog(@"录音结束 录音文件在 %@",[fileUrl path]);
    ExtAudioConverter * converter = [[ExtAudioConverter alloc] init];
    converter.inputFile =  [fileUrl path];
    converter.outputFile = [url path];
    converter.outputSampleRate = 44100 ;
    converter.outputNumberChannels = 1;
    converter.outputBitDepth = BitDepth_16;
    converter.outputFormatID = kAudioFormatMPEGLayer3 ;
    converter.outputFileType = kAudioFileMP3Type;
    [converter convert];
}
- (void)qyRecorder:(AVAudioRecorder *)recorder error:(NSError *)error
{
    
    NSLog(@"录音出错  error = %@",[error userInfo]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
