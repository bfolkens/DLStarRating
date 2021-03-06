/*

    DLStarRating
    Copyright (C) 2011 David Linsin <dlinsin@gmail.com> 

    All rights reserved. This program and the accompanying materials
    are made available under the terms of the Eclipse Public License v1.0
    which accompanies this distribution, and is available at
    http://www.eclipse.org/legal/epl-v10.html

 */

#import "DLStarRatingControl.h"
#import "DLStarView.h"
#import "UIView+Subviews.h"



@implementation DLStarRatingControl

@synthesize star, highlightedStar, delegate;

#pragma mark -
#pragma mark Initialization

- (void)setupView {
	self.clipsToBounds = YES;
	currentIdx = -1;
	star = [UIImage imageNamed:@"star.png"];
	highlightedStar = [UIImage imageNamed:@"star_highlighted.png"];        

	for (int i=0; i<numberOfStars; i++) {
		DLStarView *v = [[DLStarView alloc] initWithDefault:self.star highlighted:self.highlightedStar position:i];
		[self addSubview:v];
        [v release];
	}
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		numberOfStars = kDefaultNumberOfStars;
		[self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		numberOfStars = kDefaultNumberOfStars;
		[self setupView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame andStars:(NSUInteger)_numberOfStars {
	self = [super initWithFrame:frame];
	if (self) {
		numberOfStars = _numberOfStars;
		[self setupView];
	}
	return self;
}

- (void)layoutSubviews {
	for (int i=0; i < numberOfStars; i++) {
		[(DLStarView*)[self subViewWithTag:i+kTagOffset] centerIn:self.frame with:numberOfStars];
	}
}

#pragma mark -
#pragma mark Touch Handling

- (UIButton*)starForPoint:(CGPoint)point {
	for (int i=0; i < numberOfStars; i++) {
		if (CGRectContainsPoint([self subViewWithTag:i+kTagOffset].frame, point)) {
			return (UIButton*)[self subViewWithTag:i+kTagOffset];
		}
	}	
	return nil;
}

- (void)disableStarsDownToExclusive:(int)idx {
	for (int i=numberOfStars; i > idx; --i) {
		UIButton *b = (UIButton*)[self subViewWithTag:i+kTagOffset];
		b.highlighted = NO;
	}
}

- (void)disableStarsDownTo:(int)idx {
	for (int i=numberOfStars; i >= idx; --i) {
		UIButton *b = (UIButton*)[self subViewWithTag:i+kTagOffset];
		b.highlighted = NO;
	}
}


- (void)enableStarsUpTo:(int)idx {
	for (int i=0; i <= idx; i++) {
		UIButton *b = (UIButton*)[self subViewWithTag:i+kTagOffset];
		b.highlighted = YES;
	}
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint point = [touch locationInView:self];	
	UIButton *pressedButton = [self starForPoint:point];
	if (pressedButton) {
		int idx = pressedButton.tag - kTagOffset;
		if (pressedButton.highlighted) {
			[self disableStarsDownToExclusive:idx];
		} else {
			[self enableStarsUpTo:idx];
		}		
		currentIdx = idx;
	} 
	return YES;		
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
	[super cancelTrackingWithEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint point = [touch locationInView:self];
	
	UIButton *pressedButton = [self starForPoint:point];
	if (pressedButton) {
		int idx = pressedButton.tag - kTagOffset;
		UIButton *currentButton = (UIButton*)[self subViewWithTag:currentIdx];
		
		if (idx < currentIdx) {
			currentButton.highlighted = NO;
			currentIdx = idx;
			[self disableStarsDownToExclusive:idx];
		} else if (idx > currentIdx) {
			currentButton.highlighted = YES;
			pressedButton.highlighted = YES;
			currentIdx = idx;
			[self enableStarsUpTo:idx];
		}
	} else if (point.x < [self subViewWithTag:kTagOffset].frame.origin.x) {
		((UIButton*)[self subViewWithTag:kTagOffset]).highlighted = NO;
		currentIdx = -1;
		[self disableStarsDownToExclusive:0];
	}
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	[self.delegate newRating:self withRating:self.rating];
	[super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark -
#pragma mark Rating Property

- (void)setRating:(NSUInteger)_rating {
	[self disableStarsDownTo:0];
	currentIdx = _rating-1;
	[self enableStarsUpTo:currentIdx];
}

- (NSUInteger)rating {
	return (NSUInteger)currentIdx+1;
}

@end
