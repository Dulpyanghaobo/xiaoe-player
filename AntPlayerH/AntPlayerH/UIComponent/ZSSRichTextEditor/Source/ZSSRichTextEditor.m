//
//  ZSSRichTextEditorViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "ZSSRichTextEditor.h"
#import "ZSSBarButtonItem.h"
#import "HRColorUtil.h"
#import "ZSSTextView.h"

@import JavaScriptCore;


/**
 
 WKWebView modifications for hiding the inputAccessoryView
 
 **/
@interface WKWebView (HackishAccessoryHiding)
@property (nonatomic, assign) BOOL hidesInputAccessoryView;
@end

@implementation WKWebView (HackishAccessoryHiding)

static const char * const hackishFixClassName = "WKWebBrowserViewMinusAccessoryView";
static Class hackishFixClass = Nil;

- (UIView *)hackishlyFoundBrowserView {
    UIScrollView *scrollView = self.scrollView;
    
    UIView *browserView = nil;
    for (UIView *subview in scrollView.subviews) {
        if ([NSStringFromClass([subview class]) hasPrefix:@"WKWebBrowserView"]) {
            browserView = subview;
            break;
        }
    }
    return browserView;
}

- (id)methodReturningNil {
    return nil;
}

- (void)ensureHackishSubclassExistsOfBrowserViewClass:(Class)browserViewClass {
    if (!hackishFixClass) {
        Class newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        IMP nilImp = [self methodForSelector:@selector(methodReturningNil)];
        class_addMethod(newClass, @selector(inputAccessoryView), nilImp, "@@:");
        objc_registerClassPair(newClass);
        
        hackishFixClass = newClass;
    }
}

- (BOOL) hidesInputAccessoryView {
    UIView *browserView = [self hackishlyFoundBrowserView];
    return [browserView class] == hackishFixClass;
}

- (void) setHidesInputAccessoryView:(BOOL)value {
    UIView *browserView = [self hackishlyFoundBrowserView];
    if (browserView == nil) {
        return;
    }
    [self ensureHackishSubclassExistsOfBrowserViewClass:[browserView class]];
    
    if (value) {
        object_setClass(browserView, hackishFixClass);
    }
    else {
        Class normalClass = objc_getClass("WKWebBrowserView");
        object_setClass(browserView, normalClass);
    }
    [browserView reloadInputViews];
}

@end


@interface ZSSRichTextEditor ()

/*
 *  Scroll view containing the toolbar
 */
@property (nonatomic, strong) UIScrollView *toolBarScroll;

/*
 *  Toolbar containing ZSSBarButtonItems
 */
@property (nonatomic, strong) UIToolbar *toolbar;

/*
 *  Holder for all of the toolbar components
 */
@property (nonatomic, strong) UIView *toolbarHolder;

/*
 *  String for the HTML
 */
@property (nonatomic, strong) NSString *htmlString;

/*
 *  WKWebView for writing/editing/displaying the content
 */
@property (nonatomic, strong) WKWebView *editorView;

/*
 *  ZSSTextView for displaying the source code for what is displayed in the editor view
 */
@property (nonatomic, strong) ZSSTextView *sourceView;

/*
 *  CGRect for holding the frame for the editor view
 */
@property (nonatomic) CGRect editorViewFrame;

/*
 *  BOOL for holding if the resources are loaded or not
 */
@property (nonatomic) BOOL resourcesLoaded;

/*
 *  Array holding the enabled editor items
 */
@property (nonatomic, strong) NSArray *editorItemsEnabled;

/*
 *  Alert View used when inserting links/images
 */
@property (nonatomic, strong) UIAlertView *alertView;

/*
 *  NSString holding the selected links URL value
 */
@property (nonatomic, strong) NSString *selectedLinkURL;

/*
 *  NSString holding the selected links title value
 */
@property (nonatomic, strong) NSString *selectedLinkTitle;

/*
 *  NSString holding the selected image URL value
 */
@property (nonatomic, strong) NSString *selectedImageURL;

/*
 *  NSString holding the selected image Alt value
 */
@property (nonatomic, strong) NSString *selectedImageAlt;

/*
 *  CGFloat holdign the selected image scale value
 */
@property (nonatomic, assign) CGFloat selectedImageScale;

/*
 *  NSString holding the base64 value of the current image
 */
@property (nonatomic, strong) NSString *imageBase64String;

/*
 *  Bar button item for the keyboard dismiss button in the toolbar
 */
@property (nonatomic, strong) UIBarButtonItem *keyboardItem;

/*
 *  Array for custom bar button items
 */
@property (nonatomic, strong) NSMutableArray *customBarButtonItems;

/*
 *  Array for custom ZSSBarButtonItems
 */
@property (nonatomic, strong) NSMutableArray *customZSSBarButtonItems;

/*
 *  NSString holding the html
 */
@property (nonatomic, strong) NSString *internalHTML;

/*
 *  NSString holding the css
 */
@property (nonatomic, strong) NSString *customCSS;

/*
 *  BOOL for if the editor is loaded or not
 */
@property (nonatomic) BOOL editorLoaded;

/*
 *  BOOL for if the editor is paste or not
 */
@property (nonatomic) BOOL editorPaste;
/*
 *  Image Picker for selecting photos from users photo library
 */
@property (nonatomic, strong) UIImagePickerController *imagePicker;


// local var to hold first responder state after callback
@property (nonatomic) BOOL isFirstResponderUpdated;

/*
 *  Method for getting a version of the html without quotes
 */
- (NSString *)removeQuotesFromHTML:(NSString *)html;

/*
 *  Method for getting a tidied version of the html
 */
- (void)tidyHTML:(NSString *)html completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

/*
 * Method for enablign toolbar items
 */
- (void)enableToolbarItems:(BOOL)enable;

/*
 *  Setter for isIpad BOOL
 */
- (BOOL)isIpad;

@end

/*
 
 ZSSRichTextEditor
 
 */
@implementation ZSSRichTextEditor

//Scale image from device
static CGFloat kJPEGCompression = 0.8;
static CGFloat kDefaultScale = 0.5;

