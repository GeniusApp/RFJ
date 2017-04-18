//
//  DataManager.m
//  rfj
//
//  Created by Nuno Silva on 22/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#import "Validation.h"
#import "DataManager.h"

@implementation DataManager

+ (NSString*) sha1:(NSString*)input {
    NSData *data = [input dataUsingEncoding: NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    return output;
}

- (id)init {
    if (self = [super init]) {
        self.backendURLs = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackendURLs" ofType:@"plist"]];
        self.soapConfig = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SoapConfig" ofType:@"plist"]];
        self.awsSnsConfig = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AWSSNSConfig" ofType:@"plist"]];
        self.adsAndStatisticConfig = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AdsAndStatisticConfig" ofType:@"plist"]];
    }
    return self;
}

- (BOOL)isRFJ {
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] isEqualToString:@"RFJ"];
}

- (BOOL)isRJB {
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] isEqualToString:@"RJB"];
}

- (BOOL)isRTN {
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] isEqualToString:@"RTN"];
}

-(void)sendInfoReportWithTitle:(NSString *)title email:(NSString *)email description:(NSString *)description phone:(NSString *)phone image:(NSData *)image successBlock:(void(^)())successBlock
               andFailureBlock:(void(^)(NSError *error))failureBlock {
    NSString *requestURL = [self.soapConfig objectForKey:@"SoapURL"];
    NSString *soapNamespace = [self.soapConfig objectForKey:@"SoapNamespace"];
    NSString *soapAction = [NSString stringWithFormat:@"%@/%@", [self.soapConfig objectForKey:@"SoapNamespace"],
                            [self.soapConfig objectForKey:@"SoapMethodSendNews"]];
    NSString *soapMethod = [self.soapConfig objectForKey:@"SoapMethodSendNews"];
    
    // Compute the signature of the message
    NSString *mailKey = [self.soapConfig objectForKey:@"MailKey"];
    CGFloat now = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *timeStamp = [[NSString stringWithFormat:@"%.2f", fabsf(now)] stringByReplacingOccurrencesOfString:@".00" withString:@""];
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@%@%@", timeStamp, mailKey, description, email];
    NSString *signature = [DataManager sha1:stringToHash];
    
    NSMutableString *soapMessage = [NSMutableString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><%@ xmlns=\"%@\">", soapMethod, soapNamespace];
    
    NSString *byteArray  = [image base64Encoding];
    
    [soapMessage appendFormat:@"<title>%@</title>", title];
    [soapMessage appendFormat:@"<description>%@</description>", description];
    [soapMessage appendFormat:@"<phone>%@</phone>", phone];
    [soapMessage appendFormat:@"<email>%@</email>", email];
    [soapMessage appendFormat:@"<timestamp>%@</timestamp>", timeStamp];
    [soapMessage appendFormat:@"<hash>%@</hash>", signature];
    [soapMessage appendFormat:@"<image>%@</image>", byteArray];//[infoReport.image mutableBytes]];
    
    [soapMessage appendFormat:@"</%@></soap:Body></soap:Envelope>", soapMethod];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]                                                        cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:1000];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"www.rfj.ch" forHTTPHeaderField:@"Host"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [request setValue:[NSString stringWithFormat:@"%d", (uint)soapMessage.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/xml"];
    
    NSURLSessionTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(VALID(error, NSError)) {
            NSLog(@"SOAP Error: %@", [error localizedDescription]);

            if(failureBlock) {
                failureBlock(error);
            }
        }
        else {
            if(VALID_NOTEMPTY(responseObject, NSData)) {
                NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                if(VALID_NOTEMPTY(responseString, NSString)) {
                    NSLog(@"SOAP Response: %@", responseString);
                }

                if(successBlock) {
                    successBlock();
                }
            }
            else {
                if(failureBlock) {
                    failureBlock(error);
                }
            }
        }
    }];
    
    [task resume];
}

@end
