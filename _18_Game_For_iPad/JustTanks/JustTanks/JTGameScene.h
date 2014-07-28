//
//  JTGameScene.h
//  JustTanks
//
//  Created by Exo-terminal on 3/31/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "JTPlayerTank.h"
#import "JTObject.h"
#import "JTMainMenuScene.h"

//KEYS
#define key_position          @"key_position"
#define key_rotation          @"key_rotation"
#define key_shot_distance     @"key_shot_distance"
#define key_health            @"key_health"
#define key_damage            @"key_damage"
#define key_move_speed        @"key_move_speed"
#define key_rot_speed         @"key_rot_speed"
#define key_appearing_delay   @"key_appearing_delay"

#define key_open_level        @"key_open_level"







//TAGS
#define player_tag 2000
#define life_icon_tag 2001
#define bullet_icon_tag 2002
#define pressed_tag 2003
#define move_tag 2004
#define rot_tag 2005
#define bullet_tag 2006

//MAX
#define max_bullets 20
#define max_lives 3

//DELAYS
#define trace_duration 10
#define kFadingTime 6
#define delay_after_shot 1
#define trace_duration 10
//#define rot_speed 40
//#define move_speed 120
#define bonus_interval 12
#define bonus_duration 7


#define offset_y 35

@interface JTGameScene : CCLayer {
    
}

@property (assign, nonatomic) BOOL isMovingForward;
@property (assign, nonatomic) BOOL isMovingBack;
@property (assign, nonatomic) BOOL isRotatingLeft;
@property (assign, nonatomic) BOOL isRotatingRight;
@property (strong, nonatomic) NSMutableArray* wallsArray;
@property (strong, nonatomic) NSMutableArray* enemiesArray;
@property (strong, nonatomic) JTPlayerTank* playerTank;
@property (assign, nonatomic)int lives;

+(CCScene *) sceneWithLevel: (int)level;
-(CGRect) getRectFromSprite: (CCSprite*) sprt;
-(void) createPlayer;
-(void) updateBulletsIcons;
-(void) updateLifeIcons;
-(CGRect) getRectFromObject: (JTObject*) object;
-(void) createEnemyWithDProperties: (NSDictionary*) dict;

@end
