//
// ZDStickerView.m
//
// Created by Seonghyun Kim on 5/29/13.
// Copyright (c) 2013 scipi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ZDStickerView.h"
#import "SPGripViewBorderView.h"


#define kSPUserResizableViewGlobalInset 14.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewInteractiveBorderSize 10.0
#define kZDStickerViewControlSize 32.0



@interface ZDStickerView ()

@property (nonatomic, strong) SPGripViewBorderView *borderView;

@property (strong, nonatomic) UIImageView *resizingControl;
@property (strong, nonatomic) UIImageView *deleteControl;
@property (strong, nonatomic) UIImageView *customControl;

@property (strong, nonatomic) UIImageView *topLeftCornerIcon;
@property (strong, nonatomic) UIImageView *topRightCornerIcon;
@property (strong, nonatomic) UIImageView *bottomLeftCornerIcon;
@property (strong, nonatomic) UIImageView *bottomRightCornerIcon;
@property (strong, nonatomic) UIImageView *mainResizingControl;

@property (nonatomic) BOOL preventsLayoutWhileResizing;

@property (nonatomic) CGFloat deltaAngle;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat deltaScale;
@property (nonatomic) CGFloat startScale;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;

@property (nonatomic) CGPoint touchStart;

@end



@implementation ZDStickerView

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect
   {
    // Drawing code
   }
 */

#ifdef ZDSTICKERVIEW_LONGPRESS
- (void)longPress:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidLongPressed:)])
        {
            [self.stickerViewDelegate stickerViewDidLongPressed:self];
        }
    }
}
#endif


- (void)deleteTap:(UIPanGestureRecognizer *)recognizer
{
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidClose:)])
    {
        [self.stickerViewDelegate stickerViewDidClose:self];
    }

    if (NO == self.preventsDeleting)
    {
        UIView *close = (UIView *)[recognizer view];
        [close.superview removeFromSuperview];
    }
}

- (void)resetTap:(UIPanGestureRecognizer *)recognizer
{
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidReset:)])
    {
        [self.stickerViewDelegate stickerViewDidReset:self];
    }
}

- (void) doubleTap: (UIPanGestureRecognizer *) recognier {
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidDoubleTapped:)])
    {
        [self.stickerViewDelegate stickerViewDidDoubleTapped:self];
    }
}

- (void)customTap:(UIPanGestureRecognizer *)recognizer
{
    if (NO == self.preventsCustomButton)
    {
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidCustomButtonTap:)])
        {
            [self.stickerViewDelegate stickerViewDidCustomButtonTap:self];
        }
    }
}


- (void)pinchTranslate:(UIPinchGestureRecognizer *)recognizer {
    if (self.bLocked) {
        return;
    }

    CGFloat diffScale = self.startScale * recognizer.scale - self.startScale;

    if (self.deltaScale + diffScale > 10) {
        diffScale = 0.0;
    } else if (self.deltaScale + diffScale < 0) {
        diffScale = 0.0;
    } else {
        self.startScale *= recognizer.scale;
    }

    [self resizeViewManually:diffScale / 0.1f * 4.0f];
    self.deltaScale += diffScale;

    [self rotateView:self.deltaAngle];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateZoomValueInStickView" object:nil userInfo:@{@"value": @(self.deltaScale)}];

    /*
    self.transform = CGAffineTransformScale(self.transform, recognizer.scale, recognizer.scale);
     */
    
    recognizer.scale = 1;
}