#pragma mark - View Did Load Section
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Initialise variables
    self.editorLoaded = NO;
    self.receiveEditorDidChangeEvents = NO;
    self.alwaysShowToolbar = NO;
    self.shouldShowKeyboard = YES;
    self.formatHTML = YES;
    
    //Initalise enabled toolbar items array
    self.enabledToolbarItems = [[NSArray alloc] init];
    
    //Frame for the source view and editor view
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    //Source View
    [self createSourceViewWithFrame:frame];
    
    //Editor View
    [self createEditorViewWithFrame:frame];
    
    //Image Picker used to allow the user insert images from the device (base64 encoded)
    [self setUpImagePicker];
    
    //Scrolling View
    [self createToolBarScroll];
    
    //Toolbar with icons
    [self createToolbar];
    
    //Parent holding view
    [self createParentHoldingView];
    
    //Hide Keyboard
    if (![self isIpad]) {
        NSBundle* bundle = [NSBundle bundleForClass:[ZSSRichTextEditor class]];
        
        // Toolbar holder used to crop and position toolbar
        UIView *toolbarCropper = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-44, 0, 44, 44)];
        toolbarCropper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        toolbarCropper.clipsToBounds = YES;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        
        [btn addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [[UIImage systemImageNamed:@"arrowtriangle.down.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setTintColor:[self barButtonItemDefaultColor]];
        
        [toolbarCropper addSubview:btn];
        
        [self.toolbarHolder addSubview:toolbarCropper];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.6f, 44)];
        line.backgroundColor = [UIColor lightGrayColor];
        line.alpha = 0.7f;
        [toolbarCropper addSubview:line];
        
    }
    
    [self.view addSubview:self.toolbarHolder];
    
    //Build the toolbar
    [self buildToolbar];
    
    //Load Resources
    if (!self.resourcesLoaded) {
        
        [self loadResources];
        
    }
    
}

#pragma mark - View Will Appear Section
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //Add observers for keyboard showing or hiding notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - View Will Disappear Section
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    //Remove observers for keyboard showing or hiding notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

#pragma mark - Set Up View Section

- (void)createSourceViewWithFrame:(CGRect)frame {
    
    self.sourceView = [[ZSSTextView alloc] initWithFrame:frame];
    self.sourceView.hidden = YES;
    self.sourceView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.sourceView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.sourceView.font = [UIFont fontWithName:@"Courier" size:13.0];
    self.sourceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.sourceView.autoresizesSubviews = YES;
    self.sourceView.delegate = self;
    [self.view addSubview:self.sourceView];
    
}

- (void)createEditorViewWithFrame:(CGRect)frame {
    
    
    //allocate config and contentController and add scriptMessageHandler
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    [contentController addScriptMessageHandler:self name:@"jsm"];
    
    config.userContentController = contentController;

    //load scripts
    NSString *scriptString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";

    WKUserScript *script = [[WKUserScript alloc] initWithSource:scriptString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    [contentController addUserScript:script];
    
    
    //set data detection to none so it doesnt conflict
    config.dataDetectorTypes = WKDataDetectorTypeNone;
    

    
    self.editorView = [[WKWebView alloc] initWithFrame:frame
                                         configuration: config];

    
    self.editorView.UIDelegate = self;
    self.editorView.navigationDelegate = self;
    self.editorView.hidesInputAccessoryView = YES;
    
    //TODO: Is this behavior correct? Is it the right replacement?
//    self.editorView.keyboardDisplayRequiresUserAction = NO;
    [ZSSRichTextEditor allowDisplayingKeyboardWithoutUserAction];

    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.editorView.scrollView.bounces = YES;
    self.editorView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.editorView];
    
}

- (void)setUpImagePicker {
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.allowsEditing = YES;
    self.selectedImageScale = kDefaultScale; //by default scale to half the size
    
}

- (void)createToolBarScroll {
    
    self.toolBarScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self isIpad] ? self.view.frame.size.width : self.view.frame.size.width - 44, 44)];
    self.toolBarScroll.backgroundColor = [UIColor clearColor];
    self.toolBarScroll.showsHorizontalScrollIndicator = NO;
    
}

- (void)createToolbar {
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.toolbar.backgroundColor = [UIColor clearColor];
    [self.toolBarScroll addSubview:self.toolbar];
    self.toolBarScroll.autoresizingMask = self.toolbar.autoresizingMask;
    
}

- (void)createParentHoldingView {
    
    //Background Toolbar
    UIToolbar *backgroundToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //Parent holding view
    self.toolbarHolder = [[UIView alloc] init];
    
    if (_alwaysShowToolbar) {
        self.toolbarHolder.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    } else {
        self.toolbarHolder.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44);
    }
    
    self.toolbarHolder.autoresizingMask = self.toolbar.autoresizingMask;
    [self.toolbarHolder addSubview:self.toolBarScroll];
    [self.toolbarHolder insertSubview:backgroundToolbar atIndex:0];
    
}

#pragma mark - Convenience replacement for keyboardDisplayRequiresUserAction in WKWebview

+ (void)allowDisplayingKeyboardWithoutUserAction {
    Class class = NSClassFromString(@"WKContentView");
    NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};
    NSOperatingSystemVersion iOS_12_2_0 = (NSOperatingSystemVersion){12, 2, 0};
    NSOperatingSystemVersion iOS_13_0_0 = (NSOperatingSystemVersion){13, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_13_0_0]) {
        SEL selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
        ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    }
   else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_12_2_0]) {
        SEL selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
        ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    }
    else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    } else {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
        });
        method_setImplementation(method, override);
    }
}

#pragma mark - Resources Section

- (void)loadResources {
    
    //Define correct bundle for loading resources
    NSBundle* bundle = [NSBundle bundleForClass:[ZSSRichTextEditor class]];
    
    //Create a string with the contents of editor.html
    NSString *filePath = [bundle pathForResource:@"editor" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    //Add jQuery.js to the html file
    NSString *jquery = [bundle pathForResource:@"jQuery" ofType:@"js"];
    NSString *jqueryString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:jquery] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jQuery -->" withString:jqueryString];
    
    //Add JSBeautifier.js to the html file
    NSString *beautifier = [bundle pathForResource:@"JSBeautifier" ofType:@"js"];
    NSString *beautifierString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:beautifier] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jsbeautifier -->" withString:beautifierString];
    
    //Add ZSSRichTextEditor.js to the html file
    NSString *source = [bundle pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
    
    [self.editorView loadHTMLString:htmlString baseURL:self.baseURL];
    self.resourcesLoaded = YES;
    
}

#pragma mark - Toolbar Section

- (void)setEnabledToolbarItems:(NSArray *)enabledToolbarItems {
    
    _enabledToolbarItems = enabledToolbarItems;
    [self buildToolbar];
    
}


