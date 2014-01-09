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

- (void)testDisplayNameForKeyValue
{
	var frLocale = [[CPLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
	[self assert:@"français" equals: [frLocale displayNameForKey:CPLocaleLanguageCode value:@"fr_FR"]];
	[self assert:@"anglais" equals: [frLocale displayNameForKey:CPLocaleLanguageCode value:@"en_US"]]

	[self assert:@"France" equals: [frLocale displayNameForKey:CPLocaleCountryCode value:@"fr_FR"]];
	[self assert:@"États-Unis" equals: [frLocale displayNameForKey:CPLocaleCountryCode value:@"en_US"]]

	[self assert:@"français (France)" equals: [frLocale displayNameForKey:CPLocaleIdentifier value:@"fr_FR"]];
	[self assert:@"anglais (États-Unis)" equals: [frLocale displayNameForKey:CPLocaleIdentifier value:@"en_US"]]
}

- (void)testAvailableLocaleIdentifiers
{
	[self assert:[CPLocale availableLocaleIdentifiers] equals:[[CLDRDatabase sharedDatabase] availableLocaleIdentifiers]];
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
	[self assert:[CPCharacterSet characterSetWithCharactersInString:@"aàbcdeéèfghiìjklmnoóòpqrstuùvwxyz"] equals:[locale objectForKey:CPLocaleExemplarCharacterSet]];
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
	//[self assert:@"€" equals:[germanLocale objectForKey:CPLocaleCurrencySymbol]];
	//[self assert:@"$" equals:[usLocale objectForKey:CPLocaleCurrencySymbol]];
}

- (void)testCPLocaleCurrencyCode
{
	//[self assert:@"EUR" equals:[germanLocale objectForKey:CPLocaleCurrencyCode]];
	//[self assert:@"USD" equals:[usLocale objectForKey:CPLocaleCurrencyCode]];
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

- (void)testCPLocaleAlternateQuotationBeginDelimiterKey
{
	[self assert:@"‚" equals:[germanLocale objectForKey:CPLocaleAlternateQuotationBeginDelimiterKey]];
	[self assert:@"‘" equals:[usLocale objectForKey:CPLocaleAlternateQuotationBeginDelimiterKey]];
}

- (void)testCPLocaleAlternateQuotationEndDelimiterKey
{
	[self assert:@"‘" equals:[germanLocale objectForKey:CPLocaleAlternateQuotationEndDelimiterKey]];
	[self assert:@"’" equals:[usLocale objectForKey:CPLocaleAlternateQuotationEndDelimiterKey]];
}

@end
