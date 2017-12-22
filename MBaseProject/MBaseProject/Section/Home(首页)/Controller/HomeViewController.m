//
//  HomeViewController.m
//  MBaseProject
//
//  Created by Wisdom on 2017/12/21.
//  Copyright © 2017年 Wisdom. All rights reserved.
//

#import "HomeViewController.h"
#import "MConst.h"
#import "HomeLabel.h"
#import "MHeader.h"
#import "TestViewController.h"


@interface HomeViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView *titleScrollView;
@property(nonatomic,strong)UIScrollView * contentScrollView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

  
    [self setupChildVc];
    [self setup];
    [self setupTitle];
    
    [self scrollViewDidEndScrollingAnimation:self.contentScrollView];

}

-(void)setup{
    self.titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64,SCREENWIDTH, 35)];
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    self.titleScrollView.backgroundColor = [UIColor lightGrayColor];
    self.titleScrollView.delegate = self;
    [self.view addSubview:self.titleScrollView];
    
    
    self.contentScrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100,SCREENWIDTH, SCREENHEIGHT - 100)];
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.backgroundColor = [UIColor orangeColor];
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.delegate = self;
    [self.view addSubview:self.contentScrollView];

    
}
/**
 * setupChildVc
 */
- (void)setupChildVc
{
    TestViewController *social0 = [[TestViewController alloc] init];
    social0.title = @"国际";
    [self addChildViewController:social0];
    
    TestViewController *social1 = [[TestViewController alloc] init];
    social1.title = @"军事";
    [self addChildViewController:social1];
    
    TestViewController *social2 = [[TestViewController alloc] init];
    social2.title = @"社会";
    [self addChildViewController:social2];
    
    TestViewController *social3 = [[TestViewController alloc] init];
    social3.title = @"政治";
    [self addChildViewController:social3];
    
    TestViewController *social4 = [[TestViewController alloc] init];
    social4.title = @"经济";
    [self addChildViewController:social4];
    
    TestViewController *social5 = [[TestViewController alloc] init];
    social5.title = @"体育";
    [self addChildViewController:social5];
    
    TestViewController *social6 = [[TestViewController alloc] init];
    social6.title = @"娱乐";
    [self addChildViewController:social6];
    
}

/**
 * 添加标题
 */
- (void)setupTitle
{
    // 定义临时变量
    CGFloat labelW = 100;
    CGFloat labelY = 0;
    CGFloat labelH = self.titleScrollView.frame.size.height;
    
    // 添加label
    for (NSInteger i = 0; i<7; i++) {
        HomeLabel *label = [[HomeLabel alloc] init];
        label.text = [self.childViewControllers[i] title];
        CGFloat labelX = i * labelW;
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick:)]];
        label.tag = i;
        [self.titleScrollView addSubview:label];
        
        if (i == 0) { // 最前面的label
            label.scale = 1.0;
        }
    }
    
    // 设置contentSize
    self.titleScrollView.contentSize = CGSizeMake(7 * labelW, 0);
    self.contentScrollView.contentSize = CGSizeMake(7 * [UIScreen mainScreen].bounds.size.width, 0);
    
}

/**
 * 监听顶部label点击
 */
- (void)labelClick:(UITapGestureRecognizer *)tap
{
    // 取出被点击label的索引
    NSInteger index = tap.view.tag;
    
    // 让底部的内容scrollView滚动到对应位置
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = index * self.contentScrollView.frame.size.width;
    [self.contentScrollView setContentOffset:offset animated:YES];
}

#pragma mark - <UIScrollViewDelegate>
/**
 * scrollView结束了滚动动画以后就会调用这个方法（比如- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;方法执行的动画完毕后）
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 一些临时变量
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 当前位置需要显示的控制器的索引
    NSInteger index = offsetX / width;
    
    // 让对应的顶部标题居中显示
    HomeLabel *label = self.titleScrollView.subviews[index];
    CGPoint titleOffset = self.titleScrollView.contentOffset;
    titleOffset.x = label.center.x - width * 0.5;
    // 左边超出处理
    if (titleOffset.x < 0) titleOffset.x = 0;
    // 右边超出处理
    CGFloat maxTitleOffsetX = self.titleScrollView.contentSize.width - width;
    if (titleOffset.x > maxTitleOffsetX) titleOffset.x = maxTitleOffsetX;
    
    [self.titleScrollView setContentOffset:titleOffset animated:YES];
    
    // 让其他label回到最初的状态
    for (HomeLabel *otherLabel in self.titleScrollView.subviews) {
        if (otherLabel != label) otherLabel.scale = 0.0;
    }
    
    // 取出需要显示的控制器
    UIViewController *willShowVc = self.childViewControllers[index];
    
    // 如果当前位置的位置已经显示过了，就直接返回
    if ([willShowVc isViewLoaded]) return;
    
    // 添加控制器的view到contentScrollView中;
    willShowVc.view.frame = CGRectMake(offsetX, 0, width, height);
    [scrollView addSubview:willShowVc.view];
}

/**
 * 手指松开scrollView后，scrollView停止减速完毕就会调用这个
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/**
 * 只要scrollView在滚动，就会调用
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"4--%d",self.contentScrollView.subviews.count);
    NSLog(@"%@",self.contentScrollView.subviews.firstObject);
    
    CGFloat scale = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (scale < 0 || scale > self.titleScrollView.subviews.count - 1) return;
    
    // 获得需要操作的左边label
    NSInteger leftIndex = scale;
    HomeLabel *leftLabel = self.titleScrollView.subviews[leftIndex];
    
    // 获得需要操作的右边label
    NSInteger rightIndex = leftIndex + 1;
    HomeLabel *rightLabel = (rightIndex == self.titleScrollView.subviews.count) ? nil : self.titleScrollView.subviews[rightIndex];
    
    // 右边比例
    CGFloat rightScale = scale - leftIndex;
    // 左边比例
    CGFloat leftScale = 1 - rightScale;
    
    // 设置label的比例
    leftLabel.scale = leftScale;
    rightLabel.scale = rightScale;
}


@end
