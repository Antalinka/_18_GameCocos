//
//  JTGameScene.m
//  JustTanks
//
//  Created by Exo-terminal on 3/31/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import "JTGameScene.h"
#import "JTObject.h"
#import "SimpleAudioEngine.h"
#import "JTEnemyTank.h"
#import "JTBonus.h"

@interface JTGameScene()
@property (unsafe_unretained, nonatomic) CGSize winSize;
@property (strong, nonatomic) CCSprite* rotLeft;
@property (strong, nonatomic) CCSprite* rotRight;
@property (strong, nonatomic) CCSprite* moveForward;
@property (strong, nonatomic) CCSprite* moveBack;
@property (strong, nonatomic) CCSprite* attack;
@property (assign, nonatomic) ALuint engineSound;
@end

@interface JTGameScene (private)

-(CCSprite*) buttonWithName:(NSString*) name pressedName: (NSString*) pressedName pos:(CGPoint) pos flipX:(BOOL) flipX flipY:(BOOL) flipY;
-(void) createEnemyWithPosition: (CGPoint) pos;

@end

@implementation JTGameScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	JTGameScene *layer = [JTGameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

#pragma mark - INIT -

-(id)init{
    if (self == [super init]) {
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"real_war.mp3" loop:YES];
        _wallsArray = [[NSMutableArray alloc]init];
        _enemiesArray = [[NSMutableArray alloc]init];
        
        
        self.winSize = [CCDirector sharedDirector].winSize;
        
        CCLayerColor* lc = [CCLayerColor layerWithColor:ccc4(20, 35, 20, 255)];
        [self addChild:lc];
        
        NSDictionary* dict = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Level_1" ofType:@"plist"]];
        NSArray* array = [dict objectForKey:@"Walls"];
        
        for (NSDictionary *wallDict in array) {
            CCSprite* wall = [CCSprite spriteWithFile:@"brickWall.png"];
            wall.position = ccp([[wallDict objectForKey:@"x"]floatValue], [[wallDict objectForKey:@"y"]floatValue]);
            [self addChild:wall];
            
            [_wallsArray addObject:wall];
        }
        
        _lives = max_lives;
        
        [self createPlayer];
        
        [self createEnemyWithPosition:ccp(300, 400)];
//        [self createEnemyWithPosition:ccp(700, 400)];

        
        
        _rotLeft = [self buttonWithName:@"btnRotate.png" pressedName:@"btnRotatePressed.png" pos:ccp(40, 100) flipX:YES flipY:NO];
        _rotRight = [self buttonWithName:@"btnRotate.png" pressedName:@"btnRotatePressed.png" pos:ccp(160, 100) flipX:NO flipY:NO];
        _moveForward = [self buttonWithName:@"btnArrow.png" pressedName:@"btnArrowPressed.png" pos:ccp(100, 150) flipX:NO flipY:NO];
        _moveBack = [self buttonWithName:@"btnArrow.png" pressedName:@"btnArrowPressed.png" pos:ccp(100, 40) flipX:NO flipY:YES];
        _attack = [self buttonWithName:@"btnFire.png" pressedName:@"btnFirePressed.png" pos:ccp(_winSize.width - 80, 100) flipX:NO flipY:NO];
        
        self.touchEnabled = YES;


    }
    return self;
}

-(void) onEnterTransitionDidFinish{
    [self schedule:@selector(generationBonus) interval:bonus_interval];
}
#pragma mark - PRIVAT METHODS -

-(CGRect) getRectFromObject: (JTObject*) object{
    
    return CGRectMake(object.position.x - object.sprite.contentSize.width/2, object.position.y - object.sprite.contentSize.height/2,
                      object.sprite.contentSize.height, object.sprite.contentSize.height);
}


