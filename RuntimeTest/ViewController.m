//
//  ViewController.m
//  RuntimeTest
//
//  Created by appleimac on 2017/7/19.
//  Copyright © 2017年 appleimac. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"
#import "TestModel2.h"
#import <objc/runtime.h>
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc]init];
    
    [self.view addSubview:self.tableView];
    
    self.tableView.frame = self.view.bounds;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 6;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    switch (indexPath.row ) {
        case 0:
            cell.textLabel.text = @"所有成员变量";
            break;
        case 1:
            cell.textLabel.text = @"类的所有属性";
            break;
        case 2:
            cell.textLabel.text = @"类的所有方法";
            break;
        case 3:
            cell.textLabel.text = @"交换方法";
            break;
        case 4:
            cell.textLabel.text = @"动态创建一个类";
            break;
        case 5:
            cell.textLabel.text = @"动态的添加一个成员变量和方法";
            break;

        default:
            break;
    }
    return cell;


}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self getAllIvars];
            break;
           case 1:
            [self getAllProperty];
            break;
        case 2:
            [self getAllMethod];
            break;
        case 3:
            [self exchangeMethod];
            
            break;
        case 4:
            [self getClass];
            break;
        case 5:
            [self addProperty];
            break;
    
        default:
            break;
    }



}

-(void)getAllIvars{
    
    unsigned int outCount = 0;
    
    Ivar * ivars = class_copyIvarList([TestModel class], &outCount);
    
    for (int i = 0 ; i<outCount; i++) {
        Ivar ivar  = ivars[i];
        NSLog(@"%s",ivar_getName(ivar));
        
    }
    free(ivars);
}

-(void)getAllProperty{
   
    unsigned int count = 0;
    
    objc_property_t * propertyList = class_copyPropertyList([TestModel class], &count);
    
    NSMutableArray * propertyArray = [NSMutableArray array];
    
    for (int i = 0; i<count; i++) {
        
        objc_property_t property = propertyList[i];
      
        const char * propetyName= property_getName(property);
        
        NSLog(@"propertyName %s",propetyName);
        
        NSLog(@"propertyAttributrs: %s",property_getAttributes(property));
        
        NSString * proName = [[NSString alloc]initWithCString:propetyName encoding:NSUTF8StringEncoding];
        
        [propertyArray addObject:proName];
    }
    
    free(propertyList);
    

}

-(void)getAllMethod{

    unsigned int num = 0;
    
    Method * method = class_copyMethodList([TestModel class], &num);
    
    for (int i = 0; i<num; i++) {
        Method meth = method[i];
        SEL sel = method_getName(meth);
        const char * methodName = sel_getName(sel);
        
        NSLog(@"methodName  %@",[NSString stringWithUTF8String:methodName]);
        
    }

}

-(void)exchangeMethod{

    Method method1 =  class_getInstanceMethod([TestModel class], @selector(getNam1));
    
    Method method2 = class_getInstanceMethod([TestModel class], @selector(getAge1));
    
    method_exchangeImplementations(method1, method2);
    
   
    [[[TestModel alloc]init]getAge1];
    [[[TestModel alloc]init]getNam1];


}


-(void)getClass{
    Class cls = objc_allocateClassPair([NSObject class], "RunTimeClass", 0);
    
//      objc_registerClassPair(cls);
    
    NSLog(@"clsName %@   %@",NSStringFromClass(cls),[[[cls alloc]init] description]);
  
}
-(void)addProperty{
    /*  创建类
     *  参数1 父类  参数二 类名 参数3关于内存默认
     */
    Class  Hero = objc_allocateClassPair([NSObject class], "Hero", 0);
    
    class_addMethod(Hero, @selector(R:), (IMP)R, "@@:@");//添加方法
    
    class_addIvar(Hero, "Q", sizeof(NSString *), 0, "@");//添加成员变量
    class_addIvar(Hero, "W", sizeof(NSString *), 0, "@");//添加成员变量
    
    //添加属性实现setter  getter方法
    class_addMethod(Hero, @selector(setW:), (IMP)setW, "v@:@");
    class_addMethod(Hero, @selector(getW), (IMP)getW, "@@:");
    
    //注册类
    objc_registerClassPair(Hero);
    
    //实例化应用
    id hanbing = [[Hero alloc]init];
    
    //objc_setAssociatedObject 绑定key  value
    objc_setAssociatedObject(hanbing, @"beidong", @"寒冰的被动", OBJC_ASSOCIATION_COPY);
    NSLog(@"%@",objc_getAssociatedObject(hanbing, @"beidong"));
    
    //通过kvc设置上面定义的成员变量
    [hanbing setValue:@"寒冰射手的Q" forKey:@"Q"];
    
    [hanbing setW:@"寒冰的w"];
    NSLog(@"%@",[hanbing getW]);
    
    //类的属性
    objc_property_attribute_t type = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backingivar  = { "V", "E" };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    class_addProperty(Hero, "E", attrs, 3);
    
    //遍历属性查看
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([Hero class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        fprintf(stdout, "Hero %s : %s\n", property_getName(property), property_getAttributes(property));
    }
    
    [hanbing R:@"德玛西亚"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  OC方法

//OC方法不会调用，但是必须得写。实际调用IMP针织实现。
-(void)setW:(NSString *)w{
    
}

-(NSString *)getW{
    return nil;
}

-(NSString *)R:(NSString *)emery{
    
    return nil;
}

#pragma mark  IMP方法

void setW(id self,SEL cmd,NSString * str){
    Ivar  w = class_getInstanceVariable([self class], "W");
    NSString * oldW = object_getIvar(self, w);
    if (oldW!=str) {
        object_setIvar(self, w, [str copy]);
    }
}

NSString * getW(id self,SEL cmd){
    Ivar  w = class_getInstanceVariable([self class], "W");
    return object_getIvar(self, w);
}

id R(id self,SEL cmd,id emery){
    Ivar v  = class_getInstanceVariable([self class], "Q");
    NSString * vStr = object_getIvar(self, v);
    NSString * result = [NSString stringWithFormat:@"%@R死了%@",vStr,emery];
    NSLog(@"%@", result);
    return [NSString stringWithFormat:@"R死了%@",emery];
}


@end
