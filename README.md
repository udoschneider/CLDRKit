#CLDRKit

ATTENTION! This is still in alpha stage and absolutely unusable in anything other than a playground project!

## Synopsis

*CLDRKit* aims to provide full CPLocale support for the [Cappuccino Web Framework](http://www.cappuccino-project.org/) using the CLDR locale data fron the [CLDR - Unicode Common Locale Data Repository](http://cldr.unicode.org/). CLDR data is maintained by maintained by Unicode consortium and automatically parsed by CLDR kit. So every update by Unicode is automatically usable without any manual interaction!


## Code Example

Either obtain a system `CPLocale` instance or create one manually:

    @import <CLDRKit.j>
    
    var germanLocale = [CPLocale localeWithLocaleIdentifier:@"de_DE"],
        frLocale = [[CPLocale alloc] initWithLocaleIdentifier:@"fr_FR"],
		usLocale = [CPLocale localeWithLocaleIdentifier:@"en_US"];
    
The resulting `CPLocale` instance provides all the basic functionality to query locales specific data defined by CLDR. E.g.:

    [germanLocale objectForKey:CPLocaleIdentifier] --> @"de_DE"
    [germanLocale objectForKey:CPLocaleLanguageCode] --> @"de"
    [germanLocale objectForKey:CPLocaleCountryCode] --> @"DE"
    
    [frLocale displayNameForKey:CPLocaleLanguageCode value:@"fr_FR"] --> @"français"    
	[frLocale displayNameForKey:CPLocaleLanguageCode value:@"en_US"] --> @"anglais"

	[frLocale displayNameForKey:CPLocaleCountryCode value:@"fr_FR"] --> @"France"
	[frLocale displayNameForKey:CPLocaleCountryCode value:@"en_US"] --> @"États-Unis"

	[frLocale displayNameForKey:CPLocaleIdentifier value:@"fr_FR"] --> @"français (France)"
	[frLocale displayNameForKey:CPLocaleIdentifier value:@"en_US"] --> @"anglais (États-Unis)"
	
	[germanLocale objectForKey:CPLocaleDecimalSeparator] --> @","
	[usLocale objectForKey:CPLocaleDecimalSeparator] --> @"."



## Motivation

Cocoa provides a comprehensive support for i18n out of the box - for View and core classes. This means all numbers, dates and other locale specific date is displayd/parsed according to the current locale. Cappuccino does not yet implement this locale support although the basic classes (e.g. `CPLocale`) are available. IMHO this is caused by the ammount of work needed for each locale if this data is maintained manually. CLDRKit addresses this by automatically building locales from external data. Thus _l18n will simply be a matter of the framework for every/locale_ ... l10n is another matter though ...

## Installation

### Using prebuilt locales

Please note that the github repository does contain preparsed plists for all locales. You don't have to generate them manually! _I have to check licensing issues though_

    $ git clone https://github.com/krodelin/CLDRKit
    $ cd CLDRKit
    $ jake install
    
### Rebuild locales from CLDR data

#### External dependencies/Build setup

You'll need the following external components:

1. A JRE environment
2. A copy of the CLDR core data. At the time of writing this was [Version 25 of core.zip](http://unicode.org/Public/cldr/25/core.zip).
3. A copy of the CLDR tools. At the time of writing this was [Version 25 of tools.zip](http://unicode.org/Public/cldr/25/tools.zip). Please not that based on your environment additional components like ant and ICU4J might be needed.

Extract the archives and change the variable (`CLDR_DIR`, `CLDR_TOOLS_FOLDER` and `ICU4J_FOLDER`)  in `Ldml2JsonConverter` to point to the according directories.

#### Configuration

You might want to change `CLDR_INITIAL_LOCALES` in `cldr.js` to list a number of locales which should be included in the initial data (reducing the number of requests for demand loading).

#### Generate locales

1. Create JSON data from XML. Please note that CLDR does provide pre-built JSON files. In my experience they are incomplete - in terms of supported locales and included data. So we'll build our own from the full-blown XML
    a. Generate "main" data in directory `cldr` using `$ ./Ldml2JsonConverter -d cldr -t main -r false -l modern`
    b. Generate supplemental data in directory `cldr` using `$ ./Ldml2JsonConverter -d cldr -t supplemental -r false -l modern`
2. Create locale plists from JSON in `Ressources/locales` using `$ jake cldr`. `Ressources/locales` will contain the following files:
    * `root.plist`: The data for the root locale
	* One `.plist` file _per language_: E.g. `de.plist` contains data for `de`, `de_AT`, `de_CH` and `de_DE`.
	* `initial.plist`: Core data needed by CLDRKit (e.g. _available_ locales).
	* Optional/Debug
        * `DEBUG.plist`: The complete data of all locales
        * All files in JSON format. Not used by CLDRKit ... but this makes testing the generated files easier ...


## API Reference

The intended API is identical to the one used by [NSLocale](https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSLocale_Class/Reference/Reference.html). The [NSLocale blog enty by NSHipster](http://nshipster.com/nslocale/) provides some additial background (must read!).

## Tests

Please note that some tests are either failing (still alpha) or generate warnings due to return types!

    $ ojtest Test/*
   

## Background

### CLDR hierachical locales

CLDR uses a _hierarchical_ model for locales. E.g. the locale `en_US` denotes a locale for the language english (`en`) and the region/country United States (`US`). Some locales even diffrentiate different scripts. All locale data is part of a tree whose root is calles `root`:

    +-root
      +-de
      | +-AT
      | |-CH
      | +-DE
      +-en
        +-US
        +-GB
        
`root` already defines all locale data in a very generic way. All of it's children only define the delta to their parent. E.g. `en_US` and `en_GB` only specify differences to the `en` locale. So to obtain the full data for `en_US` one has to start with `root`and apply all the changes from `en` and `US` in this order.

### Implementation choices

This means two option for a framework like CLDRKit:

1. Use pre-merged (during build time) locales
    * Pro
        1. Each locale requested by the browser can (in theory) be fetched using a single HTTP Request.
    * Con
        1. The deployment size would be huge! Having all (defined) locales pre-merged results in a locale DB with 100s of MB! This might be feasible for a desktop operating systems - for a WebApp it is not!
        2. CLDR only lists locales for which data (deltas) is known. E.g. _`en_CN` is unknown_ (english in China?) but _not invalid_! CLDR dictates to search up the tree (in this case `en`) until a match is found. This also means that at least the `root` locale will allways match and thus provide sensible defaults.
2. Use demand-loading during runtime
    * Pro
        1. Much smaller filesize as each locale only stores the delta to it's parent
    * Con
    	1. Higher number of requests. Naïve Demand loading would create three requests for a locale `en_US` (`root.plist`, `en.plist` and `en_US.plist`).
    	2. Not-Found Requests (404): Without the framework being aware which locale data is available you can only try to fetch a locale and react accordingly if you get a 404. E.g. `en_CH` would try to fetch `en_CH.plist` only to realize (404) that it's not available.
    	
### Actual implementation

Even in _full demand loading_ mode (i.e. `CLDR_INITIAL_LOCALES` is empty - in production it should at least contain widely used locales like `en`, `es`, `fr`, `de`. `root` is always included) CLDRKit uses two strategies to reduce the number of requests:

1. `initial.plist`: This plist contains meta-data - especially all the locales known to CLDRKit. This eliminates requests for non-existing locales:
2. Language locales: Instead of storing each region/country seperately CLDKit combined all locales for a language into one file. E.g. `de.plist` contains the data for `de`, `de_AT`, `de_CH` and `de_DE`.

So in production (e.g. `CLDR_INITIAL_LOCALES = [ 'de.*', 'en.*', 'es.*', 'fr.*', 'pt.*' ]`) requesting a locale for a country/region where the language is either german, english, spanish, french or portugese will only result in _one request_ (fetching `initial.plist`). Any other requested locale will only result in one additional request _per language_!

The actual demand loading, caching and merging of CLDR data is completely implemented in `CLDRDatabase`.

    var cldrData = [[CLDRDatabase sharedDatabase] mergedLocaleWithIdentifier:@"de_AT"];
    
`cldrData` will contain the fully merged data from the provided locale (based on the available data) which is then used by `CPLocale`.    

### Caveats

* Some Cappuccino core classes do use `CPLocale` (e.g. `CPDatePicker`) and would in theory benefit from full locale support automatically). Others (e.g. `CPDateFormatter`) don't and provide their own l18n capability ... which is sometimes broken (e.g. `CPDateFormater` claims support for `fr`, `en`, `de` and `es` ... however the array for `de` and `es` are empty thus resulting in no output at all for browsers with this locale!). A possible solution might be to refactor core classes to always use `CPLocale`. Extending `CPLocale` with a sensible static data would make Cappuccino l18n enabled. For those needing full locale support CLDRKit could then provide additional locales (e.g. by implementing `CPLocale#_platformLocaleAdditionalDescriptionForIdentifier:`).
      
## Contributors

* Udo Schneider <udo.schneider@homeaddress.de>

## License

Copyright 2014, Krodelin Software Solutions. All rights reserved.

This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.