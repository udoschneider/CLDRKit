/*
 * CPLocale+CLDRKit.j
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

@implementation CPLocale (CLDRKit)

+ (id)localeWithLocaleIdentifier:(CPString)string
{
	return [[CPLocale alloc] initWithLocaleIdentifier:string];
}

+ (CPArray)availableLocaleIdentifiers
{
	return [[CLDRDatabase sharedDatabase] availableLocaleIdentifiers];
}

+ (CPArray)ISOLanguageCodes
{
	return [[CLDRDatabase sharedDatabase] languageCodes];
}

+ (CPArray)ISOCountryCodes
{
	return [[CLDRDatabase sharedDatabase] countryCodes];
}

+ (CPDictionary)componentsFromLocaleIdentifier:(CPString)aLocaleIdentifier
{
	var localIdentifierParts = aLocaleIdentifier.split(/[-_]/),
		components = [CPMutableDictionary dictionary],
		language = localIdentifierParts.shift();

	if (!language)
		[CPException raise:@"InvalidLocaleIdentifier" format:@"CLDRKit could not parse the locale identifier \"%@\"", aLocaleIdentifier];

	[components setObject:aLocaleIdentifier forKey:CPLocaleIdentifier];
	[components setObject:language forKey:CPLocaleLanguageCode];

	var	territoryOrScript = localIdentifierParts.shift();

	if (!territoryOrScript)
		return components;

	if (territoryOrScript.length == 4)
	{
		[components setObject:territoryOrScript forKey:CPLocaleScriptCode];
		territory = localIdentifierParts.shift();
	}
	else
		territory = territoryOrScript;

	if (!territory)
		return components;

	[components setObject:territory forKey:CPLocaleCountryCode];

	var variant = localIdentifierParts.join("_");

	if (variant)
		[components setObject:variant forKey:CPLocaleVariantCode];

	return components;
}

+ (void)_platformLocaleAdditionalDescriptionForIdentifier:(CPString)aLocaleIdentifier
{
	var additionalData = [CPMutableDictionary dictionary],
		cldrData = [[CLDRDatabase sharedDatabase] mergedLocaleWithIdentifier:aLocaleIdentifier],
		components = [self componentsFromLocaleIdentifier:aLocaleIdentifier];

	[additionalData addEntriesFromDictionary:cldrData];
	[additionalData addEntriesFromDictionary:components];

	// CPLocaleExemplarCharacterSet
	[additionalData setObject:[CPCharacterSet characterSetWithCharactersInString:[cldrData valueForKeyPath:@"_CPLocaleExemplarCharacterSetString"]] forKey:CPLocaleExemplarCharacterSet];

	var countries = [[CLDRDatabase sharedDatabase] countries],
		country = [components objectForKey:CPLocaleCountryCode];

	// CPLocaleCurrencySymbol
	[additionalData setObject:[[countries objectForKey:country] objectForKey:CPLocaleCurrencySymbol] forKey:CPLocaleCurrencySymbol];

	// CPLocaleCurrencyCode
	[additionalData setObject:[[countries objectForKey:country] objectForKey:CPLocaleCurrencyCode] forKey:CPLocaleCurrencyCode];

	// print([additionalData description]);
	return additionalData;
}

- (CPString)displayNameForKey:(id)key value:(id)value
{
	var cldrData = [[CLDRDatabase sharedDatabase] mergedLocaleWithIdentifier:[self localeIdentifier]],
		localeDisplayNames = [cldrData objectForKey:@"_localeDisplayNames"],
		localeComponents = [CPLocale componentsFromLocaleIdentifier:value],
		languageComponent = [localeComponents objectForKey:CPLocaleLanguageCode],
		language = [[localeDisplayNames objectForKey:CPLocaleLanguageCode] objectForKey:languageComponent],
		countryComponent = [localeComponents objectForKey:CPLocaleCountryCode],
		country = [[localeDisplayNames objectForKey:CPLocaleCountryCode] objectForKey:countryComponent];

	if (key == CPLocaleLanguageCode)
		return language;

	if (key == CPLocaleCountryCode)
		return country;

	if (key == CPLocaleIdentifier)
		return [CPString stringWithFormat:[localeDisplayNames objectForKey:@"localePattern"],language,country];
}

@end
