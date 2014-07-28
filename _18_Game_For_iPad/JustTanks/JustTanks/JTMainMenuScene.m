//
//  JTMainMenuScene.m
//  JustTanks
//
//  Created by Exo-terminal on 4/9/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import "JTMainMenuScene.h"
#import "JTSelectLevelScene.h"


@implementation JTMainMenuScene
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	JTMainMenuScene *layer = [JTMainMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLayerColor* lc = [CCLayerColor layerWithColor:ccc4(227, 207, 113, 225)];
        [self addChild:lc];
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"Just Tanks!" fontName:@"Avenir" fontSize:100];
        label.position = ccp(winSize.width /2, winSize.height - 130);
        label.color = ccc3(70, 88, 36);
        [self addChild:label];
        
        
        CCMenuItemImage* itemPlay = [CCMenuItemImage itemWithNormalImage:@"bttn_play.png" selectedImage:@"bttn_play_pressed.png" block:^(id sender) {
            [[CCDirector sharedDirector]replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5 scene:[JTSelectLevelScene scene]]];
            
        }];
        
        CCMenuItemImage* itemSetting = [CCMenuItemImage itemWithNormalImage:@"bttn_settings.png" selectedImage:@"bttn_settings_pressed.png" block:^(id sender) {
            
        }];
        
        CCMenu* menu = [CCMenu menuWithItems:itemPlay,itemSetting, nil];
        [menu alignItemsVerticallyWithPadding:60];
        [self addChild:menu];
        
    }
    return self;
}


@end