- (void) rotateTranslate:(UIRotationGestureRecognizer *) recognizer {
    if (self.bLocked) {
        return;
    }

    NSLog(@"%f", recognizer.rotation);
    
    [self rotateView:(self.deltaAngle + recognizer.rotation)];
    
    CGFloat newAngle = 0.0;
    if (self.deltaAngle >= 0.0) {
        newAngle = self.deltaAngle - (int)(self.deltaAngle / (2 * M_PI)) * (2 * M_PI);
    } else {
        newAngle = -1 * (-self.deltaAngle - (int)(-self.deltaAngle / (2 * M_PI)) * (2 * M_PI));
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateRotateValueInStickView" object:nil userInfo:@{@"value": @(newAngle / M_PI * 180)}];

    recognizer.rotation = 0.0;
}

- (void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    if (self.bLocked) {
        return;
    }

    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidBeginEditing:)])
        {
            [self.stickerViewDelegate stickerViewDidBeginEditing:self];
        }

        [self enableTransluceny:YES];
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
        
        self.startAngle = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        [self enableTransluceny:YES];
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        
        float angleDiff = ang - self.startAngle;
        self.startAngle = ang;
        
        [self rotateView:(self.deltaAngle + angleDiff)];
        
        CGFloat newAngle = 0.0;
        if (self.deltaAngle >= 0.0) {
            newAngle = self.deltaAngle - (int)(self.deltaAngle / (2 * M_PI)) * (2 * M_PI);
        } else {
            newAngle = -1 * (-self.deltaAngle - (int)(-self.deltaAngle / (2 * M_PI)) * (2 * M_PI));
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateRotateValueInStickView" object:nil userInfo:@{@"value": @(newAngle / M_PI * 180)}];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled)
    {
        [self enableTransluceny:NO];
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
        
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidEndEditing:)])
        {
            [self.stickerViewDelegate stickerViewDidEndEditing:self];
        }

    }
}

- (void) resetRotateZoomForTextChange: (CGFloat) angleValue withZoom: (CGFloat) zoomValue {
    self.transform = CGAffineTransformIdentity;
    self.contentView.transform = CGAffineTransformIdentity;
    
    self.startAngle = 0.0;
    self.startScale = 1.0;

    self.deltaScale = 4.0;
    self.deltaAngle = 0.0;
    
    
    //[self rotateView:0.0];
    //[self zoomView:4.0];
}

- (void) resetRotateZoom {
    self.transform = CGAffineTransformIdentity;

    self.startAngle = 0.0;
    self.startScale = 1.0;
    
    [self rotateView:0.0];
    [self zoomView:4.0];
}

- (void) rotateView: (CGFloat) angle {
    CGFloat diffAngle = angle - self.deltaAngle;
    
    self.deltaAngle = angle;
    
    self.transform = CGAffineTransformRotate(self.transform, diffAngle);

    self.contentView.frame = CGRectInset(self.bounds,
                                         kSPUserResizableViewGlobalInset + 3,
                                         kSPUserResizableViewGlobalInset + 3);
    [self.borderView setNeedsDisplay];
    
    [self setNeedsDisplay];
}

- (void) zoomOutView {
    [self resizeViewManually:-4.0f];
}

- (void) zoomInView {
    [self resizeViewManually:4.0f];
}

- (void) zoomView: (CGFloat) scale {
    [self resizeViewManually:(scale - self.deltaScale) / 0.1f * 4.0f];
    self.deltaScale = scale;
}

