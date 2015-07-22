//
//  Jstorecord_ViewController.m
//  jstoios
//
//  Created by AndLi on 15/7/17.
//  Copyright (c) 2015年 AndLi. All rights reserved.
//

#import "Record_ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import <AVFoundation/AVFoundation.h>
#import "lame.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define NAVBAR_HEIGHT 40

#define TITLE_X (SCREEN_WIDTH/2-SCREEN_WIDTH/10)
#define TITLE_Y (1.5*NAVBAR_HEIGHT)
#define TITLE_WIDTH (SCREEN_WIDTH/5)
#define TITLE_HEIGHT NAVBAR_HEIGHT

#define RECORDBAR_X (SCREEN_WIDTH/2-SCREEN_WIDTH/4)
#define RECORDBAR_Y (TITLE_Y+TITLE_HEIGHT+NAVBAR_HEIGHT/2)
#define RECORDBAR_WIDTH (SCREEN_WIDTH/2)

#define TIME_X (SCREEN_WIDTH/2-SCREEN_WIDTH/8)
#define TIME_Y (RECORDBAR_Y+NAVBAR_HEIGHT)
#define TIME_WIDTH (SCREEN_WIDTH/4)
#define TIME_HEIGHT NAVBAR_HEIGHT

#define RECORDBUTTON_X (SCREEN_WIDTH/2-SCREEN_WIDTH/6)
#define RECORDBUTTON_Y (TIME_Y+TIME_HEIGHT+NAVBAR_HEIGHT/2)
#define RECORDBUTTON_WIDTH (SCREEN_WIDTH/3)
#define RECORDBUTTON_HEIGHT RECORDBUTTON_WIDTH

#define PLAYBUTTON_X (SCREEN_WIDTH/2-SCREEN_WIDTH/8)
#define PLAYBUTTON_Y (TIME_Y+2*TIME_HEIGHT)
#define PLAYBUTTON_WIDTH SCREEN_WIDTH/4
#define PLAYBUTTON_HEIGHT PLAYBUTTON_WIDTH

#define RECORE_BUTTON_TAG 1010
#define NEW_PLAY_BUTTON_TAG 1011
#define PAUSE_PLAY_BUTTON_TAG 1012
#define FINISH_BUTTON_TAG 1013
#define RECORDAGAIN_BUTTON_TAG 1014
#define PAUSE_BUTTON_TAG 1015

@interface Record_ViewController ()<AVAudioRecorderDelegate>
{
    UILabel* recordTitleLabel;
    UISlider* progressView;
    UILabel* timeLabel;
    UIButton* recordButton;
    UILabel* recordLabel;
    
    NSTimer* timer;
    int recordTime;
    int playTime;
    int playDuration;
    int second;
    int minute;
    
    UIButton* playButton;
    UIButton* finishButton;
    UIButton* pauseButton;
    UIButton* recordAgainButton;
    
    UILabel* playLabel;
    UILabel* finishLabel;
    UILabel* pauseLabel;
    UILabel* recordAgainLabel;
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    AVAudioSession * audioSession;
    
    NSURL* recordUrl;
    NSURL* mp3FilePath;
    NSURL* audioFileSavePath;
}
@end

@implementation Record_ViewController


- (void)viewDidLoad {
    [self initializeUI];
}

