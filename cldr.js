var stream = require("narwhal/term").stream,
	FILE = require("file");

var  CLDR_SRC_DIR = "cldr",
     CLDR_DST_DIR = "Resources/locales",
     CLDR_INITIAL_LOCALES = [ "de.*" ],
     CLDR_INITIAL_LOCALES_REGEXP = new RegExp("^(" + CLDR_INITIAL_LOCALES.join("|") + ")$");

var DEBUG = true;

var create = function() {
	var cldrData = readCldrData();
	if (DEBUG)
    storeLocale("DEBUG", cldrData); // Debug
	
  storeInitial(cldrData);
  storeLanguages(cldrData);

};

var readCldrData = function () {
  var cldrData = {},
    jsonFileMatch = /^.*json$/;
  FILE.listTree(FILE.join(CLDR_SRC_DIR)).forEach(function (filename){
    if (filename.match(jsonFileMatch))
    {
      var filename = FILE.join(CLDR_SRC_DIR, filename),
        file = FILE.open(filename, "rb");
                try {
                  colorPrint("Loading " + filename, "bold+green");
                  var contents = file.read(),
                    stringContents = contents.decodeToString("utf-8"),
                    json = JSON.parse(stringContents);
                  cldrData = mergeRecursive(cldrData, json);
                } finally {
                  file.close();
                }
    }
  });
  return cldrData;
};

var isInitialLocaleIdentifier = function(localeIdentifier)
{
  if (localeIdentifier == "root")
    return true;

  return localeIdentifier.match(CLDR_INITIAL_LOCALES_REGEXP); 
}

var isOnDemandLocaleIdentifier = function(localeIdentifier)
{
  return !(isInitialLocaleIdentifier(localeIdentifier));
}

var storeInitial = function(cldrData)
{
  var data = {},
    availableLocales = Object.keys(cldrData.main),
    initialLocales = availableLocales.filter(isInitialLocaleIdentifier);

  data["supplemental"] = cldrData.supplemental;
  data["main"] = {};
  data["availableLocales"] = availableLocales;

  initialLocales.forEach(function(localeIdentifier){data.main[localeIdentifier] = cldrData.main[localeIdentifier];})

  storeLocale("initial", data);
};

var storeLanguages = function (cldrData)
{
  var availableLocales = Object.keys(cldrData.main),
  onDemandLocales = availableLocales.filter(isOnDemandLocaleIdentifier),
  onDemandLanguages = unique(onDemandLocales.map(function (locale){return locale.split("-")[0]}));

  onDemandLanguages.forEach(function (language){
    var data = { main:{}},
      languageRegExp = new RegExp("^"+language+".*");
    onDemandLocales.forEach(function (locale){
      if(locale.match(languageRegExp))
        data.main[locale] = cldrData.main[locale];
    });
    storeLocale(language, data);
  });

}

var storeLocale = function (filename, data)
{
    colorPrint("Storing " + filename, "bold+green");
    chunkedSave(FILE.join(CLDR_DST_DIR, filename + ".plist"), CFPropertyList.stringFromPropertyList(CFType(data)));
    if (DEBUG)
      chunkedSave(FILE.join(CLDR_DST_DIR, filename + ".json"),  JSON.stringify(data, undefined, 4));
};

// ******** Helper functions

var unique = function(array) {
    var unique = [];
    for (var i = 0; i < array.length; i++) {
        if (unique.indexOf(array[i]) == -1) {
            unique.push(array[i]);
        }
    }
    return unique;
};

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

exports.create = create;