- (void) resizeViewManually: (CGFloat) wChange {
    float hChange = 0.0;
    
    float wRatioChange = (wChange/(float)self.bounds.size.width);
    
    hChange = wRatioChange * self.bounds.size.height;
    
    if (self.bounds.size.width + wChange < 20.0f) {
        wChange = 0.f;
        hChange = 0.f;
    }
    
    CGFloat diffSize = (kSPUserResizableViewGlobalInset + 3) * 2.0;
    
    CGFloat newWidth = self.bounds.size.width + (wChange);
    CGFloat newHeight = self.bounds.size.height + (hChange);
    
    CGFloat scaleX = (newWidth - diffSize) / (self.bounds.size.width - diffSize);
    CGFloat scaleY = (newHeight - diffSize) / (self.bounds.size.height - diffSize);
    
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                             newWidth,
                             newHeight);

    NSLog(@"bounds = %f, %f, %f, %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);

    self.topLeftCornerIcon.frame = CGRectMake(0, 0,
                                              kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    self.topRightCornerIcon.frame = CGRectMake(self.bounds.size.width-kZDStickerViewControlSize / 3.0, 0,
                                               kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    self.bottomLeftCornerIcon.frame = CGRectMake(0, self.bounds.size.height-kZDStickerViewControlSize / 3.0,
                                                 kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    self.bottomRightCornerIcon.frame = CGRectMake(self.bounds.size.width-kZDStickerViewControlSize / 3.0, self.bounds.size.height-kZDStickerViewControlSize / 3.0,
                                                  kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    
    self.deleteControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                         self.bounds.size.height-kZDStickerViewControlSize,
                                         kZDStickerViewControlSize, kZDStickerViewControlSize);
    self.mainResizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                               self.bounds.size.height-kZDStickerViewControlSize,
                                               kZDStickerViewControlSize, kZDStickerViewControlSize);
    self.resizingControl.frame = CGRectMake(0, 0,
                                            kZDStickerViewControlSize, kZDStickerViewControlSize);
    self.customControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                         0,
                                         kZDStickerViewControlSize,
                                         kZDStickerViewControlSize);
    
    self.borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    
    self.contentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CGAffineTransform transform =  CGAffineTransformScale(self.contentView.transform, scaleX, scaleY);
    self.contentView.transform = transform;
    
    NSLog(@"content view bounds = %f, %f, %f, %f", self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)setupDefaultAttributes
{
    self.deltaScale = 4.0;
    self.deltaAngle = 0.0;
    self.startScale = 1.0;
    
    UIView* prevBorderView = [self viewWithTag:20];
    if (prevBorderView) {
        [prevBorderView removeFromSuperview];
    }

    self.borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    self.borderView.tag = 20;
    [self.borderView setHidden:NO];
    [self addSubview:self.borderView];

    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5)
    {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    }
    else
    {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }

    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    self.preventsCustomButton = YES;
    self.translucencySticker = YES;
    self.bLocked = NO;
    self.bSelected = NO;
    
#ifdef ZDSTICKERVIEW_LONGPRESS
    UILongPressGestureRecognizer*longpress = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self
                                                      action:@selector(longPress:)];
    [self addGestureRecognizer:longpress];
#endif

    self.deleteControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                                                      self.frame.size.height-kZDStickerViewControlSize,
                                                                      kZDStickerViewControlSize, kZDStickerViewControlSize)];
    self.deleteControl.backgroundColor = [UIColor clearColor];
    self.deleteControl.image = [UIImage imageNamed:@"ZDStickerView.bundle/delete.png"];
    self.deleteControl.userInteractionEnabled = YES;
    UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(deleteTap:)];
    [self.deleteControl addGestureRecognizer:deleteTap];
    [self addSubview:self.deleteControl];
    
    self.resizingControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                        kZDStickerViewControlSize, kZDStickerViewControlSize)];
    self.resizingControl.backgroundColor = [UIColor clearColor];
    self.resizingControl.userInteractionEnabled = YES;
    self.resizingControl.image = [UIImage imageNamed:@"ZDStickerView.bundle/restore.png"];
    UITapGestureRecognizer *resetTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(resetTap:)];
    //[self.resizingControl addGestureRecognizer:resetTap];
    UIPanGestureRecognizer *resizeGesture = [[UIPanGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(resizeTranslate:)];
    [self.resizingControl addGestureRecognizer:resizeGesture];
    

    [self addSubview:self.resizingControl];

    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    self.borderView.userInteractionEnabled = true;
    [self.borderView addGestureRecognizer:doubleTapGesture];
    
    self.topLeftCornerIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                      kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0)];
    self.topLeftCornerIcon.backgroundColor = [UIColor clearColor];
    //self.topLeftCornerIcon.image = [UIImage imageNamed:@"ZDStickerView.bundle/corner.png"];
    self.topLeftCornerIcon.userInteractionEnabled = NO;
    [self addSubview:self.topLeftCornerIcon];

    self.topRightCornerIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kZDStickerViewControlSize / 3.0, 0,
                                                                          kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0)];
    self.topRightCornerIcon.backgroundColor = [UIColor clearColor];
    //self.topRightCornerIcon.image = [UIImage imageNamed:@"ZDStickerView.bundle/corner.png"];
    self.topRightCornerIcon.userInteractionEnabled = NO;
    [self addSubview:self.topRightCornerIcon];

    self.bottomLeftCornerIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-kZDStickerViewControlSize / 3.0,
                                                                          kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0)];
    self.bottomLeftCornerIcon.backgroundColor = [UIColor clearColor];
    //self.bottomLeftCornerIcon.image = [UIImage imageNamed:@"ZDStickerView.bundle/corner.png"];
    self.bottomLeftCornerIcon.userInteractionEnabled = NO;
    [self addSubview:self.bottomLeftCornerIcon];

    self.bottomRightCornerIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kZDStickerViewControlSize / 3.0, self.frame.size.height-kZDStickerViewControlSize / 3.0,
                                                                          kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0)];
    self.bottomRightCornerIcon.backgroundColor = [UIColor clearColor];
    //self.bottomRightCornerIcon.image = [UIImage imageNamed:@"ZDStickerView.bundle/corner.png"];
    self.bottomRightCornerIcon.userInteractionEnabled = YES;
    
    [self addSubview:self.bottomRightCornerIcon];

    self.mainResizingControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                            kZDStickerViewControlSize, kZDStickerViewControlSize)];
    self.mainResizingControl.backgroundColor = [UIColor clearColor];
    self.mainResizingControl.userInteractionEnabled = YES;
    //self.mainResizingControl.image = [UIImage imageNamed:@"ZDStickerView.bundle/restore.png"];
    //self.mainResizingControl.userInteractionEnabled = YES;
    [self addSubview:self.mainResizingControl];

    self.customControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                                                      0,
                                                                      kZDStickerViewControlSize, kZDStickerViewControlSize)];
    self.customControl.backgroundColor = [UIColor clearColor];
    self.customControl.userInteractionEnabled = YES;
    self.customControl.image = nil;
    
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(pinchTranslate:)];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];

    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(rotateTranslate:)];
    rotateGesture.delegate = self;
    [self addGestureRecognizer:rotateGesture];

    /*
    UITapGestureRecognizer *customTapGesture = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                        action:@selector(customTap:)];
    [self.customControl addGestureRecognizer:customTapGesture];
    */
    
    [self addSubview:self.customControl];

    /*
    self.deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                            self.frame.origin.x+self.frame.size.width - self.center.x);
    */

    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(tappedView:)];
    oneTap.numberOfTouchesRequired = 1;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:oneTap];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setupDefaultAttributes];
    }

    return self;
}



- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setupDefaultAttributes];
    }

    return self;
}

- (void) showBorderCorners {
    self.borderView.hidden = NO;
    self.borderView.bHide = NO;
    [self.borderView setNeedsDisplay];
    
    self.topLeftCornerIcon.hidden = NO;
    self.topRightCornerIcon.hidden = NO;
    self.bottomLeftCornerIcon.hidden = NO;
    self.bottomRightCornerIcon.hidden = NO;
}

- (void) hideBorderCorners {
    self.borderView.hidden = YES;
    self.borderView.bHide = YES;
    [self.borderView setNeedsDisplay];
    
    self.topLeftCornerIcon.hidden = YES;
    self.topRightCornerIcon.hidden = YES;
    self.bottomLeftCornerIcon.hidden = YES;
    self.bottomRightCornerIcon.hidden = YES;
}

- (void)setContentView:(UIView *)newContentView
{
    [self.contentView removeFromSuperview];
    
    UIView* prevContentView = [self viewWithTag:10];
    if (prevContentView) {
        [prevContentView removeFromSuperview];
    }
    
    _contentView = newContentView;

//    self.contentView.frame = CGRectInset(self.bounds,
//                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize,
//                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize);
    self.contentView.frame = CGRectInset(self.bounds,
                                         kSPUserResizableViewGlobalInset + 3,
                                         kSPUserResizableViewGlobalInset + 3);

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentView.tag = 10;
    [self addSubview:self.contentView];
    
    self.contentView.backgroundColor = self.iconTintColor;
    for (UIView *subview in [self.contentView subviews])
    {
        [subview setFrame:CGRectMake(0, 0,
                                     self.contentView.frame.size.width,
                                     self.contentView.frame.size.height)];

        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    [self bringSubviewToFront:self.borderView];
    [self bringSubviewToFront:self.resizingControl];
    [self bringSubviewToFront:self.mainResizingControl];
    [self bringSubviewToFront:self.deleteControl];
    [self bringSubviewToFront:self.customControl];
}



- (void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    /*
    self.contentView.frame = CGRectInset(self.bounds,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
     */

    self.contentView.frame = CGRectInset(self.bounds,
                                         kSPUserResizableViewGlobalInset + 3,
                                         kSPUserResizableViewGlobalInset + 3);

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    for (UIView *subview in [self.contentView subviews])
    {
        [subview setFrame:CGRectMake(0, 0,
                                     self.contentView.frame.size.width,
                                     self.contentView.frame.size.height)];

        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    self.topLeftCornerIcon.frame = CGRectMake(0, 0,
                                              kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    self.topRightCornerIcon.frame = CGRectMake(self.bounds.size.width-kZDStickerViewControlSize / 3.0, 0,
                                               kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    self.bottomLeftCornerIcon.frame = CGRectMake(0, self.bounds.size.height-kZDStickerViewControlSize / 3.0,
                                                 kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    self.bottomRightCornerIcon.frame = CGRectMake(self.bounds.size.width-kZDStickerViewControlSize / 3.0, self.bounds.size.height-kZDStickerViewControlSize / 3.0,
                                                  kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    

    self.borderView.frame = CGRectInset(self.bounds,
                                        kSPUserResizableViewGlobalInset,
                                        kSPUserResizableViewGlobalInset);

    self.deleteControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                           self.bounds.size.height-kZDStickerViewControlSize,
                                           kZDStickerViewControlSize,
                                           kZDStickerViewControlSize);

    self.resizingControl.frame = CGRectMake(0, 0,
                                          kZDStickerViewControlSize, kZDStickerViewControlSize);

    self.customControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                         0,
                                         kZDStickerViewControlSize,
                                         kZDStickerViewControlSize);

    [self.borderView setNeedsDisplay];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (self.topLeftCornerIcon) {
        self.topLeftCornerIcon.frame = CGRectMake(0, 0,
                                                  kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    }
    
    if (self.topRightCornerIcon) {
        self.topRightCornerIcon.frame = CGRectMake(self.bounds.size.width-kZDStickerViewControlSize / 3.0, 0,
                                                   kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    }
    
    if (self.bottomLeftCornerIcon) {
        self.bottomLeftCornerIcon.frame = CGRectMake(0, self.bounds.size.height-kZDStickerViewControlSize / 3.0,
                                                     kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    }
    
    if (self.bottomRightCornerIcon) {
        self.bottomRightCornerIcon.frame = CGRectMake(self.bounds.size.width-kZDStickerViewControlSize / 3.0, self.bounds.size.height-kZDStickerViewControlSize / 3.0,
                                                      kZDStickerViewControlSize / 3.0, kZDStickerViewControlSize / 3.0);
    }

    if (self.deleteControl) {
        self.deleteControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                               self.bounds.size.height-kZDStickerViewControlSize,
                                               kZDStickerViewControlSize, kZDStickerViewControlSize);
    }

    if (self.mainResizingControl) {
        self.mainResizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                               self.bounds.size.height-kZDStickerViewControlSize,
                                               kZDStickerViewControlSize, kZDStickerViewControlSize);
    }

    if (self.resizingControl) {
        self.resizingControl.frame = CGRectMake(0, 0,
                                              kZDStickerViewControlSize, kZDStickerViewControlSize);
    }
    
    if (self.customControl) {
        self.customControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                             0,
                                             kZDStickerViewControlSize,
                                             kZDStickerViewControlSize);
    }
}

- (void) setSelectedStatus:(BOOL) bFlag
{
    self.bSelected = bFlag;
}

- (void)tappedView:(UIPanGestureRecognizer *)recognizer
{
    [self enableTransluceny:NO];

    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidTapped:)])
    {
        [self.stickerViewDelegate stickerViewDidTapped:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.bSelected) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisabledScrollView" object:nil userInfo:nil];
    
    [self enableTransluceny:YES];

    UITouch *touch = [touches anyObject];
    self.touchStart = [touch locationInView:self.superview];
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidBeginEditing:)])
    {
        [self.stickerViewDelegate stickerViewDidBeginEditing:self];
    }
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.bSelected) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnabledScrollView" object:nil userInfo:nil];

    [self enableTransluceny:NO];

    // Notify the delegate we've ended our editing session.
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidEndEditing:)])
    {
        [self.stickerViewDelegate stickerViewDidEndEditing:self];
    }
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.bSelected) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnabledScrollView" object:nil userInfo:nil];

    [self enableTransluceny:NO];

    // Notify the delegate we've ended our editing session.
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidCancelEditing:)])
    {
        [self.stickerViewDelegate stickerViewDidCancelEditing:self];
    }
}