- (void)initializeUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake(PLAYBUTTON_X, PLAYBUTTON_Y, PLAYBUTTON_WIDTH, PLAYBUTTON_HEIGHT)];
    [playButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
    playButton.tag = NEW_PLAY_BUTTON_TAG;
    [playButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
    playLabel = [[UILabel alloc] initWithFrame:CGRectMake(PLAYBUTTON_X, PLAYBUTTON_Y+PLAYBUTTON_HEIGHT, PLAYBUTTON_WIDTH, NAVBAR_HEIGHT)];
    [playLabel setText:@"播放"];
    [playLabel setTextAlignment:NSTextAlignmentCenter];
    
    pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(PLAYBUTTON_X, PLAYBUTTON_Y, PLAYBUTTON_WIDTH, PLAYBUTTON_HEIGHT)];
    [pauseButton setImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateNormal];
    pauseButton.tag = PAUSE_BUTTON_TAG;
    [pauseButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
    pauseLabel = [[UILabel alloc] initWithFrame:CGRectMake(PLAYBUTTON_X, PLAYBUTTON_Y+PLAYBUTTON_HEIGHT, PLAYBUTTON_WIDTH, NAVBAR_HEIGHT)];
    [pauseLabel setText:@"暂停"];
    [pauseLabel setTextAlignment:NSTextAlignmentCenter];
    
    finishButton = [[UIButton alloc] initWithFrame:CGRectMake(PLAYBUTTON_X-PLAYBUTTON_WIDTH-10, PLAYBUTTON_Y, PLAYBUTTON_WIDTH, PLAYBUTTON_HEIGHT)];
    [finishButton setImage:[UIImage imageNamed:@"finish_button.png"] forState:UIControlStateNormal];
    finishButton.tag = FINISH_BUTTON_TAG;
    [finishButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
    finishLabel = [[UILabel alloc] initWithFrame:CGRectMake(PLAYBUTTON_X-PLAYBUTTON_WIDTH-10, PLAYBUTTON_Y+PLAYBUTTON_HEIGHT, PLAYBUTTON_WIDTH, NAVBAR_HEIGHT)];
    [finishLabel setText:@"完成"];
    [finishLabel setTextAlignment:NSTextAlignmentCenter];
    
    recordAgainButton = [[UIButton alloc] initWithFrame:CGRectMake(PLAYBUTTON_X+PLAYBUTTON_WIDTH+10, PLAYBUTTON_Y, PLAYBUTTON_WIDTH, PLAYBUTTON_HEIGHT)];
    [recordAgainButton setImage:[UIImage imageNamed:@"record_again_button.png"] forState:UIControlStateNormal];
    recordAgainButton.tag = RECORDAGAIN_BUTTON_TAG;
    [recordAgainButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
    recordAgainLabel = [[UILabel alloc] initWithFrame:CGRectMake(PLAYBUTTON_X+PLAYBUTTON_WIDTH+10, PLAYBUTTON_Y+PLAYBUTTON_HEIGHT, PLAYBUTTON_WIDTH, NAVBAR_HEIGHT)];
    [recordAgainLabel setText:@"重新录制"];
    [recordAgainLabel setTextAlignment:NSTextAlignmentCenter];
    
    recordTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_X, TITLE_Y, SCREEN_WIDTH, TITLE_HEIGHT)];
    [recordTitleLabel setText:@"录制语音"];
    
    progressView = [[UISlider alloc] initWithFrame:CGRectMake(RECORDBAR_X, RECORDBAR_Y, RECORDBAR_WIDTH, 20)];
    [progressView setThumbImage:[UIImage imageNamed:@"one.png"] forState:UIControlStateNormal];
    progressView.value = 0;
    progressView.userInteractionEnabled = NO;
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TIME_X, TIME_Y, TIME_WIDTH, TIME_HEIGHT)];
    [timeLabel setText:@"00:00"];
    [timeLabel setFont:[UIFont systemFontOfSize:32]];
    [timeLabel setTextColor:[UIColor blackColor]];
    
    recordButton = [[UIButton alloc] initWithFrame:CGRectMake(RECORDBUTTON_X, RECORDBUTTON_Y, RECORDBUTTON_WIDTH, RECORDBUTTON_HEIGHT)];
    recordButton.tag = RECORE_BUTTON_TAG;
    [recordButton addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    [recordButton setImage:[UIImage imageNamed:@"record_button.png"] forState:UIControlStateNormal];
    
    recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(RECORDBUTTON_X, RECORDBUTTON_Y+RECORDBUTTON_HEIGHT, RECORDBUTTON_WIDTH, NAVBAR_HEIGHT/2)];
    [recordLabel setText:@"点击开始"];
    [recordLabel setTextAlignment:NSTextAlignmentCenter];
    
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    //录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    //存储录音文件
    recordUrl = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"selfRecord.caf"]];
    
    //初始化
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:recordUrl settings:recordSetting error:nil];
    //开启音量检测
    audioRecorder.meteringEnabled = YES;
    audioRecorder.delegate = self;
    
    [self.view addSubview:recordTitleLabel];
    [self.view addSubview:progressView];
    [self.view addSubview:timeLabel];
    [self.view addSubview:recordButton];
    [self.view addSubview:recordLabel];
}

