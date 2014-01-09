var stream = require("narwhal/term").stream,
	FILE = require("file");

var  CLDR_SRC_DIR = "cldr",
     CLDR_DST_DIR = "Resources/locales",
     CLDR_ROOT_LOCALES = [ ],
     CLDR_AVAILABLE_LOCALES = [".*"],
     CLDRData = {},
     CPLocaleData = {
     	locales:{},
     	available:[],
     	languages:[],
     	countries:{},
     };

CPLocaleIdentifier                          = "CPLocaleIdentifier";
CPLocaleLanguageCode                        = "CPLocaleLanguageCode";
CPLocaleCountryCode                         = "CPLocaleCountryCode";
CPLocaleScriptCode                          = "CPLocaleScriptCode";
CPLocaleVariantCode                         = "CPLocaleVariantCode";
CPLocaleExemplarCharacterSet                = "CPLocaleExemplarCharacterSet";
CPLocaleCalendar                            = "CPLocaleCalendar";
CPLocaleCollationIdentifier                 = "CPLocaleCollationIdentifier";
CPLocaleUsesMetricSystem                    = "CPLocaleUsesMetricSystem";
CPLocaleMeasurementSystem                   = "CPLocaleMeasurementSystem";
CPLocaleDecimalSeparator                    = "CPLocaleDecimalSeparator";
CPLocaleGroupingSeparator                   = "CPLocaleGroupingSeparator";
CPLocaleCurrencySymbol                      = "CPLocaleCurrencySymbol";
CPLocaleCurrencyCode                        = "CPLocaleCurrencyCode";
CPLocaleCollatorIdentifier                  = "CPLocaleCollatorIdentifier";
CPLocaleQuotationBeginDelimiterKey          = "CPLocaleQuotationBeginDelimiterKey";
CPLocaleQuotationEndDelimiterKey            = "CPLocaleQuotationEndDelimiterKey";
CPLocaleAlternateQuotationBeginDelimiterKey = "CPLocaleAlternateQuotationBeginDelimiterKey";
CPLocaleAlternateQuotationEndDelimiterKey   = "CPLocaleAlternateQuotationEndDelimiterKey";

CPGregorianCalendar                         = "CPGregorianCalendar";
CPBuddhistCalendar                          = "CPBuddhistCalendar";
CPChineseCalendar                           = "CPChineseCalendar";
CPHebrewCalendar                            = "CPHebrewCalendar";
CPIslamicCalendar                           = "CPIslamicCalendar";
CPIslamicCivilCalendar                      = "CPIslamicCivilCalendar";
CPJapaneseCalendar                          = "CPJapaneseCalendar";
CPRepublicOfChinaCalendar                   = "CPRepublicOfChinaCalendar";
CPPersianCalendar                           = "CPPersianCalendar";
CPIndianCalendar                            = "CPIndianCalendar";
CPISO8601Calendar                           = "CPISO8601Calendar";

CPLocaleLanguageDirectionUnknown            = "CPLocaleLanguageDirectionUnknown";
CPLocaleLanguageDirectionLeftToRight        = "CPLocaleLanguageDirectionLeftToRight";
CPLocaleLanguageDirectionRightToLeft        = "CPLocaleLanguageDirectionRightToLeft";
CPLocaleLanguageDirectionTopToBottom        = "CPLocaleLanguageDirectionTopToBottom";
CPLocaleLanguageDirectionBottomToTop        = "CPLocaleLanguageDirectionBottomToTop";

var createCPLocalePropertyLists = function() {
	readCldrData();
	storeLocale("DEBUG", CLDRData); // Debug
	for(var localeIdentifier in CLDRData.main)
		transformCldrLocaleToCPLocale(localeIdentifier);
    fillCountryData();
	print(CFType(CPLocaleData));
	storeLocale("initial", CPLocaleData);
};