- (void)setToolbarItemTintColor:(UIColor *)toolbarItemTintColor {
    
    _toolbarItemTintColor = toolbarItemTintColor;
    
    // Update the color
    for (ZSSBarButtonItem *item in self.toolbar.items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
    self.keyboardItem.tintColor = toolbarItemTintColor;
    
}


- (void)setToolbarItemSelectedTintColor:(UIColor *)toolbarItemSelectedTintColor {
    
    _toolbarItemSelectedTintColor = toolbarItemSelectedTintColor;
    
}

- (NSArray *)itemsForToolbar {
    
    //Define correct bundle for loading resources
    NSBundle* bundle = [NSBundle bundleForClass:[ZSSRichTextEditor class]];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // None
    if(_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarNone])
    {
        return items;
    }
    
    BOOL customOrder = NO;
    if (_enabledToolbarItems && ![_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll]){
        customOrder = YES;
        for(int i=0; i < _enabledToolbarItems.count;i++){
            [items addObject:@""];
        }
    }
    
    // Bold
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarBold]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *bold = [[ZSSBarButtonItem alloc] initWithImage:[[UIImage systemImageNamed:@"b.circle"] imageWithTintColor:[UIColor blackColor]] style:UIBarButtonItemStylePlain target:self action:@selector(setBold)];
        bold.label = @"bold";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarBold] withObject:bold];
        } else {
            [items addObject:bold];
        }
    }
    
    // Italic
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarItalic]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *italic = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSitalic.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setItalic)];
        italic.label = @"italic";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarItalic] withObject:italic];
        } else {
            [items addObject:italic];
        }
    }
    
    // Subscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarSubscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *subscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsubscript.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setSubscript)];
        subscript.label = @"subscript";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarSubscript] withObject:subscript];
        } else {
            [items addObject:subscript];
        }
    }
    
    // Superscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarSuperscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *superscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsuperscript.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setSuperscript)];
        superscript.label = @"superscript";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarSuperscript] withObject:superscript];
        } else {
            [items addObject:superscript];
        }
    }
    
    // Strike Through
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarStrikeThrough]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *strikeThrough = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSstrikethrough.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setStrikethrough)];
        strikeThrough.label = @"strikeThrough";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarStrikeThrough] withObject:strikeThrough];
        } else {
            [items addObject:strikeThrough];
        }
    }
    
    // Underline
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUnderline]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *underline = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunderline.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setUnderline)];
        underline.label = @"underline";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarUnderline] withObject:underline];
        } else {
            [items addObject:underline];
        }
    }
    
    // Remove Format
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRemoveFormat]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *removeFormat = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSclearstyle.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(removeFormat)];
        removeFormat.label = @"removeFormat";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarRemoveFormat] withObject:removeFormat];
        } else {
            [items addObject:removeFormat];
        }
    }
    
    //  Fonts
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarFonts]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        
        ZSSBarButtonItem *fonts = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSfonts.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(showFontsPicker)];
        fonts.label = @"fonts";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarFonts] withObject:fonts];
        } else {
            [items addObject:fonts];
        }
        
    }
    
    // Undo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUndo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *undoButton = [[ZSSBarButtonItem alloc] initWithImage:[[UIImage systemImageNamed:@"arrow.uturn.backward"] imageWithTintColor:[UIColor blackColor]] style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
        undoButton.label = @"undo";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarUndo] withObject:undoButton];
        } else {
            [items addObject:undoButton];
        }
    }
    
    // Redo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRedo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *redoButton = [[ZSSBarButtonItem alloc] initWithImage:[[UIImage systemImageNamed:@"arrow.uturn.forward"] imageWithTintColor:[UIColor blackColor]] style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
        redoButton.label = @"redo";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarRedo] withObject:redoButton];
        } else {
            [items addObject:redoButton];
        }
    }
    
    // Align Left
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyLeft]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignLeft = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSleftjustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignLeft)];
        alignLeft.label = @"justifyLeft";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarJustifyLeft] withObject:alignLeft];
        } else {
            [items addObject:alignLeft];
        }
    }
    
    // Align Center
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyCenter]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignCenter = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSScenterjustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignCenter)];
        alignCenter.label = @"justifyCenter";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarJustifyCenter] withObject:alignCenter];
        } else {
            [items addObject:alignCenter];
        }
    }
    
    // Align Right
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyRight]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignRight = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSrightjustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignRight)];
        alignRight.label = @"justifyRight";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarJustifyRight] withObject:alignRight];
        } else {
            [items addObject:alignRight];
        }
    }
    
    // Align Justify
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyFull]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignFull = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSforcejustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignFull)];
        alignFull.label = @"justifyFull";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarJustifyFull] withObject:alignFull];
        } else {
            [items addObject:alignFull];
        }
    }
    
    // Paragraph
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarParagraph]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *paragraph = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSparagraph.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(paragraph)];
        paragraph.label = @"p";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarParagraph] withObject:paragraph];
        } else {
            [items addObject:paragraph];
        }
    }
    
    // Header 1
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH1]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h1 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh1.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading1)];
        h1.label = @"h1";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH1] withObject:h1];
        } else {
            [items addObject:h1];
        }
    }
    
    // Header 2
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH2]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h2 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh2.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading2)];
        h2.label = @"h2";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH2] withObject:h2];
        } else {
            [items addObject:h2];
        }
    }
    
    // Header 3
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH3]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h3 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh3.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading3)];
        h3.label = @"h3";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH3] withObject:h3];
        } else {
            [items addObject:h3];
        }
    }
    
    // Heading 4
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH4]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h4 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh4.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading4)];
        h4.label = @"h4";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH4] withObject:h4];
        } else {
            [items addObject:h4];
        }
    }
    
    // Header 5
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH5]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h5 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh5.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading5)];
        h5.label = @"h5";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH5] withObject:h5];
        } else {
            [items addObject:h5];
        }
    }
    
    // Heading 6
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH6]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h6 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh6.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading6)];
        h6.label = @"h6";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH6] withObject:h6];
        } else {
            [items addObject:h6];
        }
    }
    
    // Text Color
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarTextColor]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *textColor = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSStextcolor.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(textColor)];
        textColor.label = @"textColor";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarTextColor] withObject:textColor];
        } else {
            [items addObject:textColor];
        }
    }
    
    // Background Color
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarBackgroundColor]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *bgColor = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSbgcolor.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(bgColor)];
        bgColor.label = @"backgroundColor";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarBackgroundColor] withObject:bgColor];
        } else {
            [items addObject:bgColor];
        }
    }
    
    // Unordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUnorderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *ul = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunorderedlist.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setUnorderedList)];
        ul.label = @"unorderedList";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarUnorderedList] withObject:ul];
        } else {
            [items addObject:ul];
        }
    }
    
    // Ordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarOrderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *ol = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSorderedlist.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setOrderedList)];
        ol.label = @"orderedList";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarOrderedList] withObject:ol];
        } else {
            [items addObject:ol];
        }
    }
    
    // Horizontal Rule
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarHorizontalRule]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *hr = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSShorizontalrule.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setHR)];
        hr.label = @"horizontalRule";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarHorizontalRule] withObject:hr];
        } else {
            [items addObject:hr];
        }
    }
    
    // Indent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarIndent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *indent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSindent.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setIndent)];
        indent.label = @"indent";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarIndent] withObject:indent];
        } else {
            [items addObject:indent];
        }
    }
    
    // Outdent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarOutdent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *outdent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSoutdent.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setOutdent)];
        outdent.label = @"outdent";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarOutdent] withObject:outdent];
        } else {
            [items addObject:outdent];
        }
    }
    
    // Image
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertImage]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertImage = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSimage.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(insertImage)];
        insertImage.label = @"image";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarInsertImage] withObject:insertImage];
        } else {
            [items addObject:insertImage];
        }
    }
    
    // Image From Device
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertImageFromDevice]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertImageFromDevice = [[ZSSBarButtonItem alloc] initWithImage:[[UIImage systemImageNamed:@"photo.fill"] imageWithTintColor:[UIColor blackColor]] style:UIBarButtonItemStylePlain target:self action:@selector(insertImageFromDevice)];
        insertImageFromDevice.label = @"imageFromDevice";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarInsertImageFromDevice] withObject:insertImageFromDevice];
        } else {
            [items addObject:insertImageFromDevice];
        }
    }
   
    // Insert Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSlink.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(insertLink)];
        insertLink.label = @"link";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarInsertLink] withObject:insertLink];
        } else {
            [items addObject:insertLink];
        }
    }
    
    // Remove Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRemoveLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *removeLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunlink.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(removeLink)];
        removeLink.label = @"removeLink";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarRemoveLink] withObject:removeLink];
        } else {
            [items addObject:removeLink];
        }
    }
    
    // Quick Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarQuickLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *quickLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSquicklink.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(quickLink)];
        quickLink.label = @"quickLink";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarQuickLink] withObject:quickLink];
        } else {
            [items addObject:quickLink];
        }
    }
    
    // Show Source
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarViewSource]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *showSource = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSviewsource.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(showHTMLSource:)];
        showSource.label = @"source";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarViewSource] withObject:showSource];
        } else {
            [items addObject:showSource];
        }
    }
    
    return [NSArray arrayWithArray:items];
    
}


