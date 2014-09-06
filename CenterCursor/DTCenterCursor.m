#import "DTCenterCursor.h"

#import "DTXcodeHeaders.h"
#import "DTXcodeUtils.h"

static DTCenterCursor *sharedPlugin;

@interface DTCenterCursor()

@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation DTCenterCursor

+ (void)pluginDidLoad:(NSBundle *)plugin {
  static dispatch_once_t onceToken;
  NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
  if ([currentApplicationName isEqual:@"Xcode"]) {
    dispatch_once(&onceToken, ^{ sharedPlugin = [[self alloc] initWithBundle:plugin]; });
  }
}

- (id)initWithBundle:(NSBundle *)plugin {
  if (self = [super init]) {
    self.bundle = plugin;
    NSMenuItem *menuItem = [DTXcodeUtils getMainMenuItemWithTitle:@"Edit"];
    if (menuItem) {
      [[menuItem submenu] addItem:[NSMenuItem separatorItem]];

      [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
      NSMenuItem *centerCursorItem = [[NSMenuItem alloc] initWithTitle:@"Center Cursor"
                                                                action:@selector(centerCursor)
                                                         keyEquivalent:@""];
      [centerCursorItem setTarget:self];
      [[menuItem submenu] addItem:centerCursorItem];
    }
  }
  return self;
}

- (void)centerCursor {
  NSScrollView *scrollView = [DTXcodeUtils currentScrollView];
  NSPoint center = [scrollView contentView].bounds.origin;
  center.y += [scrollView contentView].bounds.size.height / 2;
  NSUInteger centerIndex = [[scrollView documentView] characterIndexForInsertionAtPoint:center];
  DVTSourceTextView *textView = [DTXcodeUtils currentSourceTextView];
  [textView setSelectedRange:NSMakeRange(centerIndex, 0)];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end