var readCldrData = function () {
	var jsonFileMatch = /^.*json$/;
	var jsonFileMatch = /^(root|supplemental|en|en-US.*|de.*|fr.*|es.*|it.*)\/.*json$/;
	FILE.listTree(FILE.join(CLDR_SRC_DIR)).forEach(function (filename){
		if (filename.match(jsonFileMatch))
		{
			var filename = FILE.join(CLDR_SRC_DIR, filename),
				file = FILE.open(filename, "rb");
                try {
                	var contents = file.read(),
                		stringContents = contents.decodeToString("utf-8"),
                		json = JSON.parse(stringContents);
	                colorPrint("Loaded " + filename, "bold+green");
	                CLDRData = mergeRecursive(CLDRData, json);
                } finally {
                	file.close();
                }
		}
	});
};

var transformCldrLocaleToCPLocale = function(localeIdentifier) {
	var cldrLocale = CLDRData.main[localeIdentifier],
		cpLocale = { _localeDisplayNames:{} },
		cpLocaleIdentifier = cleanLocaleIdentifier(localeIdentifier),
		temp;

	cpLocale[CPLocaleIdentifier] = cpLocaleIdentifier;

	var identityData = cldrLocale.identity;

	if (temp = identityData.language)
	{
		cpLocale[CPLocaleLanguageCode] = temp;
		CPLocaleData.languages = unique(CPLocaleData.languages.concat(temp));
	}

	if (temp = identityData.territory)
	{
		cpLocale[CPLocaleCountryCode] = temp;
		CPLocaleData.countries[temp] = {}; // unique(CPLocaleData.countries.concat(temp));
	}

	if (temp = identityData.script)
		cpLocale[CPLocaleScriptCode] = temp;

	if (temp = identityData.variant)
		cpLocale[CPLocaleVariantCode] = temp

	if (temp = keyPath(cldrLocale, "characters.exemplarCharacters"))
		cpLocale["_CPLocaleExemplarCharacterSetString"] = temp.split(/[\[\]\s]/).join("");

	if (temp = keyPath(cldrLocale, "numbers.symbols-numberSystem-latn.decimal"))
		cpLocale[CPLocaleDecimalSeparator] = temp;

	if (temp = keyPath(cldrLocale, "numbers.symbols-numberSystem-latn.group"))
		cpLocale[CPLocaleGroupingSeparator] = temp;

	if (temp = keyPath(cldrLocale, "delimiters.quotationStart"))
		cpLocale[CPLocaleQuotationBeginDelimiterKey] = temp;

	if (temp = keyPath(cldrLocale, "delimiters.quotationEnd"))
		cpLocale[CPLocaleQuotationEndDelimiterKey] = temp;

	if (temp = keyPath(cldrLocale, "delimiters.alternateQuotationStart"))
		cpLocale[CPLocaleAlternateQuotationBeginDelimiterKey] = temp;
	
	if (temp = keyPath(cldrLocale, "delimiters.alternateQuotationEnd"))
		cpLocale[CPLocaleAlternateQuotationEndDelimiterKey] = temp;

	if (temp = keyPath(cldrLocale, "localeDisplayNames.languages"))
		cpLocale["_localeDisplayNames"][CPLocaleLanguageCode] = temp;

	if (temp = keyPath(cldrLocale, "localeDisplayNames.territories"))
		cpLocale["_localeDisplayNames"][CPLocaleCountryCode] = temp;

	if (temp = keyPath(cldrLocale, "localeDisplayNames.localeDisplayPattern"))
		for (var key in temp)
			cpLocale["_localeDisplayNames"][key] = convertPositionalParameter(temp[key]);
			
	CPLocaleData.locales[cpLocaleIdentifier] = cpLocale;

	CPLocaleData.available = CPLocaleData.available.concat(cpLocaleIdentifier);

    colorPrint("Transformed " + cpLocaleIdentifier, "bold+green");
};

