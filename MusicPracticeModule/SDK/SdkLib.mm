//
//  SdkLib.m
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

#import <Foundation/Foundation.h>
#import "Piano.h"
#import "SdkLib.h"

using namespace enjoymusic;
using namespace piano;

@implementation SdkLib

-(void)initialize {
    _piano = new Piano();
}

-(void)loadModel: (const char*) path {
    Piano *_p = (Piano *)_piano;
    _p->loadModel((char *)path, true);
}

-(void)loadClsModel: (const char*) path; {
    Piano *_p = (Piano *)_piano;
    _p->loadClsModel((char *)path);
}

-(void)loadLicense: (NSString*) license {
    Piano *_p = (Piano *)_piano;
    std::string lic([license UTF8String]);
    _p->loadLicense(lic);
}

-(void)setMode: (int) mode {
    Piano *_p = (Piano *)_piano;
    _p->setMode(mode);
}

-(void)setThread: (int) thread {
    Piano *_p = (Piano *)_piano;
    _p->setThread(thread);
}

-(void)setLowThreshold: (float) thres {
    Piano *_p = (Piano *)_piano;
    _p->setLowThreshold(thres);
}

-(void) setCheckPercent: (float) percent {
    Piano *_p = (Piano *)_piano;
    _p->setCheckPercent(percent);
}

-(void)loadScore: (NSString*) document {
    Piano *_p = (Piano *)_piano;
    std::string doc([document UTF8String]);
    NSLog(@"yoyoyo%@", document );
    _p->loadScore(doc);
}

-(void)prepare {
    Piano *_p = (Piano *)_piano;
    _p->prepare();
}

-(bool)skipNext {
    Piano *_p = (Piano *)_piano;
    return _p->skipNext();
}

-(bool)shouldGoNext: (float *) buffer andLength: (int) length {
    Piano *_p = (Piano *)_piano;
    std::vector<float> buf{buffer, buffer + length};
    return _p->shouldGoNext(buf, length);
}

-(int)noteIndexToGo: (float *) buffer andLength: (int) length {
    Piano *_p = (Piano *)_piano;
    std::vector<float> buf{buffer, buffer + length};
    return _p->noteIndexToGo(buf, length);
}

-(NSArray *) keysAtHostTime: (float *) buffer length: (int) length andHostTime: (int) hostTime {
    Piano *_p = (Piano *)_piano;
    std::vector<float> buf{buffer, buffer + length};
    std::vector<int> keys = _p->keysAtHostTime(buf, length, hostTime);
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:keys.size()];
    for (int i = 0; i < keys.size(); i ++) {
        NSNumber *number = [NSNumber numberWithFloat:keys[i]];
        [mutableArray addObject:number];
    }
    return [NSArray arrayWithArray:mutableArray];
}

-(NSArray *) compute: (float *) buffer length: (int) length; {
    Piano *_p = (Piano *)_piano;
    std::vector<float> buf{buffer, buffer + length};
    std::vector<int> keys = _p->compute(buf);
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:keys.size()];
    for (int i = 0; i < keys.size(); i ++) {
        NSNumber *number = [NSNumber numberWithFloat:keys[i]];
        [mutableArray addObject:number];
    }
    return [NSArray arrayWithArray:mutableArray];
}


-(NSArray *)getScore {
    Piano *_p = (Piano *)_piano;
    std::vector<float> score = _p->getScore();
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:score.size()];
    for (int i = 0; i < score.size(); i ++) {
        NSNumber *number = [NSNumber numberWithFloat:score[i]];
        [mutableArray addObject:number];
    }
    return [NSArray arrayWithArray:mutableArray];
}

-(NSString *)getReport {
    Piano *_p = (Piano *)_piano;
    std::string resultString = _p->getReport();
    NSString* result = [NSString stringWithUTF8String:resultString.c_str()];
    return result;
}

- (void)dealloc {
    Piano *_p = (Piano *)_piano;
    delete _p;
}

@end
