//
//  ViewController.m
//  SignInwithApple
//
//  Created by AlbertYuan on 2021/10/26.
//

#import "ViewController.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import <objc/runtime.h>

@interface ViewController () <ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>
@property (nonatomic, strong)  UILabel *appleIDInfoLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self configUI];
}

- (void)configUI{

    // 用于展示Sign In With Apple 登录过程的信息
    self.appleIDInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.4)];
    self.appleIDInfoLabel.font = [UIFont systemFontOfSize:22.0];
    self.appleIDInfoLabel.numberOfLines = 0;
    self.appleIDInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.appleIDInfoLabel.text = @"显示Sign In With Apple 登录信息\n";
    [self.view addSubview:self.appleIDInfoLabel];

    if (@available(iOS 13.0, *)) {
        // Sign In With Apple Button
        ASAuthorizationAppleIDButton *appleIDBtn = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeDefault style:ASAuthorizationAppleIDButtonStyleWhite];
        appleIDBtn.frame = CGRectMake(30, self.view.bounds.size.height - 180, self.view.bounds.size.width - 60, 100);
        //    appleBtn.cornerRadius = 22.f;
        [appleIDBtn addTarget:self action:@selector(handleAuthorizationAppleIDButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:appleIDBtn];
    }
}

// 处理授权
- (void)handleAuthorizationAppleIDButtonPress{
    NSLog(@"////////");

    if (@available(iOS 13.0, *)) {

        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];

        // 创建新的AppleID 授权请求
        ASAuthorizationAppleIDRequest *appleIDRequest = [appleIDProvider createRequest];
        // 在用户授权期间请求的联系信息
        appleIDRequest.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest]];

        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self;
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self;

        // 在控制器初始化期间启动授权流
        [authorizationController performRequests];
    }
}

// 如果存在iCloud Keychain 凭证或者AppleID 凭证提示用户
- (void)perfomExistingAccountSetupFlows{
    NSLog(@"///已经认证过了/////");
    if (@available(iOS 13.0, *)) {
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        // 授权请求AppleID
        ASAuthorizationAppleIDRequest *appleIDRequest = [appleIDProvider createRequest];
        // 为了执行钥匙串凭证分享生成请求的一种机制
        ASAuthorizationPasswordProvider *passwordProvider = [[ASAuthorizationPasswordProvider alloc] init];
        ASAuthorizationPasswordRequest *passwordRequest = [passwordProvider createRequest];
        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest, passwordRequest]];
        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self;
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self;
        // 在控制器初始化期间启动授权流
        [authorizationController performRequests];
    }
}

#pragma mark - delegate
//@optional 授权成功地回调
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization{
    NSLog(@"授权完成:::%@", authorization.credential);
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", controller);
    NSLog(@"%@", authorization);

    // 测试配置UI显示
    NSMutableString *mStr = [NSMutableString string];

    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // 用户登录使用ASAuthorizationAppleIDCredential:faceid
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        NSString *user = appleIDCredential.user;
        NSString *familyName = appleIDCredential.fullName.familyName;
        NSString *givenName = appleIDCredential.fullName.givenName;
        NSString *email = appleIDCredential.email;
        NSLog(@"%@",[[NSString alloc] initWithData:appleIDCredential.authorizationCode encoding:NSUTF8StringEncoding]);

        NSDictionary *dic = @{
            @"userIdentifier":user,
            @"code":[[NSString alloc] initWithData:appleIDCredential.authorizationCode encoding:NSUTF8StringEncoding]
        };

        [self authInServer:dic];

//        NSData *identityToken = appleIDCredential.identityToken;
//        NSData *authorizationCode = appleIDCredential.authorizationCode;
        // Create an account in your system.
        // For the purpose of this demo app, store the userIdentifier in the keychain.
        //  需要使用钥匙串的方式保存用户的唯一信息
//        [YostarKeychain save:KEYCHAIN_IDENTIFIER(@"userIdentifier") data:user];
//        [mStr appendString:user];
//        [mStr appendString:@"\n"];
//        [mStr appendString:familyName];
//        [mStr appendString:@"\n"];
//        [mStr appendString:givenName];
//        [mStr appendString:@"\n"];
//        [mStr appendString:email];
//        NSLog(@"mStr:::%@", mStr);
//        [mStr appendString:@"\n"];
        _appleIDInfoLabel.text = user;

    }else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]){
        // Sign in using an existing iCloud Keychain credential.
        // 用户登录使用现有的密码凭证
        ASPasswordCredential *passwordCredential = authorization.credential;
        // 密码凭证对象的用户标识 用户的唯一标识
        NSString *user = passwordCredential.user;
        // 密码凭证对象的密码
        NSString *password = passwordCredential.password;

//        [mStr appendString:user];
//        [mStr appendString:@"\n"];
//        [mStr appendString:password];
//        [mStr appendString:@"\n"];
//        NSLog(@"mStr:::%@", mStr);
        _appleIDInfoLabel.text = user;
    }else{
        NSLog(@"授权信息均不符");
        mStr = [@"授权信息均不符" copy];
        _appleIDInfoLabel.text = mStr;
    }
}

// 授权失败的回调
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error{
    // Handle error.
    NSLog(@"Handle error：%@", error);
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;

        default:
            break;
    }

    NSMutableString *mStr = [_appleIDInfoLabel.text mutableCopy];
    [mStr appendString:@"\n"];
    [mStr appendString:errorMsg];
    [mStr appendString:@"\n"];
    _appleIDInfoLabel.text = mStr;
}

// 告诉代理应该在哪个window 展示内容给用户
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller{
    NSLog(@"88888888888");
    // 返回window
    return self.view.window;
}

-(void)authInServer:(NSDictionary *)requestDic{

    NSLog(@"%@",requestDic);

    // 1.请求路径
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.157:8081/login/apple"];
    // 2.创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 设置 post 请求方式
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // 设置请求体
    //追加额外参
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDic options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    request.HTTPBody = [strJson dataUsingEncoding:NSUTF8StringEncoding];


    NSURLSession *session = [NSURLSession sharedSession];


    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSLog(@"response is : %@", response);
        if (error) {
                NSLog(@"NSURLSessionDataTaskerror:%@",error);
//            if (failed) {
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    failed(error);
//                }];
//            }
            return;
        }

        //5.解析数据
        NSLog(@"NSURLSessionDataTask:%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);

        NSError * dataErr;
        NSString * jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&dataErr];
        NSLog(@"%@",resultDic);

        if (dataErr) {
            NSLog(@"NSURLSessionDataTaskerror:%@",error);
//            if (failed) {
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    failed(dataErr);
//                }];
//            }
            return;
        }
//        if (success) {
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                success(resultDic);
//            }];
//        }
    }];
    [dataTask resume];
}

@end