- (void)transformCAFToMP3 {
    mp3FilePath = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"myselfRecord.mp3"]];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([[recordUrl absoluteString] cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                                   //skip file header
        FILE *mp3 = fopen([[mp3FilePath absoluteString] cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        audioFileSavePath = mp3FilePath;
        NSLog(@"MP3生成成功: %@",audioFileSavePath);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"mp3转化成功！" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)clickOnButton:(UIButton*)sender {
    audioSession = [AVAudioSession sharedInstance];//得到AVAudioSession单例对象
    switch (sender.tag) {
            
            //开始，停止
        case RECORE_BUTTON_TAG:{
            if (![audioRecorder isRecording]) {
                [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//设置类别,表示该应用同时支持播放和录音
                [audioSession setActive:YES error:nil];//启动音频会话管理,此时会阻断后台音乐的播放.
                
                [audioRecorder prepareToRecord];
                [audioRecorder peakPowerForChannel:0.0];
                [audioRecorder record];
                recordTime = 0;
                
                [self recordTimeStart];
                [recordButton setImage:[UIImage imageNamed:@"recording_button.png"] forState:UIControlStateNormal];
                [recordLabel setText:@"点击结束"];
            }
            else{
                [audioRecorder stop];                          //录音停止
                [audioSession setActive:NO error:nil];         //一定要在录音停止以后再关闭音频会话管理（否则会报错），此时会延续后台音乐播放
                [timer invalidate];                            //timer失效
                [timeLabel setText:@"00:00"];                  //时间显示复位
                [progressView setValue:0 animated:YES];        //进度条复位
                
                [recordButton removeFromSuperview];
                [recordLabel removeFromSuperview];
                [self.view addSubview:playButton];
                [self.view addSubview:finishButton];
                [self.view addSubview:recordAgainButton];
                [self.view addSubview:playLabel];
                [self.view addSubview:finishLabel];
                [self.view addSubview:recordAgainLabel];
            }
        }
            break;
            
            //播放
        case NEW_PLAY_BUTTON_TAG:{
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [audioSession setActive:YES error:nil];
            
            if (mp3FilePath != nil) {
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:mp3FilePath error:nil];
            }
            else if (recordUrl != nil){
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordUrl error:nil];
            }
            
            [audioPlayer prepareToPlay];
            audioPlayer.volume = 1;
            [audioPlayer play];
            
            [playButton removeFromSuperview];
            [playLabel removeFromSuperview];
            [self.view addSubview:pauseButton];
            [self.view addSubview:pauseLabel];
            
            playDuration = (int)audioPlayer.duration;
            NSLog(@"音频时长为：%i",playDuration);
            playTime = 0;
            [self audioPlayTimeStart];
        }
            break;
            //暂停播放
        case PAUSE_PLAY_BUTTON_TAG:{
            [audioSession setActive:YES error:nil];
            
            [audioPlayer play];
            
            [playButton removeFromSuperview];
            [playLabel removeFromSuperview];
            [self.view addSubview:pauseButton];
            [self.view addSubview:pauseLabel];
        }
            break;
        case PAUSE_BUTTON_TAG:{
            [audioPlayer pause];
            [audioSession setActive:NO error:nil];
            
            playButton.tag = PAUSE_PLAY_BUTTON_TAG;
            [pauseButton removeFromSuperview];
            [pauseLabel removeFromSuperview];
            [self.view addSubview:playButton];
            [self.view addSubview:playLabel];
        }
            break;
            //完成
        case FINISH_BUTTON_TAG:{
            [self transformCAFToMP3];
        }
            break;
            
            //重新录制
        case RECORDAGAIN_BUTTON_TAG:{
            [audioPlayer stop];
            [audioRecorder stop];
            [audioSession setActive:NO error:nil];
            
            [timer invalidate];
            progressView.value = 0;
            [timeLabel setText:@"00:00"];
            recordTime = 0;
            playTime = 0;
            
            [playButton removeFromSuperview];
            [pauseButton removeFromSuperview];
            [finishButton removeFromSuperview];
            [recordAgainButton removeFromSuperview];
            [playLabel removeFromSuperview];
            [pauseLabel removeFromSuperview];
            [finishLabel removeFromSuperview];
            [recordAgainLabel removeFromSuperview];
            
            [self.view addSubview:recordButton];
            [self.view addSubview:recordLabel];
            [recordButton setImage:[UIImage imageNamed:@"record_button.png"] forState:UIControlStateNormal];
            [recordLabel setText:@"点击开始"];
        }
            break;
        default:
            break;
    }
}

- (void)recordTimeStart {
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordTimeTick) userInfo:nil repeats:YES];
}