- (void)buildToolbar {
    
    // Check to see if we have any toolbar items, if not, add them all
    NSArray *items = [self itemsForToolbar];
    if (items.count == 0 && !(_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarNone])) {
        _enabledToolbarItems = @[ZSSRichTextEditorToolbarAll];
        items = [self itemsForToolbar];
    }
    
    if (self.customZSSBarButtonItems != nil) {
        items = [items arrayByAddingObjectsFromArray:self.customZSSBarButtonItems];
    }
    
    // get the width before we add custom buttons
    CGFloat toolbarWidth = items.count == 0 ? 0.0f : (CGFloat)(items.count * 44);
    
    if(self.customBarButtonItems != nil)
    {
        items = [items arrayByAddingObjectsFromArray:self.customBarButtonItems];
        for(ZSSBarButtonItem *buttonItem in self.customBarButtonItems)
        {
            toolbarWidth += buttonItem.customView.frame.size.width + 11.0f;
        }
    }
    
    self.toolbar.items = items;
    for (ZSSBarButtonItem *item in items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
    
    self.toolbar.frame = CGRectMake(0, 0, toolbarWidth, 44);
    self.toolBarScroll.contentSize = CGSizeMake(self.toolbar.frame.size.width, 44);
}


#pragma mark - Editor Modification Section

- (void)setCSS:(NSString *)css {
    
    self.customCSS = css;
    
    if (self.editorLoaded) {
        [self updateCSS];
    }
    
}

- (void)updateCSS {
    
    if (self.customCSS != NULL && [self.customCSS length] != 0) {
        
        NSString *js = [NSString stringWithFormat:@"zss_editor.setCustomCSS(\"%@\");", self.customCSS];
        [self.editorView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error) {
         
        }];
        
    }
}

- (void)setPlaceholderText {
    
    //Call the setPlaceholder javascript method if a placeholder has been set
    if (self.placeholder != NULL && [self.placeholder length] != 0) {
        
        NSString *js = [NSString stringWithFormat:@"zss_editor.setPlaceholder(\"%@\");", self.placeholder];
        [self.editorView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error) {
         
        }];

        
    }
    
}

- (void)setFooterHeight:(float)footerHeight {
    
    //Call the setFooterHeight javascript method
    NSString *js = [NSString stringWithFormat:@"zss_editor.setFooterHeight(\"%f\");", footerHeight];
    [self.editorView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error) {
     
    }];

    
}

- (void)setContentHeight:(float)contentHeight {
    
    //Call the contentHeight javascript method
    NSString *js = [NSString stringWithFormat:@"zss_editor.contentHeight = %f;", contentHeight];
    [self.editorView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error) {
     
    }];

    
}

#pragma mark - Editor Interaction

- (void)focusTextEditor {
    
    //TODO: Is this behavior correct? Is it the right replacement?
//    self.editorView.keyboardDisplayRequiresUserAction = NO;
    [ZSSRichTextEditor allowDisplayingKeyboardWithoutUserAction];
    
    NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
    [self.editorView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error) {
     
    }];

}

- (void)blurTextEditor {
    NSString *js = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self.editorView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error) {
     
    }];

}

- (void)setHTML:(NSString *)html {
    
    self.internalHTML = html;
    
    if (self.editorLoaded) {
        [self updateHTML];
    }
    
}

- (void)updateHTML {
    
    NSString *html = self.internalHTML;
    self.sourceView.text = html;
    NSString *cleanedHTML = [self removeQuotesFromHTML:self.sourceView.text];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {

    }];

    
}

- (void)getHTML:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler {
    
    
    [self.editorView evaluateJavaScript:ZSSEditorHTML completionHandler:^(NSString *result, NSError *error) {
        
        if (error != NULL) {
            NSLog(@"HTML Parsing Error: %@", error);
        }
        
        NSLog(@"%@", result);
     
        NSString *html = [self removeQuotesFromHTML:result];
        
        NSLog(@"%@", html);
        
        [self tidyHTML:html completionHandler:^(NSString *result, NSError *error) {
            completionHandler(result, error);
        }];

    }];
}


- (void)insertHTML:(NSString *)html {
    
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];

}

- (void)getText:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler {
    
    [self.editorView evaluateJavaScript:ZSSEditorText completionHandler:^(NSString *result, NSError *error) {
        
        if (error != NULL) {
            NSLog(@"Text Parsing Error: %@", error);
        }
        
        
        completionHandler(result, error);
    }];
}

- (void)updateEditor {
    [self getHTML:^(NSString *htmlResult, NSError * _Nullable error) {
        [self getText:^(NSString *textResult, NSError * _Nullable error) {
            [self editorDidChangeWithText:textResult andHTML:htmlResult];
        }];
    }];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)isFirstResponder {
    
    [self.editorView evaluateJavaScript:ZSSEditorContent completionHandler:^(NSNumber *result, NSError *error) {
        
        //save the result as a bool and then update the UI
        self.isFirstResponderUpdated = [result boolValue];
        if (self.isFirstResponderUpdated == true) {
            [self becomeFirstResponder];
        } else {
            [self resignFirstResponder];
        }
    }];
    
    //this state is old and will quickly be updated after the callback above completes
    //TODO: refactor to find a more elegant approach
    return self.isFirstResponderUpdated;
}

