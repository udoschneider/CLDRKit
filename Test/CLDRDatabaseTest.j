@import <Foundation/Foundation.j>
@import "../CLDRKit.j"

@implementation CLDRDatabaseTest : OJTestCase
{
    CLDRDatabase sharedDatabase;
}

- (void)setUp
{
    [CLDRDatabase reset];
    sharedDatabase = [CLDRDatabase sharedDatabase];
}

- (void)testSharedInstance
{
    [self assertNoThrow:(function(){
        [CLDRDatabase sharedDatabase];
    })];
    [self assert:[CLDRDatabase sharedDatabase] same:[CLDRDatabase sharedDatabase]];
    [self assert:sharedDatabase notSame:[[CLDRDatabase alloc] init]];
}

- (void)testAvailableLocaleIdentifiers
{
     // At least one locale should always be present
    [self assertTrue:[[sharedDatabase availableLocaleIdentifiers] count] > 0];
    [self assertFalse:[[sharedDatabase availableLocaleIdentifiers] containsObject:@"root"]];
}

- (void)testLoadLanguage
{
    [self assertNoThrow:(function() {
        [sharedDatabase _loadLanguage:@"aa"];
    })]
}

- (void)testLoadRoot
{
    var root;
    [self assertNoThrow:(function() {
        root = [sharedDatabase _loadRoot];
    })]
    [self assertTrue:[[root class] isSubclassOfClass:[CPDictionary class]]];
    [self assertNotNull:[root objectForKey:@"main"]];
    [self assertNotNull:[root objectForKey:@"availableLocales"]];
    [self assertNotNull:[root objectForKey:@"rootLocales"]];
}

- (void)testLoadNonExistentLanguage
{
    [self assertThrows:(function (){
        [sharedDatabase _loadLanguage:@"NONEXISTENT"];
    })];
}

- (void)testLoadAdditialLanguage
{
    [self assertFalse:[[sharedDatabase loadedLocaleIdentifiers] containsObject:@"it"]];
    [sharedDatabase _mergeLanguage:@"it"];
    [self assertTrue:[[sharedDatabase loadedLocaleIdentifiers] containsObject:@"it"]];
}

- (void)testLoadedLocaleIdentifiers
{
    [self assertTrue:[[sharedDatabase loadedLocaleIdentifiers] count] > 0];
    [self assertTrue:[[CPSet setWithArray:[sharedDatabase loadedLocaleIdentifiers]] isSubsetOfSet: [CPSet setWithArray:[sharedDatabase rootLocaleIdentifiers]]]];
}

- (void)testGetMergedLocale
{
    var locale;
    [self assertNoThrow:(function (){
        locale = [sharedDatabase mergedLocale:@"de-AT"];
    })];
    // print("######" + [locale description]);
    [self assert:@"Andorranische Pesete" equals:[locale valueForKeyPath:@"numbers.currencies.ADP.displayName"]]; // This should be inherited from de
    [self assert:@"Jänner" equals:[locale valueForKeyPath:@"dates.calendars.gregorian.months.format.wide.1"]]; // This is specific to de-AT

    // main["de-AT"].dates.calendars.gregorian.months.format.wide[1] = Jänner

    // main["de-AT"].numbers.currencies.ADP.displayName "Andorranische Pesete"
}

@end