- (void)recordTimeTick {
    recordTime += 1;
    [progressView setValue:(float)recordTime/30.0 animated:YES];
    if (recordTime == 30) {
        recordTime = 0;
        [audioRecorder stop];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [timer invalidate];
        [timeLabel setText:@"00:00"];
        [progressView setValue:0.0 animated:YES];
        
        [recordButton removeFromSuperview];
        [recordLabel removeFromSuperview];
        [self.view addSubview:playButton];
        [self.view addSubview:finishButton];
        [self.view addSubview:recordAgainButton];
        [self.view addSubview:playLabel];
        [self.view addSubview:finishLabel];
        [self.view addSubview:recordAgainLabel];
        return;
    }
    [self updateAudioRecordTime];
}

- (void)updateAudioRecordTime {
    minute = recordTime/60.0;
    second = recordTime-minute*60;
    
    [timeLabel setText:[NSString stringWithFormat:@"%02d:%02d",minute,second]];
}

- (void)audioPlayTimeStart {
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playTimeTick) userInfo:nil repeats:YES];
}

- (void)playTimeTick {
    if (playDuration == playTime) {
        playTime = 0;
        [audioPlayer stop];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        [pauseButton removeFromSuperview];
        [pauseLabel removeFromSuperview];
        [self.view addSubview:playButton];
        [self.view addSubview:playLabel];
        
        playButton.tag = NEW_PLAY_BUTTON_TAG;
        
        [timeLabel setText:@"00:00"];
        [timer invalidate];
        progressView.value = 0;
        return;
    }
    if (![audioPlayer isPlaying]) {
        return;
    }
    playTime += 1;
    [progressView setValue:(float)playTime/(float)playDuration animated:YES];
    [self updateAudioPlayTime];
}

- (void)updateAudioPlayTime {
    minute = playTime/60.0;
    second = playTime-minute*60;
    
    [timeLabel setText:[NSString stringWithFormat:@"%02d:%02d",minute,second]];
}

//AVAudioRecorderDelegate方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [audioSession setActive:NO error:nil];
    
    playTime = 0;
    
    [pauseButton removeFromSuperview];
    [pauseLabel removeFromSuperview];
    [self.view addSubview:playButton];
    [self.view addSubview:playLabel];
    
    playButton.tag = NEW_PLAY_BUTTON_TAG;
    
    [timeLabel setText:@"00:00"];
    [timer invalidate];
    progressView.value = 0;
}

@end