- (void)showHTMLSource:(ZSSBarButtonItem *)barButtonItem {
    if (self.sourceView.hidden) {
        
        [self getHTML:^(NSString *result, NSError * _Nullable error) {
            self.sourceView.text = result;
        }];
        
        self.sourceView.hidden = NO;
        barButtonItem.tintColor = [UIColor blackColor];
        self.editorView.hidden = YES;
        [self enableToolbarItems:NO];
    } else {
        [self setHTML:self.sourceView.text];
        barButtonItem.tintColor = [self barButtonItemDefaultColor];
        self.sourceView.hidden = YES;
        self.editorView.hidden = NO;
        [self enableToolbarItems:YES];
    }
}

- (void)removeFormat {
    NSString *trigger = @"zss_editor.removeFormating();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)alignLeft {
    NSString *trigger = @"zss_editor.setJustifyLeft();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)alignCenter {
    NSString *trigger = @"zss_editor.setJustifyCenter();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)alignRight {
    NSString *trigger = @"zss_editor.setJustifyRight();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)alignFull {
    NSString *trigger = @"zss_editor.setJustifyFull();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setBold {
    NSString *trigger = @"zss_editor.setBold();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {

    }];
}

- (void)setItalic {
    NSString *trigger = @"zss_editor.setItalic();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setSubscript {
    NSString *trigger = @"zss_editor.setSubscript();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setUnderline {
    NSString *trigger = @"zss_editor.setUnderline();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setSuperscript {
    NSString *trigger = @"zss_editor.setSuperscript();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setStrikethrough {
    NSString *trigger = @"zss_editor.setStrikeThrough();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setUnorderedList {
    NSString *trigger = @"zss_editor.setUnorderedList();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setOrderedList {
    NSString *trigger = @"zss_editor.setOrderedList();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setHR {
    NSString *trigger = @"zss_editor.setHorizontalRule();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setIndent {
    NSString *trigger = @"zss_editor.setIndent();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setOutdent {
    NSString *trigger = @"zss_editor.setOutdent();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)heading1 {
    NSString *trigger = @"zss_editor.setHeading('h1');";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)getTimeStamp {
    NSString *trigger = @"zss_editor.addTimestampClickListener();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)setTimeStamp:(NSString *)timestamp {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.addFlagButtonWithTimestamp('%@');", timestamp];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)heading2 {
    NSString *trigger = @"zss_editor.setHeading('h2');";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)heading3 {
    NSString *trigger = @"zss_editor.setHeading('h3');";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)heading4 {
    NSString *trigger = @"zss_editor.setHeading('h4');";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)heading5 {
    NSString *trigger = @"zss_editor.setHeading('h5');";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)heading6 {
    NSString *trigger = @"zss_editor.setHeading('h6');";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)paragraph {
    NSString *trigger = @"zss_editor.setParagraph();";
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)showFontsPicker {
    
    // Save the selection location
    [self.editorView evaluateJavaScript:@"zss_editor.prepareInsert();" completionHandler:^(NSString *result, NSError *error) {
     
    }];
    
    //Call picker
    ZSSFontsViewController *fontPicker = [ZSSFontsViewController cancelableFontPickerViewControllerWithFontFamily:ZSSFontFamilyDefault];
    fontPicker.delegate = self;
    [self.navigationController pushViewController:fontPicker animated:YES];
    
}

- (void)setSelectedFontFamily:(ZSSFontFamily)fontFamily {
    
    NSString *fontFamilyString;
    
    switch (fontFamily) {
        case ZSSFontFamilyDefault:
            fontFamilyString = @"Arial, Helvetica, sans-serif";
            break;
            
        case ZSSFontFamilyGeorgia:
            fontFamilyString = @"Georgia, serif";
            break;
            
        case ZSSFontFamilyPalatino:
            fontFamilyString = @"Palatino Linotype, Book Antiqua, Palatino, serif";
            break;
            
        case ZSSFontFamilyTimesNew:
            fontFamilyString = @"Times New Roman, Times, serif";
            break;
            
        case ZSSFontFamilyTrebuchet:
            fontFamilyString = @"Trebuchet MS, Helvetica, sans-serif";
            break;
            
        case ZSSFontFamilyVerdana:
            fontFamilyString = @"Verdana, Geneva, sans-serif";
            break;
            
        case ZSSFontFamilyCourierNew:
            fontFamilyString = @"Courier New, Courier, monospace";
            break;
            
        default:
            fontFamilyString = @"Arial, Helvetica, sans-serif";
            break;
    }
    
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setFontFamily(\"%@\");", fontFamilyString];
    
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)textColor {
    
    // Save the selection location
    [self.editorView evaluateJavaScript:@"zss_editor.prepareInsert();" completionHandler:^(NSString *result, NSError *error) {
     
    }];
    
    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 1;
    colorPicker.title = NSLocalizedString(@"Text Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
    
}

- (void)bgColor {
    
    // Save the selection location
    [self.editorView evaluateJavaScript:@"zss_editor.prepareInsert();" completionHandler:^(NSString *result, NSError *error) {
     
    }];
    
    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 2;
    colorPicker.title = NSLocalizedString(@"BG Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
    
}

- (void)setSelectedColor:(UIColor*)color tag:(int)tag {
    
    NSString *hex = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)];
    NSString *trigger;
    if (tag == 1) {
        trigger = [NSString stringWithFormat:@"zss_editor.setTextColor(\"%@\");", hex];
    } else if (tag == 2) {
        trigger = [NSString stringWithFormat:@"zss_editor.setBackgroundColor(\"%@\");", hex];
    }
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)undo:(ZSSBarButtonItem *)barButtonItem {
    [self.editorView evaluateJavaScript:@"zss_editor.undo();" completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)redo:(ZSSBarButtonItem *)barButtonItem {
    [self.editorView evaluateJavaScript:@"zss_editor.redo();" completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)insertLink {
    
    // Save the selection location
    [self.editorView evaluateJavaScript:@"zss_editor.prepareInsert();" completionHandler:^(NSString *result, NSError *error) {
     
    }];

    // Show the dialog for inserting or editing a link
    [self showInsertLinkDialogWithLink:self.selectedLinkURL title:self.selectedLinkTitle];
    
}


- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title {
    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedLinkURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png" inBundle:[NSBundle bundleForClass:[ZSSRichTextEditor class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertURLAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Title", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (title) {
                textField.text = title;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *linkURL = [alertController.textFields objectAtIndex:0];
            UITextField *title = [alertController.textFields objectAtIndex:1];
            if (!self.selectedLinkURL) {
                [self insertLink:linkURL.text title:title.text];
                //NSLog(@"insert link");
            } else {
                [self updateLink:linkURL.text title:title.text];
            }
            [self focusTextEditor];
        }]];
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 2;
        UITextField *linkURL = [self.alertView textFieldAtIndex:0];
        linkURL.placeholder = NSLocalizedString(@"URL (required)", nil);
        if (url) {
            linkURL.text = url;
        }
        
        linkURL.rightView = am;
        linkURL.rightViewMode = UITextFieldViewModeAlways;
        
        UITextField *alt = [self.alertView textFieldAtIndex:1];
        alt.secureTextEntry = NO;
        alt.placeholder = NSLocalizedString(@"Title", nil);
        if (title) {
            alt.text = title;
        }
        
        [self.alertView show];
    }
    
}

