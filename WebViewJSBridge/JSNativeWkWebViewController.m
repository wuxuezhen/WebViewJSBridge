//
//  JSNativeWkWebViewController.m
//  WebViewJSBridge
//
//  Created by 吴振振 on 2018/5/24.
//  Copyright © 2018年 WZZ. All rights reserved.
//

#import "JSNativeWkWebViewController.h"
#import <WebKit/WebKit.h>
@interface JSNativeWkWebViewController ()<WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation JSNativeWkWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 创建UserContentController（提供JavaScript向webView发送消息的方法）
    [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    [self loadExamplePage:_webView];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 150, 150, 40);
    [button setTitle:@"native Call JS" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(callHander:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)loadExamplePage:(WKWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"NativeJs" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}



// oc 调用 js
- (void)callHander:(id)sender {
    [self.webView evaluateJavaScript:@"jsShowAlert()" completionHandler:^(NSString * message, NSError * _Nullable error) {
        // message 调用成功返回的信息
        [self showAlert:message];
    }];
}




// js 调用 oc
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
//    message.name 是我们 [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
//    根据name 做不同的操作
    NSDictionary * dic = message.body;
    NSString * urlStr = dic[@"body"];
    [self showAlert:urlStr];
    
}



-(void)showAlert:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"好", nil];
    [alert show];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    completionHandler();
    NSLog(@"-----%@",message);
}
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
    NSLog(@"-----%@",message);
}
// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *__nullable result))completionHandler{
    completionHandler(@"http");
    
    NSLog(@"－－－－－%@", prompt);
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
}

// 设置这个代理后 [_bridge setWebViewDelegate:self]; 这个方法是不会执行的，原因是是代理被接管后，第三方没有实现这个方法
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}




@end