- (CGPoint) translateUsingTouchLocation:(CGPoint)touchPoint
{
    if (!self.bSelected) {
        return CGPointMake(self.center.x, self.center.y);
    }

    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - self.touchStart.x,
                                    self.center.y + touchPoint.y - self.touchStart.y);

    if (self.preventsPositionOutsideSuperview)
    {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX)
        {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }

        if (newCenter.x < midPointX)
        {
            newCenter.x = midPointX;
        }

        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY)
        {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }

        if (newCenter.y < midPointY)
        {
            newCenter.y = midPointY;
        }
    }

    self.center = newCenter;
    
    self.bShowBorderCorners = YES;
    [self showBorderCorners];
    
    return newCenter;
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.bSelected) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisabledScrollView" object:nil userInfo:nil];

    [self enableTransluceny:YES];

    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.resizingControl.frame, touchLocation))
    {
        return;
    }

    if (CGRectContainsPoint(self.mainResizingControl.frame, touchLocation))
    {
        return;
    }

    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    CGPoint prevCenter = self.center;
    CGPoint newCenter = [self translateUsingTouchLocation:touch];
    self.touchStart = touch;
    
    // Notify the delegate we're moving view.
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidMoving:withOffset:)])
    {
        CGFloat distance = (newCenter.x - prevCenter.x) * (newCenter.x - prevCenter.x) + (newCenter.y - prevCenter.y) * (newCenter.y - prevCenter.y);
        if (sqrt(distance) > 2.0) {
            [self.stickerViewDelegate stickerViewDidMoving:self withOffset:CGPointMake(newCenter.x - prevCenter.x, newCenter.y - prevCenter.y)];
        }
    }
}