- (void)insertLink:(NSString *)url title:(NSString *)title {
    
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertLink(\"%@\", \"%@\");", url, title];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
    
    if (_receiveEditorDidChangeEvents) {
        [self updateEditor];
    }
}


- (void)updateLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
    
    if (_receiveEditorDidChangeEvents) {
        [self updateEditor];
    }
}


- (void)dismissAlertView {
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
}

- (void)addCustomToolbarItemWithButton:(UIButton *)button {
    
    if(self.customBarButtonItems == nil)
    {
        self.customBarButtonItems = [NSMutableArray array];
    }
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28.5f];
    [button setTitleColor:[self barButtonItemDefaultColor] forState:UIControlStateNormal];
    [button setTitleColor:[self barButtonItemSelectedDefaultColor] forState:UIControlStateHighlighted];
    
    ZSSBarButtonItem *barButtonItem = [[ZSSBarButtonItem alloc] initWithCustomView:button];
    
    [self.customBarButtonItems addObject:barButtonItem];
    
    [self buildToolbar];
}

- (void)addCustomToolbarItem:(ZSSBarButtonItem *)item {
    
    if(self.customZSSBarButtonItems == nil)
    {
        self.customZSSBarButtonItems = [NSMutableArray array];
    }
    [self.customZSSBarButtonItems addObject:item];
    
    [self buildToolbar];
}


- (void)removeLink {
    [self.editorView evaluateJavaScript:@"zss_editor.unlink();" completionHandler:^(NSString *result, NSError *error) {
     
    }];
    
    if (_receiveEditorDidChangeEvents) {
        [self updateEditor];
    }
}

- (void)quickLink {
    [self.editorView evaluateJavaScript:@"zss_editor.quickLink();" completionHandler:^(NSString *result, NSError *error) {
     
    }];
    
    if (_receiveEditorDidChangeEvents) {
        [self updateEditor];
    }
}

- (void)insertImage {
    
    // Save the selection location
    [self.editorView evaluateJavaScript:@"zss_editor.prepareInsert();" completionHandler:^(NSString *result, NSError *error) {
     
    }];

    [self showInsertImageDialogWithLink:self.selectedImageURL alt:self.selectedImageAlt];
    
}

- (void)insertImageFromDevice {
    
    // Save the selection location
    [self.editorView evaluateJavaScript:@"zss_editor.prepareInsert();" completionHandler:^(NSString *result, NSError *error) {
     
    }];

    [self showInsertImageDialogFromDeviceWithScale:self.selectedImageScale alt:self.selectedImageAlt];
    
}

- (void)showInsertImageDialogWithLink:(NSString *)url alt:(NSString *)alt {
    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedImageURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png" inBundle:[NSBundle bundleForClass:[ZSSRichTextEditor class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertImageAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Alt", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (alt) {
                textField.text = alt;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *imageURL = [alertController.textFields objectAtIndex:0];
            UITextField *alt = [alertController.textFields objectAtIndex:1];
            if (!self.selectedImageURL) {
                [self insertImage:imageURL.text alt:alt.text];
            } else {
                [self updateImage:imageURL.text alt:alt.text];
            }
            [self focusTextEditor];
        }]];
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 1;
        UITextField *imageURL = [self.alertView textFieldAtIndex:0];
        imageURL.placeholder = NSLocalizedString(@"URL (required)", nil);
        if (url) {
            imageURL.text = url;
        }
        
        imageURL.rightView = am;
        imageURL.rightViewMode = UITextFieldViewModeAlways;
        imageURL.clearButtonMode = UITextFieldViewModeAlways;
        
        UITextField *alt1 = [self.alertView textFieldAtIndex:1];
        alt1.secureTextEntry = NO;
        alt1.placeholder = NSLocalizedString(@"Alt", nil);
        alt1.clearButtonMode = UITextFieldViewModeAlways;
        if (alt) {
            alt1.text = alt;
        }
        
        [self.alertView show];
    }
    
}

- (void)showInsertImageDialogFromDeviceWithScale:(CGFloat)scale alt:(NSString *)alt {
    
    // Insert button title
    NSString *insertButtonTitle = !self.selectedImageURL ? NSLocalizedString(@"Pick Image", nil) : NSLocalizedString(@"Pick New Image", nil);
    
    //If the OS version supports the new UIAlertController go for it. Otherwise use the old UIAlertView
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Image From Device", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        //Add alt text field
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Alt", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (alt) {
                textField.text = alt;
            }
        }];
        
        //Add scale text field
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            textField.placeholder = NSLocalizedString(@"Image scale, 0.5 by default", nil);
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        }];
        
        //Cancel action
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        
        //Insert action
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *textFieldAlt = [alertController.textFields objectAtIndex:0];
            UITextField *textFieldScale = [alertController.textFields objectAtIndex:1];
            
            self.selectedImageScale = [textFieldScale.text floatValue]?:kDefaultScale;
            self.selectedImageAlt = textFieldAlt.text?:@"";
            
            [self presentViewController:self.imagePicker animated:YES completion:nil];
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 3;
        
        UITextField *textFieldAlt = [self.alertView textFieldAtIndex:0];
        textFieldAlt.secureTextEntry = NO;
        textFieldAlt.placeholder = NSLocalizedString(@"Alt", nil);
        textFieldAlt.clearButtonMode = UITextFieldViewModeAlways;
        if (alt) {
            textFieldAlt.text = alt;
        }
        
        UITextField *textFieldScale = [self.alertView textFieldAtIndex:1];
        textFieldScale.placeholder = NSLocalizedString(@"Image scale, 0.5 by default", nil);
        textFieldScale.keyboardType = UIKeyboardTypeDecimalPad;
        
        [self.alertView show];
    }
    
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImage(\"%@\", \"%@\");", url, alt];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}


- (void)updateImage:(NSString *)url alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateImage(\"%@\", \"%@\");", url, alt];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)insertImageBase64String:(NSString *)imageBase64String alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImageBase64String(\"%@\", \"%@\");", imageBase64String, alt];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)updateImageBase64String:(NSString *)imageBase64String alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateImageBase64String(\"%@\", \"%@\");", imageBase64String, alt];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
     
    }];
}


