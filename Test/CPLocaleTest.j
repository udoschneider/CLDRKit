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
{
	CPLocale	germanLocale;
	CPLocale	usLocale;
}

- (void)setUp
{
	germanLocale = [CPLocale localeWithLocaleIdentifier:@"de_DE"];
	usLocale = [CPLocale localeWithLocaleIdentifier:@"en_US"];
}

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
	[self assert:@"de_DE" equals:[germanLocale objectForKey:CPLocaleIdentifier]];
}

- (void)testCPLocaleLanguageCode
{
	[self assert:@"de" equals:[germanLocale objectForKey:CPLocaleLanguageCode]];
}

- (void)testCPLocaleCountryCode
{
	[self assert:@"DE" equals:[germanLocale objectForKey:CPLocaleCountryCode]];
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
	[self assertTrue:[germanLocale objectForKey:CPLocaleUsesMetricSystem]];
	[self assertFalse:[usLocale objectForKey:CPLocaleUsesMetricSystem]];
}

- (void)testCPLocaleMeasurementSystem
{
	[self assert:@"Metric" equals:[germanLocale objectForKey:CPLocaleMeasurementSystem]];
	[self assert:@"U.S." equals:[usLocale objectForKey:CPLocaleMeasurementSystem]];
}

- (void)testCPLocaleDecimalSeparator
{
	[self assert:@"," equals:[germanLocale objectForKey:CPLocaleDecimalSeparator]];
	[self assert:@"." equals:[usLocale objectForKey:CPLocaleDecimalSeparator]];
}

- (void)testCPLocaleGroupingSeparator
{
	[self assert:@"." equals:[germanLocale objectForKey:CPLocaleGroupingSeparator]];
	[self assert:@"," equals:[usLocale objectForKey:CPLocaleGroupingSeparator]];
}

- (void)testCPLocaleCurrencySymbol
{
	// TODO: CPLocaleCurrencySymbol
}

- (void)testCPLocaleCurrencyCode
{
	// TODO: CPLocaleCurrencyCode
}

- (void)testCPLocaleCollatorIdentifier
{
	// TODO: CPLocaleCollatorIdentifier
}

- (void)testCPLocaleQuotationBeginDelimiterKey
{
	[self assert:@"„" equals:[germanLocale objectForKey:CPLocaleQuotationBeginDelimiterKey]];
	[self assert:@"“" equals:[usLocale objectForKey:CPLocaleQuotationBeginDelimiterKey]];
}

- (void)testCPLocaleQuotationEndDelimiterKey
{
	[self assert:@"“" equals:[germanLocale objectForKey:CPLocaleQuotationEndDelimiterKey]];
	[self assert:@"”" equals:[usLocale objectForKey:CPLocaleQuotationEndDelimiterKey]];
}

@end
