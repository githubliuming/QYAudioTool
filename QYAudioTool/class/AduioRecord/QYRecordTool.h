//
//  QYRecordTool.h
//  QYAudioTool
//
//  Created by liuming on 2017/12/26.
//  Copyright © 2017年 yoyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAudioRecorder;
typedef NS_ENUM(NSInteger,QYRecordStatus)
{
    
    QYRecordStatusRest,       //休闲状态
    QYRecordStatusWillRecord, //将要录制状态
    QYRecordStatusRecording,  //正在录制状态
    QYRecordStatusPause,      //暂停状态
};
@protocol QYRecordToolDelegate<NSObject>

- (BOOL)qyRecorderWillRecording:(AVAudioRecorder *)recorder;
@end
@interface QYRecordTool : NSObject

@property(nonatomic,assign,readonly)QYRecordStatus status;
@property(nonatomic,weak)id<QYRecordToolDelegate> delegate;
/**
 配置录音器
 @param settingDic 录音器配置字典
 @param filePath 录音文件输出路径
 */
- (void)confingRecorderWithSettingDic:(NSDictionary<NSString * ,id> *)settingDic
                             filePath:(NSString *)filePath;

/**
 开始录制
 */
- (void)startRecord;

/**
 结束录制
 */
- (void)endRecord;

/**
 暂停录制
 */
- (void) pauseRecord;

/**
 取消录制
 */
- (void) cancelRecord;
@end