var fillCountryData = function() {
    var cldrSupplemental = CLDRData.supplemental;

    for (var countryCode in CPLocaleData.countries)
    {
        var currencies;
        if (currencies = keyPath(cldrSupplemental, "currencyData.region." + countryCode))
        {
            var currentCurrencyDate,
                currentCurrencyCode,
                currentCurrencySymbol;
            for (var index = 0; index < currencies.length; index++)
            {
                var currencyHash = currencies[index];
                for (var currencySymbol in currencyHash)
                {
                    var from = new Date(currencyHash[currencySymbol]["_from"]);
                    if (!currentCurrencyDate || currentCurrencyDate < from)
                    {
                        currentCurrencyDate = from;
                        currentCurrencyCode = currencySymbol;
                    }
                }
            }
            CPLocaleData.countries[countryCode][CPLocaleCurrencyCode] = currentCurrencyCode;
        }
    }
};

var cleanLocaleIdentifier = function(localeIdentifier) {
	return localeIdentifier.split(/[-_]/).join("_");
};

// ******** Helper functions

var mergeRecursive = function(obj1, obj2) {
  for (var p in obj2) {
    try {
      // Property in destination object set; update its value.
      if ( obj2[p].constructor==Object ) {
        obj1[p] = mergeRecursive(obj1[p], obj2[p]);

      } else {
        obj1[p] = obj2[p];

      }

    } catch(e) {
      // Property in destination object not set; create it and set its value.
      obj1[p] = obj2[p];
    }
  }
  return obj1;
};

var colorPrint = function(message, color)
{
    var matches = color.match(/(bold(?: |\+))?(.+)/);

    if (!matches)
        return;

    message = "\0" + matches[2] + "(" + message + "\0)";

    if (matches[1])
        message = "\0bold(" + message + "\0)";

    stream.print(message);
};

var CFType = function(value) {
    if (value instanceof Array)
        return value.map(function(each){return CFType(each)});
    if (typeof value == "object")
    {
        var dic = new CFMutableDictionary();
        for (var key in value) {
            dic.addValueForKey(key, CFType(value[key]));
        }
        return dic;
    }
    return value;
};

var storeLocale = function (filename, data)
{
    chunkedSave(FILE.join(CLDR_DST_DIR, filename + ".plist"), CFPropertyList.stringFromPropertyList(CFType(data)));
    chunkedSave(FILE.join(CLDR_DST_DIR, filename + ".json"),  JSON.stringify(data));
};

var chunkedSave = function (filename, string) {
	// Writing directly throws a segmentation fault - paged writing does not ...
	// A simple FILE.write(filename, string) /should/ be sufficient here ...
	var file = FILE.open(filename, "wb"),
		PAGE_SIZE = Math.pow(2,21);
		try {
			for (var position=0; position < string.length; position = position + PAGE_SIZE)
				file.write(string.substr(position, PAGE_SIZE));
		} finally {
			file.close();
		}
};

var keyPath = function(hash, keyPath) {
	var keys = keyPath.split(".");
	for (var index = 0; index < keys.length; index++) {
		try {
			hash = hash[keys[index]];
		} catch(e) {
			return undefined;
		}
	}
	return hash;
};

var unique = function(array) {
    var unique = [];
    for (var i = 0; i < array.length; i++) {
        if (unique.indexOf(array[i]) == -1) {
            unique.push(array[i]);
        }
    }
    return unique;
};

var convertPositionalParameter = function(string) {
	for (var index = 0; index < 10; index++)
		string = string.replace(new RegExp("\\\{" + index + "\\\}"), "%" + (index + 1) + "$@");
	return string;
};

/*
String.prototype.capitalize = function() {
    return this.replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); });
};
*/

exports.create = createCPLocalePropertyLists;