- (void)updateToolBarWithButtonName:(NSString *)name {
    
    // Items that are enabled
    NSArray *itemNames = [name componentsSeparatedByString:@","];
    
    // Special case for link
    NSMutableArray *itemsModified = [[NSMutableArray alloc] init];
    for (NSString *linkItem in itemNames) {
        NSString *updatedItem = linkItem;
        if ([linkItem hasPrefix:@"link:"]) {
            updatedItem = @"link";
            self.selectedLinkURL = [linkItem stringByReplacingOccurrencesOfString:@"link:" withString:@""];
        } else if ([linkItem hasPrefix:@"link-title:"]) {
            self.selectedLinkTitle = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"link-title:" withString:@""]];
        } else if ([linkItem hasPrefix:@"image:"]) {
            updatedItem = @"image";
            self.selectedImageURL = [linkItem stringByReplacingOccurrencesOfString:@"image:" withString:@""];
        } else if ([linkItem hasPrefix:@"image-alt:"]) {
            self.selectedImageAlt = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"image-alt:" withString:@""]];
        } else {
            self.selectedImageURL = nil;
            self.selectedImageAlt = nil;
            self.selectedLinkURL = nil;
            self.selectedLinkTitle = nil;
        }
        [itemsModified addObject:updatedItem];
    }
    itemNames = [NSArray arrayWithArray:itemsModified];
    
    self.editorItemsEnabled = itemNames;
    
    // Highlight items
    NSArray *items = self.toolbar.items;
    for (ZSSBarButtonItem *item in items) {
        if ([itemNames containsObject:item.label]) {
            printf("%s", item.label);
            item.tintColor = [self barButtonItemSelectedDefaultColor];
        } else {
            item.tintColor = [self barButtonItemDefaultColor];
        }
    }
    
}


#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
    
}


#pragma mark - WKScriptMessageHandler Delegate

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *messageString = (NSString *)message.body;
    NSLog(@"Message received: %@", messageString);
    
    /*
     
     Callback for when text is changed, written by @madebydouglas derived from richardortiz84 https://github.com/nnhubbard/ZSSRichTextEditor/issues/5
     
     */
    
    if ([messageString isEqualToString:@"paste"]) {
        self.editorPaste = YES;
    }
    
    if ([messageString isEqualToString:@"input"]) {
        
        if (_receiveEditorDidChangeEvents) {
            [self updateEditor];
        }
        
        [self getText:^(NSString * result, NSError * _Nullable error) {
            [self checkForMentionOrHashtagInText:result];
        }];
        
        if (self.editorPaste) {
            [self blurTextEditor];
            self.editorPaste = NO;
        }
    }
}

#pragma mark - WKNavigationDelegate Delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
       
    
    NSString *query = [navigationAction.request.URL query];
    
    NSString *urlString = [navigationAction.request.URL absoluteString];

    decisionHandler(WKNavigationActionPolicyAllow);

    NSLog(@"web request");
    NSLog(@"%@", urlString);
    NSLog(@"%@", query);

    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {

        //On the old UIWebView delegate it returned false Bool here
        //TODO: what should we do now?
        
    } else if ([urlString rangeOfString:@"callback://0/"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        [self updateToolBarWithButtonName:className];
        
    } else if ([urlString rangeOfString:@"debug://"].location != NSNotFound) {
        
        NSLog(@"Debug Found");
        
        // We recieved the callback
        NSString *debug = [urlString stringByReplacingOccurrencesOfString:@"debug://" withString:@""];
        debug = [debug stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"%@", debug);
        
    } else if ([urlString rangeOfString:@"scroll://"].location != NSNotFound) {
        
        NSInteger position = [[urlString stringByReplacingOccurrencesOfString:@"scroll://" withString:@""] integerValue];
        [self editorDidScrollWithPosition:position];
        
    }
        
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.editorLoaded = YES;
    
    if (!self.internalHTML) {
        self.internalHTML = @"";
    }
    [self updateHTML];
    
    if(self.placeholder) {
        [self setPlaceholderText];
    }
    
    if (self.customCSS) {
        [self updateCSS];
    }
    
    if (self.shouldShowKeyboard) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self focusTextEditor];
        });
    }
    
    /*
     
     Create listeners for when text is changed, solution by @madebydouglas derived from richardortiz84 https://github.com/nnhubbard/ZSSRichTextEditor/issues/5
     
     */
    
    NSString *inputListener = @"document.getElementById('zss_editor_content').addEventListener('input', function() {window.webkit.messageHandlers.jsm.postMessage('input');});";
    NSString *pasteListener = @"document.getElementById('zss_editor_content').addEventListener('paste', function() {window.webkit.messageHandlers.jsm.postMessage('paste');});";
    
    [self.editorView evaluateJavaScript:inputListener completionHandler:^(NSString *result, NSError *error) {
        if (error != NULL) {
            NSLog(@"%@", error);
        }
    }];
    
    [self.editorView evaluateJavaScript:pasteListener completionHandler:^(NSString *result, NSError *error) {
        if (error != NULL) {
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark - Mention & Hashtag Support Section

- (void)checkForMentionOrHashtagInText:(NSString *)text {
    
    if ([text containsString:@" "] && [text length] > 0) {
        
        NSString *lastWord = nil;
        NSString *matchedWord = nil;
        BOOL ContainsHashtag = NO;
        BOOL ContainsMention = NO;
        
        NSRange range = [text rangeOfString:@" " options:NSBackwardsSearch];
        lastWord = [text substringFromIndex:range.location];
        
        if (lastWord != nil) {
            
            //Check if last word typed starts with a #
            NSRegularExpression *hashtagRegex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:nil];
            NSArray *hashtagMatches = [hashtagRegex matchesInString:lastWord options:0 range:NSMakeRange(0, lastWord.length)];
            
            for (NSTextCheckingResult *match in hashtagMatches) {
                
                NSRange wordRange = [match rangeAtIndex:1];
                NSString *word = [lastWord substringWithRange:wordRange];
                matchedWord = word;
                ContainsHashtag = YES;
                
            }
            
            if (!ContainsHashtag) {
                
                //Check if last word typed starts with a @
                NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:nil];
                NSArray *mentionMatches = [mentionRegex matchesInString:lastWord options:0 range:NSMakeRange(0, lastWord.length)];
                
                for (NSTextCheckingResult *match in mentionMatches) {
                    
                    NSRange wordRange = [match rangeAtIndex:1];
                    NSString *word = [lastWord substringWithRange:wordRange];
                    matchedWord = word;
                    ContainsMention = YES;
                    
                }
                
            }
            
        }
        
        if (ContainsHashtag) {
            
            [self hashtagRecognizedWithWord:matchedWord];
            
        }
        
        if (ContainsMention) {
            
            [self mentionRecognizedWithWord:matchedWord];
            
        }
        
    }
    
}

#pragma mark - Callbacks

//Blank implementation
- (void)editorDidScrollWithPosition:(NSInteger)position {}

//Blank implementation
- (void)editorDidChangeWithText:(NSString *)text andHTML:(NSString *)html  {}

//Blank implementation
- (void)hashtagRecognizedWithWord:(NSString *)word {}

//Blank implementation
- (void)mentionRecognizedWithWord:(NSString *)word {}


#pragma mark - AlertView

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    if (alertView.tag == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        UITextField *textField2 = [alertView textFieldAtIndex:1];
        if ([textField.text length] == 0 || [textField2.text length] == 0) {
            return NO;
        }
    } else if (alertView.tag == 2) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            UITextField *imageURL = [alertView textFieldAtIndex:0];
            UITextField *alt = [alertView textFieldAtIndex:1];
            if (!self.selectedImageURL) {
                [self insertImage:imageURL.text alt:alt.text];
            } else {
                [self updateImage:imageURL.text alt:alt.text];
            }
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            UITextField *linkURL = [alertView textFieldAtIndex:0];
            UITextField *title = [alertView textFieldAtIndex:1];
            if (!self.selectedLinkURL) {
                [self insertLink:linkURL.text title:title.text];
            } else {
                [self updateLink:linkURL.text title:title.text];
            }
        }
    } else if (alertView.tag == 3) {
        if (buttonIndex == 1) {
            UITextField *textFieldAlt = [alertView textFieldAtIndex:0];
            UITextField *textFieldScale = [alertView textFieldAtIndex:1];
            
            self.selectedImageScale = [textFieldScale.text floatValue]?:kDefaultScale;
            self.selectedImageAlt = textFieldAlt.text?:@"";
            
            [self presentViewController:self.imagePicker animated:YES completion:nil];
            
        }
    }
}