-(void) generationBonus{
    
    JTBonusType type = arc4random() % 3;
    
    JTBonus* bonus = [[JTBonus alloc]initWithType:type scene:self];
    
    BOOL didIntersect;
    
    CGRect rect = CGRectZero;
    
    float posX = 0;
    float posY = 0;
    
    do {
        didIntersect = NO;
        
        posX = arc4random() % (int)(_winSize.width - bonus.sprite.contentSize.width) + bonus.sprite.contentSize.width/2;
        posY = arc4random() % (int)(_winSize.height - bonus.sprite.contentSize.height) + bonus.sprite.contentSize.height/2;
        
        rect = CGRectMake(posX - bonus.sprite.contentSize.width/2, posY - bonus.sprite.contentSize.height/2,
                          bonus.sprite.contentSize.width,  bonus.sprite.contentSize.height);
        for (CCSprite* wall in _wallsArray) {
            if (CGRectIntersectsRect([self getRectFromSprite:wall], rect)) {
                didIntersect = YES;
            }
        }
        for (JTObject *enemy in _enemiesArray) {
            if (CGRectIntersectsRect([self getRectFromObject:enemy],rect)) {
                didIntersect = YES;
            }
        }
        if (CGRectIntersectsRect([self getRectFromObject:_playerTank],rect)) {
            didIntersect = YES;
        }
    } while (didIntersect);
    
    bonus.position = ccp(posX, posY);
    [self addChild:bonus z:55];
}

-(void) updateBulletsIcons{
    
    while ([self getChildByTag:bullet_icon_tag]) {
        [self removeChildByTag:bullet_icon_tag cleanup:YES];
    }
    for (int i =0; i < _playerTank.bullets; i++) {
        CCSprite* bullets = [CCSprite spriteWithFile:@"bullet.png"];
        bullets.position = ccp(5, _winSize.height - 40 - i * 9);
        bullets.anchorPoint = ccp(0, 1);
        [self addChild:bullets z:100 tag:bullet_icon_tag];
        
    }
}

-(void) updateLifeIcons{
    
    while ([self getChildByTag:life_icon_tag]) {
        [self removeChildByTag:life_icon_tag cleanup:YES];
    }
    
    for (int i = 0; i <_lives; i++) {
        
        CCSprite* life = [CCSprite spriteWithFile:@"Tank1.png"];
        life.scale = 0.35;
        life.position = ccp(15+i*20, _winSize.height-20);
        
        [self addChild:life z:100 tag:life_icon_tag];
        
    }
    
}

-(void) createPlayer{
    
    if (_lives >=0) {
        
        while ([self getChildByTag:life_icon_tag]) {
            [self removeChildByTag:life_icon_tag cleanup:YES];
        }
        
        for (int i = 0; i <_lives; i++) {
            
            CCSprite* life = [CCSprite spriteWithFile:@"Tank1.png"];
            life.scale = 0.35;
            life.position = ccp(15+i*20, _winSize.height-20);
            
            [self addChild:life z:100 tag:life_icon_tag];
            
        }
        
        _playerTank = [[JTPlayerTank alloc]initWithSprite:[CCSprite spriteWithFile:@"Tank1.png"] scene:self properties:nil];
        _playerTank.position = ccp(_winSize.width/2, _winSize.height/2);
        [self addChild:_playerTank z:50 tag:player_tag];
        
    }else{
        //game over
        
        CCLabelTTF* gameOverLabel = [CCLabelTTF labelWithString:@"Game over!" fontName:@"Verdana" fontSize:60];
        gameOverLabel.color = ccORANGE;
        gameOverLabel.position = ccp(_winSize.width/2, _winSize.height +30);
        [self addChild:gameOverLabel z:100];
        
        id move = [CCMoveTo actionWithDuration:2 position:ccp(_winSize.width/2, _winSize.height/2)];
        id bounce = [CCEaseBounceOut actionWithAction:move];
        
        [gameOverLabel runAction:bounce];
    }
    [self updateBulletsIcons];
}