/*

     task ("clean-cldr", function(){
    if (FILE.exists(CLDR_DST_DIR))
        FILE.rmtree(CLDR_DST_DIR);
});

task ("cldr", function()
{
    colorPrint("--------------------------------------------------------------------------", "bold+green");
    colorPrint("CLDRKit - Proccessing source files", "bold+green");
    colorPrint("--------------------------------------------------------------------------", "bold+green");
    // ./Ldml2JsonConverter -d cldr -m "^(de.*|root)$" -t main -r true
    var root = {},
        rootRegExp = new RegExp("^(" + CLDR_ROOT_LOCALES.join("|") + ")$"),
        rootLocales = [],
        available = {},
        availableRegExp = new RegExp("^(" + CLDR_AVAILABLE_LOCALES.join("|") + ")$"),
        availableLocales = [],
        countryCodes = [],
        fileRegExp = new RegExp("^(.*)\.json$");

    if (!(FILE.exists(CLDR_DST_DIR)))
        FILE.mkdirs(CLDR_DST_DIR);

    FILE.list(CLDR_SRC_DIR).forEach(function (locale){

        if (locale != "supplemental" && (locale == "root" || locale.match(rootRegExp) || locale.match(availableRegExp)))
        {
            var cpLocale;
            FILE.list(FILE.join(CLDR_SRC_DIR, locale)).forEach(function (file){
                if (file.match(fileRegExp))
                {
                    var filename = FILE.join(CLDR_SRC_DIR, locale, file),
                        contents = FILE.read(filename, "b"),
                        stringContents = contents.decodeToString("utf-8"),
                        json = JSON.parse(stringContents);
                    cpLocale = mergeRecursive((cpLocale || {}), json);
                }
            });

            if (cpLocale)
            {
                var language,
                    script,
                    territory,
                    variant,
                    mainLocaleData = cpLocale["main"][locale]["identity"],
                    localeIdentifier = "";

                if ("language" in mainLocaleData)
                    localeIdentifier = (language = mainLocaleData["language"].toLowerCase());
                if ("script" in mainLocaleData)
                    localeIdentifier = localeIdentifier + "_" + (script = mainLocaleData["script"].capitalize());
                if ("territory" in mainLocaleData)
                    localeIdentifier = localeIdentifier + "_" + (territory = mainLocaleData["territory"].toUpperCase());
                if ("variant" in mainLocaleData)
                    localeIdentifier = localeIdentifier + "_" + (variant = mainLocaleData["variant"].toUpperCase());

                if (localeIdentifier != "root")
                    availableLocales = availableLocales.concat(localeIdentifier);

                // cpLocale = {"main":{ localeIdentifier:cpLocale["main"][locale]}};
                var temp = cpLocale["main"][locale];
                //cpLocale = { "main":{}};
                cpLocale = {};
                cpLocale["main"] = {};
                cpLocale["main"][localeIdentifier] = temp;
                //cpLocale["main"][localeIdentifier] = cpLocale["main"][locale];
                //delete cpLocale["main"][locale];

                if ( (localeIdentifier == "root") || localeIdentifier.match(rootRegExp))
                {
                    rootLocales = rootLocales.concat(localeIdentifier);
                    root = mergeRecursive(root, cpLocale);
                    colorPrint("Parsing locale " + localeIdentifier + "\t(merge into root)", "bold+green");
                }
                else
                {
                    available[language] = mergeRecursive((available[language] || {}), cpLocale);
                    colorPrint("Parsing locale " + localeIdentifier + "\t(merge into " + language + ")", "bold+green");
                }

                if (localeIdentifier == "en")
                {
                    for (var key in cpLocale["main"][localeIdentifier]["localeDisplayNames"]["territories"])
                        countryCodes = countryCodes.concat(key);
                }
            }
        }
    });
    colorPrint("--------------------------------------------------------------------------", "bold+green");
    for (var language in available)
    {
        colorPrint("Storing locale "+language, "bold+green");
        storeLocale(available[language], language);
    }
    colorPrint("Storing locale root", "bold+green");
    root["rootLocales"] = rootLocales;
    root["availableLocales"] = availableLocales;
    root["countryCodes"] = countryCodes;

    var supplementalData;
    FILE.list(FILE.join(CLDR_SRC_DIR, "supplemental")).forEach(function (file){
            var filename = FILE.join(CLDR_SRC_DIR, "supplemental", file),
                contents = FILE.read(filename, "b"),
                stringContents = contents.decodeToString("utf-8"),
                json = JSON.parse(stringContents);
            supplementalData = mergeRecursive((supplementalData || {}), json);
    });
    root["supplemental"] = supplementalData["supplemental"];

    storeLocale(root, "root");
    colorPrint("--------------------------------------------------------------------------", "bold+green");

});







*/