#pragma mark - Asset Picker

- (void)showInsertURLAlternatePicker {
    // Blank method. User should implement this in their subclass
}


- (void)showInsertImageAlternatePicker {
    // Blank method. User should implement this in their subclass
}

#pragma mark - Image Picker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //Dismiss the Image Picker
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info{
    
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage]?:info[UIImagePickerControllerOriginalImage];
    
    //Scale the image
    CGSize targetSize = CGSizeMake(selectedImage.size.width * self.selectedImageScale, selectedImage.size.height * self.selectedImageScale);
    UIGraphicsBeginImageContext(targetSize);
    [selectedImage drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Compress the image, as it is going to be encoded rather than linked
    NSData *scaledImageData = UIImageJPEGRepresentation(scaledImage, kJPEGCompression);
    
    //Encode the image data as a base64 string
    NSString *imageBase64String = [scaledImageData base64EncodedStringWithOptions:0];
    
    //Decide if we have to insert or update
    if (!self.imageBase64String) {
        [self insertImageBase64String:imageBase64String alt:self.selectedImageAlt];
    } else {
        [self updateImageBase64String:imageBase64String alt:self.selectedImageAlt];
    }
    
    self.imageBase64String = imageBase64String;
    
    //Dismiss the Image Picker
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Keyboard status

- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    // User Info
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // Toolbar Sizes
    CGFloat sizeOfToolbar = self.toolbarHolder.frame.size.height;
    
    // Keyboard Size
    CGFloat keyboardHeight = keyboardEnd.size.height;
    
    // Correct Curve
    UIViewAnimationOptions animationOptions = curve << 16;
    
    const int extraHeight = 10;
    
    if (keyboardEnd.origin.y < [[UIScreen mainScreen] bounds].size.height) {
        
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            
            // Toolbar
            CGRect toolbarFrame = self.toolbarHolder.frame;
            CGRect kbRect = [self.toolbarHolder.superview convertRect:keyboardEnd fromView:nil];
            toolbarFrame.origin.y = kbRect.origin.y - sizeOfToolbar;
            self.toolbarHolder.frame = toolbarFrame;
            
            // Editor View
            CGRect editorFrame = self.editorView.frame;
            editorFrame.size.height = toolbarFrame.origin.y - extraHeight;
            self.editorView.frame = editorFrame;
            self.editorViewFrame = self.editorView.frame;
            self.editorView.scrollView.contentInset = UIEdgeInsetsZero;
            self.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
            // Source View
            CGRect sourceFrame = self.sourceView.frame;
            sourceFrame.size.height = (self.view.frame.size.height - keyboardHeight) - sizeOfToolbar - extraHeight;
            self.sourceView.frame = sourceFrame;
            
            // Provide editor with keyboard height and editor view height
            [self setFooterHeight:(keyboardHeight - 8)];
            [self setContentHeight: self.editorViewFrame.size.height];
            
        } completion:nil];
        
    } else {
        
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            
            CGRect frame = self.toolbarHolder.frame;
            
            if (self->_alwaysShowToolbar) {
                CGFloat bottomSafeAreaInset = 0.0;
                if (@available(iOS 11.0, *)) {
                    bottomSafeAreaInset = self.view.safeAreaInsets.bottom;
                }
                frame.origin.y = self.view.frame.size.height - sizeOfToolbar - bottomSafeAreaInset;
            } else {
                frame.origin.y = self.view.frame.size.height + keyboardHeight;
            }
            
            self.toolbarHolder.frame = frame;
            
            // Editor View
            CGRect editorFrame = self.editorView.frame;
            
            if (self->_alwaysShowToolbar) {
                editorFrame.size.height = ((self.view.frame.size.height - sizeOfToolbar) - extraHeight);
            } else {
                editorFrame.size.height = self.view.frame.size.height;
            }
            
            self.editorView.frame = editorFrame;
            self.editorViewFrame = self.editorView.frame;
            self.editorView.scrollView.contentInset = UIEdgeInsetsZero;
            self.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
            // Source View
            CGRect sourceFrame = self.sourceView.frame;
            
            if (self->_alwaysShowToolbar) {
                sourceFrame.size.height = ((self.view.frame.size.height - sizeOfToolbar) - extraHeight);
            } else {
                sourceFrame.size.height = self.view.frame.size.height;
            }
            
            self.sourceView.frame = sourceFrame;
            
            [self setFooterHeight:0];
            [self setContentHeight:self.editorViewFrame.size.height];
            
        } completion:nil];
        
    }
    
}


#pragma mark - Utilities

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}


- (void)tidyHTML:(NSString *)html completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
                
        html = [NSString stringWithFormat:@"style_html(\"%@\");", html];
        [self.editorView evaluateJavaScript:html completionHandler:^(NSString *result, NSError *error) {
            
            if (error != NULL) {
                NSLog(@"HTML Tidying Error: %@", error);
            }
            
            NSLog(@"%@", result);
            
            completionHandler(result, error);
        }];
        
    } else {
        completionHandler(html, NULL);
    }
}


- (UIColor *)barButtonItemDefaultColor {
    
    if (self.toolbarItemTintColor) {
        return self.toolbarItemTintColor;
    }
    
    return [UIColor blackColor];
}


- (UIColor *)barButtonItemSelectedDefaultColor {
    
    if (self.toolbarItemSelectedTintColor) {
        return self.toolbarItemSelectedTintColor;
    }
    
    return [UIColor blackColor];
}


- (BOOL)isIpad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}


- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (void)enableToolbarItems:(BOOL)enable {
    NSArray *items = self.toolbar.items;
    for (ZSSBarButtonItem *item in items) {
        if (![item.label isEqualToString:@"source"]) {
            item.enabled = enable;
        }
    }
}

#pragma mark - Memory Warning Section
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
