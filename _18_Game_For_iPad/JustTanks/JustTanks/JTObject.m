//
//  JTObject.m
//  JustTanks
//
//  Created by Exo-terminal on 4/1/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import "JTObject.h"
#import "JTGameScene.h"


@implementation JTObject

-(id) initWithSprite: (CCSprite*) sprt scene: (JTGameScene*) scene properties: (NSDictionary*) props{
    if (self = [super init]) {
        
        _winSize = [CCDirector sharedDirector].winSize;
        
        _scene = scene;
        _sprite = sprt;
        [self addChild:sprt];
        [self schedule:@selector(update:)];
        
        
    }
    return self;
}

-(void) update: (float) dt{
    
}

@end
