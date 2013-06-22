#import "TestHelper.h"

// Test case class without failWithException: method
@interface TestCaseClassWithoutFailMethod : NSObject
- (void)fail;
@end

@implementation TestCaseClassWithoutFailMethod
- (void)fail {
  EXPFail(self, 777, "test.m", @"epic fail");
}
@end

// Test case class with failWithException: method
@interface TestCaseClassWithFailMethod : TestCaseClassWithoutFailMethod {
  NSException *_exception;
}
@property(nonatomic, retain) NSException *exception;
- (void)failWithException:(NSException *)exception;
@end

@implementation TestCaseClassWithFailMethod
@synthesize exception=_exception;

- (void)dealloc {
  self.exception = nil;
  [super dealloc];
}

- (void)failWithException:(NSException *)exception {
  self.exception = exception;
}

@end

@interface EXPFailTest : XCTestCase
@end

@implementation EXPFailTest

- (void)test_EXPFailWithTestCaseClassThatDoesNotHaveFailureMethod {
  // it throws the exception directly
  TestCaseClassWithoutFailMethod *testCase = [TestCaseClassWithoutFailMethod new];
  @try {
    [testCase fail];
  } @catch(NSException *exception) {
    assertEqualObjects([exception name], @"Expecta Error");
    assertEqualObjects([exception reason], @"test.m:777 epic fail");
  }
  [testCase release];
}

- (void)test_EXPFailWithTestCaseClassThatHasFailureMethod {
  // it calls failWithException: method
  TestCaseClassWithFailMethod *testCase = [TestCaseClassWithFailMethod new];
  assertNil(testCase.exception);
  [testCase fail];
  NSException *exception = testCase.exception;
  assertEqualObjects([exception name], XCTestFailureException);
  assertEqualObjects([exception reason], @"epic fail");
  NSDictionary *exceptionUserInfo = [exception userInfo];
  assertEqualObjects([exceptionUserInfo objectForKey:XCTestDescriptionKey], @"epic fail");
  assertEqualObjects([exceptionUserInfo objectForKey:XCTestFilenameKey], @"test.m");
  assertEqualObjects([exceptionUserInfo objectForKey:XCTestLineNumberKey], [NSNumber numberWithInt:777]);
  [testCase release];
}

@end
