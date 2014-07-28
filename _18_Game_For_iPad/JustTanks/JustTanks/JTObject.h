//
//  JTObject.h
//  JustTanks
//
//  Created by Exo-terminal on 4/1/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@class JTGameScene;

@interface JTObject : CCNode {
    
}

@property (strong, nonatomic) CCSprite* sprite;
@property (unsafe_unretained, nonatomic) JTGameScene* scene;
@property (assign, nonatomic) CGSize winSize;
@property (assign, nonatomic)int health;
@property (assign, nonatomic)int allHealth;

-(id) initWithSprite: (CCSprite*) sprt scene: (JTGameScene*) scene properties: (NSDictionary*) props;
-(void) update: (float) dt;

@end
