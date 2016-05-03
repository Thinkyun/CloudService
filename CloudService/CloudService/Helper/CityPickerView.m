//
//  CityPickerView.m
//  省市
//
//  Created by 安永超 on 16/4/19.
//  Copyright © 2016年 zph. All rights reserved.
//

#import "CityPickerView.h"

#define KWidth  [UIScreen mainScreen].bounds.size.width
#define KHeight  [UIScreen mainScreen].bounds.size.height
@interface CityPickerView()<UIPickerViewDataSource,UIPickerViewDelegate>
{

        hidePickerViewBlock _block;
        UIView *_accessInputView;

}
/**
 *  存放数据的数组
 */
@property (nonatomic,strong)NSArray *provinceArray;
@property (nonatomic,strong)NSArray *cityArray;
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,strong)UIView *maskView;
/**
 *  省模型
 */
@property (nonatomic,copy)NSString * selecletPro;
@property (nonatomic,copy)NSString * selecletCity;
@end


@implementation Province

/**
 *  重写init方法
 */
//-(instancetype)initWithDic:(NSDictionary *)dic{
//    if (self == [super init]) {
//        [self setValuesForKeysWithDictionary:dic];
//    }
//    return self;
//}
//
//+(instancetype)citiesWithDic:(NSDictionary *)dic{
//    return [[self alloc]initWithDic:dic];
//}

@end

@implementation CityPickerView
- (instancetype)initWithCount:(NSInteger)count{
    
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        

        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.maskView = [[UIView alloc] initWithFrame:self.bounds];
    self.maskView.alpha = 0;
    self.maskView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView)];
    [self.maskView addGestureRecognizer:tap];
    CGFloat accessHeight = 50;
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, KHeight , KWidth, 180)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    _accessInputView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.pickerView.frame) - accessHeight, KWidth, accessHeight)];
    //    _accessInputView.hidden = YES;
    _accessInputView.backgroundColor = [UIColor whiteColor];
    
    UIButton *cancleBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    cancleBtn.frame = CGRectMake(20, 15, 30, 30);
    [cancleBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancleBtn addTarget:self action:@selector(cancleAction:) forControlEvents:(UIControlEventTouchUpInside)];
    UIButton *ensureBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    ensureBtn.frame = CGRectMake(KWidth - 20 - 30, 15, 30, 30);
    [ensureBtn setTitle:@"确定" forState:(UIControlStateNormal)];
    [ensureBtn addTarget:self action:@selector(ensureAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_accessInputView addSubview:cancleBtn];
    [_accessInputView addSubview:ensureBtn];
    
    [self addSubview:self.maskView];
    [self addSubview:self.pickerView];
    [self addSubview:_accessInputView];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArray.count;
    }else{
        
        // 2.如果是第1组，城市 城市的行数就要看当前正在显示的是哪个省
        //获取省的索引
        NSInteger seleProIndx = [pickerView selectedRowInComponent:0];
        //获取当前省的数据
        NSDictionary * seleDic = self.provinceArray[seleProIndx];
        //保存当前省的数据
        self.selecletPro = [seleDic valueForKey:@"name"];
        //城市的数组
        self.cityArray = [seleDic valueForKey:@"city"];
        
        //返回省的城市的个数
        return self.cityArray.count;
        
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0) {
//        self.province = self.provinceArray
//        //返回省的名字
//        Province * city = self.provinceArray[row];
        NSString *province = [self.provinceArray[row] valueForKey:@"name"];
        return province;
    }else{
               //返回保存的城市里面的内容
        return [self.cityArray[row] valueForKey:@"name"];
    }
    

}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
    }
    
    //设置label的内容
    //选择了第几组的行
    NSInteger selePro = [pickerView selectedRowInComponent:0];
    NSInteger seleCity = [pickerView selectedRowInComponent:1];
    
    self.province = [self.provinceArray[selePro] valueForKey:@"name"];
    self.city = [self.cityArray[seleCity] valueForKey:@"name"];
}

- (void)cancleAction:(UIButton *)sender {
    [self hidePickerViewWithEnsure:NO];
}

- (void)ensureAction:(UIButton *)sender {
    [self hidePickerViewWithEnsure:YES];
}

- (void)showPickViewAnimated:(hidePickerViewBlock )block {
    
    _block = block;
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.5;
        _accessInputView.transform = CGAffineTransformMakeTranslation(0, -180);
        self.pickerView.transform = CGAffineTransformMakeTranslation(0, -180);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hidePickerViewWithEnsure:(BOOL )flag {
    

    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        _accessInputView.transform = CGAffineTransformIdentity;
        self.pickerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (flag) {
            if (self.province||self.city) {
                _block(self.province,self.city);
            }else{
                //获取内容
                
                //获取当前省的数据
                NSDictionary * seleDic = self.provinceArray[0];
                //保存当前省的数据
                self.selecletPro = [seleDic valueForKey:@"name"];
                //城市的数组
                self.cityArray = [seleDic valueForKey:@"city"];
                self.city = [self.cityArray[0] valueForKey:@"name"];
                _block(self.province,self.city);
            }
            
        }
        [self removeFromSuperview];
    }];
}



- (void)tapMaskView {
    [self hidePickerViewWithEnsure:NO];
}

/**
 *  懒加载
 */
-(NSArray *)provinceArray{
    if (!_provinceArray) {
        NSString *path =[[NSString alloc]initWithString:[[NSBundle mainBundle] pathForResource:@"province"ofType:@"plist"]];

        NSDictionary *rootDic = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSDictionary *provinceDic = [rootDic valueForKey:@"root"];
        NSArray *array = [provinceDic valueForKey:@"province"];
        _provinceArray = array;
    }
    return _provinceArray;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
