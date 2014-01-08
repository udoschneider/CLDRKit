/*
 * CPLocaleTest.j
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

@import <Foundation/CPLocale.j>
@import "../CLDRKit.j"

@implementation CPLocaleTest : OJTestCase

- (void)__DisplayNameForKeyValue
{
	var frLocale = [[CPLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
	[self assert:[frLocale displayNameForKey:CPLocaleIdentifier value:@"fr_FR"] equals:@"français (France)"];
	[self assert:[frLocale displayNameForKey:CPLocaleIdentifier value:@"en_US"] equals:@"anglais (États-Unis)"]
}

- (void)testAvailableLocaleIdentifiers
{
	[self assert:[CPLocale availableLocaleIdentifiers] equals:([[CLDRDatabase sharedDatabase] availableLocaleIdentifiers]).map(function (each){return each.replace("-", "_")})];
}

- (void)testISOLanguageCodes
{
	[self assert:[CPLocale ISOLanguageCodes] equals:[[CLDRDatabase sharedDatabase] languageCodes]];
}

- (void)testISOCountryCodes
{
	[self assert:[CPLocale ISOCountryCodes] equals:[[CLDRDatabase sharedDatabase] countryCodes]];
}

- (void)testComponentsFromLocaleIdentifier
{
	var components = [CPLocale componentsFromLocaleIdentifier:@"de_AT"];
	[self assert:@{CPLocaleIdentifier:@"de_AT", CPLocaleLanguageCode:@"de", CPLocaleCountryCode:@"AT"} equals:components];

	[self assertThrows:(function (){
		[CPLocale componentsFromLocaleIdentifier:@""];
	})];
}

- (void)testCPLocaleIdentifier
{
	var locale = [CPLocale localeWithLocaleIdentifier:@"de_DE"];
	[self assert:@"de_DE" equals:[locale objectForKey:CPLocaleIdentifier]];
}

- (void)testCPLocaleLanguageCode
{
	var locale = [CPLocale localeWithLocaleIdentifier:@"de_DE"];
	[self assert:@"de" equals:[locale objectForKey:CPLocaleLanguageCode]];
}

- (void)testCPLocaleCountryCode
{
	var locale = [CPLocale localeWithLocaleIdentifier:@"de_DE"];
	[self assert:@"DE" equals:[locale objectForKey:CPLocaleCountryCode]];
}

- (void)testCPLocaleScriptCode
{
	var locale = [CPLocale localeWithLocaleIdentifier:@"es_Dsrt_ES_PREEURO"];
	[self assert:@"Dsrt" equals:[locale objectForKey:CPLocaleScriptCode]];
}

- (void)testCPLocaleVariantCode
{
	var locale  = [CPLocale localeWithLocaleIdentifier:@"es_Dsrt_ES_PREEURO"];
	[self assert:@"PREEURO" equals:[locale objectForKey:CPLocaleVariantCode]];
}

- (void)testCPLocaleExemplarCharacterSet
{
	var locale = [CPLocale localeWithLocaleIdentifier:@"it"];
	// Not sure if brackets and space are part of the character set
	[self assert:[CPCharacterSet characterSetWithCharactersInString:@"[a à b c d e é è f g h i ì j k l m n o ó ò p q r s t u ù v w x y z]"] equals:[locale objectForKey:CPLocaleExemplarCharacterSet]];
}

- (void)testCPLocaleCalendar
{
	// TODO: CPLocaleCalendar - unsure how to find the "default" calendar for a given locale
}

- (void)testCPLocaleCollationIdentifier
{
	// TODO: CPLocaleCollationIdentifier
}


- (void)testCPLocaleUsesMetricSystem
{
	var locale  = [CPLocale localeWithLocaleIdentifier:@"de_DE"];
	[self assertTrue:[locale objectForKey:CPLocaleUsesMetricSystem]];

	locale  = [CPLocale localeWithLocaleIdentifier:@"en_US"];
	[self assertFalse:[locale objectForKey:CPLocaleUsesMetricSystem]];
}

@end
