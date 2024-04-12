//
//  SdkLib.h
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

#ifndef SdkLib_h
#define SdkLib_h

#import <Foundation/Foundation.h>

@interface SdkLib: NSObject {
    @public
    void* _piano;
}
-(void)initialize;
-(void)loadModel: (const char*) path;
-(void)loadClsModel: (const char*) path;
-(void)loadLicense: (NSString*) license;
-(void)setMode: (int) mode;
-(void)setThread: (int) thread;
-(void)setLowThreshold: (float) thres;
-(void)setCheckPercent: (float) percent;
-(void)loadScore: (NSString*) document;
-(void)prepare;
-(bool)skipNext;
-(bool)shouldGoNext: (float *) buffer andLength: (int) length ;
-(NSArray *) keysAtHostTime: (float *) buffer length: (int) length andHostTime: (int) hostTime;
-(int)noteIndexToGo: (float *) buffer andLength: (int) length ;
-(NSArray *)getScore;
-(NSString *)getReport;
-(NSArray *) compute: (float *) buffer length: (int) length;

@end


#endif /* SdkLib_h */