-(void) createEnemyWithPosition: (CGPoint) pos;{
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:pos],key_position,
                          [NSNumber numberWithFloat:500],key_rotation,
                          [NSNumber numberWithFloat:300],key_shot_distance,
                          [NSNumber numberWithInt:100], key_health,nil];
    JTEnemyTank* enemyTank = [[JTEnemyTank alloc]initWithSprite:[CCSprite spriteWithFile:@"Tank2.png"] scene:self properties:dict];
    enemyTank.rotation = 0;
    [self addChild:enemyTank z:50];
    
    [_enemiesArray addObject:enemyTank];
}

-(CGRect) getRectFromSprite: (CCSprite*) sprt{
    return CGRectMake(sprt.position.x - sprt.contentSize.width/2, sprt.position.y - sprt.contentSize.height/2,
                      sprt.contentSize.width, sprt.contentSize.height);
}

-(CCSprite*) buttonWithName:(NSString*) name pressedName: (NSString*) pressedName pos:(CGPoint) pos flipX:(BOOL) flipX flipY:(BOOL) flipY{
    
    CCSprite* sprt = [CCSprite spriteWithFile:name];
    sprt.position = pos;
    sprt.flipX = flipX;
    sprt.flipY =flipY;
    [self addChild:sprt z:100];
    
    CCSprite* pressed = [CCSprite spriteWithFile:pressedName];
    pressed.flipX = flipX;
    pressed.flipY =flipY;
    pressed.anchorPoint = ccp(0, 0);
    pressed.tag = pressed_tag;
    pressed.visible = NO;
    [sprt addChild:pressed];
    
    return sprt;
}

-(void) checkForActionInBeggining:(CCSprite*) sprt isDoing:(BOOL*) isDoing location:(CGPoint) location{
    
    if (CGRectContainsPoint([self getRectFromSprite:sprt], location)) {
        
        CCNode *pressed = [sprt getChildByTag:pressed_tag];
        pressed.visible = YES;
        *isDoing = YES;
        _engineSound = [[SimpleAudioEngine sharedEngine] playEffect:@"engine.wav"];
    }
    
}
-(void) checkForActionInEndning:(CCSprite*) sprt isDoing:(BOOL*) isDoing location:(CGPoint) location{
    
    CCNode *pressed = [sprt getChildByTag:pressed_tag];
    pressed.visible = NO;
    *isDoing = NO;
    
    [[SimpleAudioEngine sharedEngine] stopEffect:_engineSound];
    
}


#pragma mark - TOUCHES -

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for( UITouch *touch in touches ) {
        
        CGPoint position = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
        
        [self checkForActionInBeggining:_rotLeft isDoing:&_isRotatingLeft location:position];
        [self checkForActionInBeggining:_rotRight isDoing:&_isRotatingRight location:position];
        [self checkForActionInBeggining:_moveForward isDoing:&_isMovingForward location:position];
        [self checkForActionInBeggining:_moveBack isDoing:&_isMovingBack location:position];
        
        if (CGRectContainsPoint([self getRectFromSprite:_attack], position)) {
            CCNode *pressed = [_attack getChildByTag:pressed_tag];
            pressed.visible = YES;
            
            [_playerTank shoot];
        }
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for( UITouch *touch in touches ) {
        
        CGPoint position = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    }

}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
   
    for( UITouch *touch in touches ) {
        
        CGPoint position = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];

        [self checkForActionInEndning:_rotLeft isDoing:&_isRotatingLeft location:position];
        [self checkForActionInEndning:_rotRight isDoing:&_isRotatingRight location:position];
        [self checkForActionInEndning:_moveForward isDoing:&_isMovingForward location:position];
        [self checkForActionInEndning:_moveBack isDoing:&_isMovingBack location:position];
        
        if (CGRectContainsPoint([self getRectFromSprite:_attack], position)) {
            CCNode *pressed = [_attack getChildByTag:pressed_tag];
            pressed.visible = NO;
            
        }

    }
}

@end
