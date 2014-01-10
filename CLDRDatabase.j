/*
 * CLDRDatabase.j
 * CLDRKit
 *
 * Created by Udo Schneider on January 1, 2014.
 *
 * Copyright 2014, Krodelin Software Solutions. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/Foundation.j>
@import "CPDictionary+DeepMerge.j"

var SharedDatabase;

@implementation CLDRDatabase : CPObject
{
	CPDictionary _cldrData;
}

// Return the shared instances
+ (CLDRDatabase)sharedDatabase
{
	if (!SharedDatabase)
		SharedDatabase = [[self alloc] init];
	return SharedDatabase
}

+ (void)reset
{
	SharedDatabase = nil;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		_cldrData = [self _loadInitial];
	}
	return self;
}

// Load all locales for a specific language
- (CPDictionary)_loadLanguage:(CPString)languageIdentifier
{
	if (_cldrData && ![[self availableLocaleIdentifiers] containsObject:languageIdentifier] && languageIdentifier != @"initial")
		[CPException raise:@"UnknownLanguage" format:@"CLDRKit does not contain the language \"%@\"",languageIdentifier];
	var url = [[CLDRKit bundle] pathForResource:[CPString stringWithFormat:"locales/%@.plist",languageIdentifier]],
		data = [CPURLConnection sendSynchronousRequest:[CPURLRequest requestWithURL:url] returningResponse:nil];
	return [data plistObject];
}

// Load the initial root (pre-merged) locale
- (CPDictionary)_loadInitial
{
	return [self _loadLanguage:@"initial"];
}


- (void)_mergeLanguage:(CPString)languageIdentifier
{
	var languageData = [self _loadLanguage: languageIdentifier];
	[[[languageData objectForKey:@"locales"] allKeys] enumerateObjectsUsingBlock:(function (localeIdentifier){
		[[_cldrData objectForKey:@"locales"] setObject:[[languageData objectForKey:@"locales"] objectForKey:localeIdentifier] forKey:localeIdentifier];
	})];
}

// Locales currently loaded - this list may grow over time!
- (CPArray)loadedLocaleIdentifiers
{
	return [[_cldrData valueForKeyPath:@"locales"] allKeys];
}

// Return an array of available locale identifiers. This includes all the root/pre-merged as well as possibly on-demand loaded locales
- (CPArray)availableLocaleIdentifiers
{
	return [_cldrData valueForKeyPath:@"available"];
}

- (CPArray)countries
{
	return [_cldrData valueForKey:@"countries"];
}

- (CPArray)countryCodes
{

	return [[self countries] allKeys];
}

- (CPArray)languageCodes
{
	return [_cldrData valueForKey:@"languages"];
}

- (CPDictionary)mergedLocaleWithIdentifier:(CPString)localeIdentifier
{
	if (![[_cldrData objectForKey:@"main"] containsKey:localeIdentifier])
	{
		var language = localeIdentifier.split(/[-_]/)[0];
		[self _mergeLanguage:language];
	}

	var merged = [[_cldrData objectForKey:@"locales"] objectForKey:@"root"],
		partialIdentifier = @"";
	[(localeIdentifier.split(/[-_]/)) enumerateObjectsUsingBlock:(function (localeIdentifierPart){
		if ([partialIdentifier isEqualToString:@""])
			partialIdentifier = localeIdentifierPart;
		else
			partialIdentifier = [partialIdentifier stringByAppendingFormat:@"_%@",localeIdentifierPart];

		merged = [merged dictionaryByDeepMergingObjectsFromDictionary:[[_cldrData objectForKey:@"locales"] objectForKey:partialIdentifier]];
	})];
	return merged;
}

@end
