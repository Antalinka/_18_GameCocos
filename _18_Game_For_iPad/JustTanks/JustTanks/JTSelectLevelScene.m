//
//  JTSelectLevelScene.m
//  JustTanks
//
//  Created by Exo-terminal on 4/9/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import "JTSelectLevelScene.h"
#import "JTGameScene.h"

@implementation JTSelectLevelScene
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	JTSelectLevelScene *layer = [JTSelectLevelScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if (![[NSUserDefaults standardUserDefaults] integerForKey:key_open_level]) {
            
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:key_open_level];
            
        }
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLayerColor* lc = [CCLayerColor layerWithColor:ccc4(200, 180, 100, 225)];
        [self addChild:lc];
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"Select level" fontName:@"Avenir" fontSize:100];
        label.position = ccp(winSize.width /2, winSize.height - 80);
        label.color = ccc3(70, 88, 36);
        [self addChild:label];
        
        NSMutableArray* array = [[NSMutableArray alloc]init];
        int counter = 1;
        
        for (int y = 4; y >= 0; y--) {
            
            for (int x = 0; x < 8; x++) {
                
                if ([[NSUserDefaults standardUserDefaults] integerForKey:key_open_level] >= counter) {
                    
                    CCMenuItemImage* item = [CCMenuItemImage itemWithNormalImage:@"box.png" selectedImage:@"box_pressed.png" block:^(CCMenuItemImage* sender) {
                        
                        [[CCDirector sharedDirector]replaceScene:[CCTransitionFadeDown transitionWithDuration:0.5 scene:[JTGameScene sceneWithLevel:sender.tag]]];
                        
                    }];
                    item.position = ccp(120 + x * 110, 100 + y * 110);
                    item.tag = counter;
                    
                    [array addObject:item];
                    
                    CCLabelTTF* label1 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", counter] fontName:@"Avenir" fontSize:35];
                    label1.position = ccp(item.contentSize.width/2 , item.contentSize.height/2);
                    [item addChild:label1];
                }else{
                    CCSprite* box = [CCSprite spriteWithFile:@"box.png"];
                    box.position = ccp(120 + x * 110, 100 + y * 110);
                    [self addChild:box];
                    
                    CCSprite* lock = [CCSprite spriteWithFile:@"lock.png"];
                    lock.position = ccp(box.contentSize.width/2, box.contentSize.height/2);
                    [box addChild:lock];
                }
                counter++;

            }
            
        }
        CCMenu* menu = [CCMenu menuWithArray:array];
        menu.position = ccp(0,0);
        [self addChild:menu];

        
      }
    return self;
}



@end