- (void)hideDelHandle
{
    self.deleteControl.hidden = YES;
}



- (void)showDelHandle
{
    self.deleteControl.hidden = NO;
}



- (void)hideEditingHandles
{
    self.resizingControl.hidden = YES;
    self.deleteControl.hidden = YES;
    self.customControl.hidden = YES;
}

- (void)showEditingHandles
{
    self.resizingControl.hidden = NO;
    self.deleteControl.hidden = NO;
    self.customControl.hidden = YES;

    /*
    if (NO == self.preventsCustomButton)
    {
        self.customControl.hidden = NO;
    }
    else
    {
        self.customControl.hidden = YES;
    }

    if (NO == self.preventsDeleting)
    {
        self.deleteControl.hidden = NO;
    }
    else
    {
        self.deleteControl.hidden = YES;
    }

    if (NO == self.preventsResizing)
    {
        self.resizingControl.hidden = NO;
    }
    else
    {
        self.resizingControl.hidden = YES;
    }
    */
}



- (void)showCustomHandle
{
    self.customControl.hidden = NO;
}



- (void)hideCustomHandle
{
    self.customControl.hidden = YES;
}



- (void)setButton:(ZDSTICKERVIEW_BUTTONS)type image:(UIImage*)image
{
    switch (type)
    {
        case ZDSTICKERVIEW_BUTTON_RESIZE:
            self.resizingControl.image = image;
            break;
        case ZDSTICKERVIEW_BUTTON_DEL:
            self.deleteControl.image = image;
            break;
        case ZDSTICKERVIEW_BUTTON_CUSTOM:
            self.customControl.image = image;
            break;

        default:
            break;
    }
}



- (BOOL)isEditingHandlesHidden
{
    return self.borderView.hidden;
}



- (void)enableTransluceny:(BOOL)state
{
    if (self.translucencySticker == YES)
    {
        if (state == YES)
        {
            self.alpha = 0.65;
        }
        else
        {
            self.alpha = 1.0;
        }
    }
}



@end
