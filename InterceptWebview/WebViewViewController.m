//
//  WebViewViewController.m
//  InterceptWebview
//
//  Created by 康子文 on 17/3/6.
//  Copyright © 2017年 康子文. All rights reserved.
//

#import "WebViewViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define s_width [UIScreen mainScreen].bounds.size.width
#define s_height [UIScreen mainScreen].bounds.size.height
#define  RequestUrlStr @"http://image.baidu.com/wisehomepage/feeds?wiseps=1"//@"http://www.baidu.com"
@interface WebViewViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)  UIWebView *webview;

@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webview=[[UIWebView alloc] init];
    [self.view addSubview:_webview];
    _webview.frame=CGRectMake(0, 0, s_width, s_height);
    _webview.scalesPageToFit = YES;
    _webview.delegate=self;
    //_webview.scrollView.scrollEnabled= NO;
    _webview.backgroundColor=[UIColor whiteColor];

    NSURL *url = [[NSURL alloc] initWithString:RequestUrlStr];//
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [_webview loadRequest:request];

}

//网页加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //注册a标签回调
    [self getHerf:webView];
    [self getIMgs:webView];
    NSLog(@"urlstr=%@",webView.request.URL.absoluteString);
    // 获取html的title
    NSString *tileStr= [_webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    //获取img标签大于200*200的第一张图片的链接地址
    NSString *imgUrl= [self getWebViewPicSrc:webView];
    //加载完成获取html的文档高度
    NSString *scrollHeight= [_webview stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    
    NSLog(@"tileStr=%@  imgUrl=%@ scrollHeight=%@",tileStr,imgUrl,scrollHeight);
    //从webview中获得JSContext对象
    JSContext *context = [_webview  valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //这是截获a标签的事件，处理回调
    context[@"callOC"] = ^() {
        NSArray *args = [JSContext currentArguments];
        if(args.count>0){
            JSValue *jsv=args[0];
            NSString *urlString=[jsv toString];
            NSLog(@"urlString就是点击a标签的链接 ：%@",urlString);
        }
    };
    //这是截获img标签的事件，处理回调
    context[@"imgCallOC"] = ^() {
        NSArray *args = [JSContext currentArguments];
        NSLog(@"imgCallOC--%@",args[0]);
        if(args.count>0){
            JSValue *jsv=args[0];
            NSString *urlString=[jsv toString];
            NSLog(@"urlString就是点击图片的链接 ：%@",urlString);
        }
    };
}

#pragma mark  点击某一张图获取链接，html不响应事件，截取事件给oc代码响应
-(void)getIMgs:(UIWebView *)view{
    [view stringByEvaluatingJavaScriptFromString:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function getImgs(){"
     "if(document.getElementsByTagName('img').length>0){"
     "for(var i=0;i<document.getElementsByTagName('img').length;i++){"
     "var img1=document.getElementsByTagName('img')[i];"
     "img1.onclick=function(e){"
     "imgCallOC(this.src);"
     "window.event? window.event.cancelBubble= true:e.stopPropagation();"
     "return false;"
     "}"
     "}"
     "}"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    [view stringByEvaluatingJavaScriptFromString:@"getImgs();"];
}
#pragma mark  注入a标签链接回调,html不响应事件，截取事件给oc代码响应
-(void)getHerf:(UIWebView *)view{
    NSString *hrefStr=@"var script = document.createElement('script');"
    "script.type = 'text/javascript';"
    "script.text = \"function getHerdf(){"
    "if(document.getElementsByTagName('a').length>0){"
    "for(var i=0;i<document.getElementsByTagName('a').length;i++){"
    "var ka=document.getElementsByTagName('a')[i];"
    "ka.onclick=function (){"
    "if(this.href.indexOf('http')==0){"
    "callOC(this.href);"
    "return false;"
    "}"
    "}"
    "}"
    "}"
    "}\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [view stringByEvaluatingJavaScriptFromString:hrefStr];
    [view stringByEvaluatingJavaScriptFromString:@"getHerdf();"];
}
#pragma mark  获取img标签大于200*200的第一张图片的链接地址
-(NSString *)getWebViewPicSrc:(UIWebView *)view{
    [view stringByEvaluatingJavaScriptFromString:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function spider(){"
     "if(document.getElementsByTagName('img').length>0){"
     "for(var i=0;i<document.getElementsByTagName('img').length;i++){"
     "var img=document.getElementsByTagName('img')[i];"
     "if (img.naturalWidth) {"
     "if(img.naturalWidth>200){"
     "return img.src"
     "}"
     "}"
     "}"
     "}"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    return  [view stringByEvaluatingJavaScriptFromString:@"spider();"];
}


@end
