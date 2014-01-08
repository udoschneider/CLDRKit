/*
 * Jakefile
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

//===========================================================
//  DO NOT REMOVE
//===========================================================

var SYS = require("system"),
    ENV = SYS.env,
    FILE = require("file"),
    OS = require("os");


//===========================================================
//  USER CONFIGURABLE VARIABLES
//===========================================================

/*
    The directory in which the project will be built. By default
    it is built in $CAPP_BUILD if that is defined, otherwise
    in a "Build" directory within the project directory.
*/
var buildDir = ENV["BUILD_PATH"] || ENV["CAPP_BUILD"] || "Build";

/*
    The list of directories containing Objective-J source
    that should be compiled by jake. The main framework
    directory is always checked for Objective-J source,
    you only need to edit this if you have source in
    subdirectories. Do NOT include a leading ortrailing slash
    in the directory name.

    Example:

    var sourceDirs = [
            "Core",
            "Modules",
            "Modules/Foo",
            "Modules/Bar"
        ];
*/
var sourceDirs = [
    ];


 //===========================================================
 //  AUTOMATICALLY GENERATED
 //
 //  Do not edit! (unless you know what you are doing)
 //===========================================================

var stream = require("narwhal/term").stream,
    JAKE = require("jake"),
    task = JAKE.task,
    CLEAN = require("jake/clean").CLEAN,
    CLOBBER = require("jake/clean").CLOBBER,
    FileList = JAKE.FileList,
    filedir = JAKE.filedir,
    framework = require("cappuccino/jake").framework,
    browserEnvironment = require("objective-j/jake/environment").Browser,
    configuration = ENV["CONFIG"] || ENV["CONFIGURATION"] || ENV["c"] || "Debug",
    productName = "CLDRKit",
    buildPath = FILE.canonical(FILE.join(buildDir, productName + ".build")),
    packageFrameworksPath = FILE.join(SYS.prefix, "packages", "cappuccino", "Frameworks"),
    debugPackagePath = FILE.join(packageFrameworksPath, "Debug", productName);
    releasePackagePath = FILE.join(packageFrameworksPath, productName);

var frameworkTask = framework (productName, function(frameworkTask)
{
    frameworkTask.setBuildIntermediatesPath(FILE.join(buildPath, configuration));
    frameworkTask.setBuildPath(FILE.join(buildDir, configuration));

    frameworkTask.setProductName(productName);
    frameworkTask.setIdentifier("com.krodelin.CLDRKit");
    frameworkTask.setVersion("1.0");
    frameworkTask.setAuthor("Krodelin Software Solutions");
    frameworkTask.setEmail("info@krodelin.com");
    frameworkTask.setSummary("CLDRKit");

    var includes = sourceDirs.map(function(dir) { return dir + "/*.j"; }),
        fileList = new FileList();

    includes.unshift("*.j");
    fileList.include(includes);
    frameworkTask.setSources(fileList);
    frameworkTask.setResources(new FileList("Resources/**/*"));
    frameworkTask.setFlattensSources(true);
    frameworkTask.setInfoPlistPath("Info.plist");
    frameworkTask.setLicense(BundleTask.License.LGPL_v2_1);
    //frameworkTask.setEnvironments([browserEnvironment]);

    if (configuration === "Debug")
        frameworkTask.setCompilerFlags("-DDEBUG -g");
    else
        frameworkTask.setCompilerFlags("-O");
});

var  CLDR_SRC_DIR = "cldr",
     CLDR_DST_DIR = "Resources/locales",
     CLDR_ROOT_LOCALES = [ "de.*", "en.*", , "es.*", "fr.*"],
     CLDR_AVAILABLE_LOCALES = [".*"];

task ("debug", function()
{
    ENV["CONFIGURATION"] = "Debug";
    JAKE.subjake(["."], "build", ENV);
});

task ("release", function()
{
    ENV["CONFIGURATION"] = "Release";
    JAKE.subjake(["."], "build", ENV);
});

task ("default", ["release"]);

var frameworkCJS = FILE.join(buildDir, configuration, "CommonJS", "cappuccino", "Frameworks", productName);

filedir (frameworkCJS, [productName], function()
{
    if (FILE.exists(frameworkCJS))
        FILE.rmtree(frameworkCJS);

    FILE.copyTree(frameworkTask.buildProductPath(), frameworkCJS);
});

task ("build", [productName, frameworkCJS]);

task ("all", ["debug", "release"]);

task ("install", ["debug", "release"], function()
{
    install("copy");
});

task ("install-symlinks", ["debug", "release"], function()
{
    install("symlink");
});

task ("help", function()
{
    var app = JAKE.application().name();

    colorPrint("--------------------------------------------------------------------------", "bold+green");
    colorPrint("CLDRKit - Framework", "bold+green");
    colorPrint("--------------------------------------------------------------------------", "bold+green");

    describeTask(app, "debug", "Builds a debug version at " + FILE.join(buildDir, "Debug", productName));
    describeTask(app, "release", "Builds a release version at " + FILE.join(buildDir, "Release", productName));
    describeTask(app, "all", "Builds a debug and release version");
    describeTask(app, "install", "Builds a debug and release version, then installs in " + packageFrameworksPath);
    describeTask(app, "install-symlinks", "Builds a debug and release version, then symlinks the built versions into " + packageFrameworksPath);
    describeTask(app, "clean", "Removes the intermediate build files");
    describeTask(app, "clobber", "Removes the intermediate build files and the installed frameworks");

    colorPrint("--------------------------------------------------------------------------", "bold+green");
});

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

        if (locale != "suplemental" && locale == "root" || locale.match(rootRegExp) || locale.match(availableRegExp))
        {
            var localeData;
            FILE.list(FILE.join(CLDR_SRC_DIR, locale)).forEach(function (file){
                if (file.match(fileRegExp))
                {
                    var filename = FILE.join(CLDR_SRC_DIR, locale, file),
                        contents = FILE.read(filename, "b"),
                        stringContents = contents.decodeToString("utf-8"),
                        json = JSON.parse(stringContents);
                    localeData = mergeRecursive((localeData || {}), json);
                }
            });

            if (localeData)
            {
                var language,
                    script,
                    territory,
                    variant,
                    mainLocaleData = localeData["main"][locale]["identity"],
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

                // localeData = {"main":{ localeIdentifier:localeData["main"][locale]}};
                var temp = localeData["main"][locale];
                //localeData = { "main":{}};
                localeData = {};
                localeData["main"] = {};
                localeData["main"][localeIdentifier] = temp;
                //localeData["main"][localeIdentifier] = localeData["main"][locale];
                //delete localeData["main"][locale];

                if ( (localeIdentifier == "root") || localeIdentifier.match(rootRegExp))
                {
                    rootLocales = rootLocales.concat(localeIdentifier);
                    root = mergeRecursive(root, localeData);
                    colorPrint("Parsing locale " + localeIdentifier + "\t(merge into root)", "bold+green");
                }
                else
                {
                    available[language] = mergeRecursive((available[language] || {}), localeData);
                    colorPrint("Parsing locale " + localeIdentifier + "\t(merge into " + language + ")", "bold+green");
                }

                if (localeIdentifier == "en")
                {
                    for (var key in localeData["main"][localeIdentifier]["localeDisplayNames"]["territories"])
                    {
                        countryCodes = countryCodes.concat(key);
                    }
                    colorPrint("countryCodes: " + countryCodes, "bold+green");
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
    storeLocale(root, "root");
    colorPrint("--------------------------------------------------------------------------", "bold+green");

});

CLEAN.include(buildPath);
CLOBBER.include(FILE.join(buildDir, "Debug", productName))
       .include(FILE.join(buildDir, "Release", productName))
       .include(debugPackagePath)
       .include(releasePackagePath);

var install = function(action)
{
    var packageFrameworksPath = FILE.join(SYS.prefix, "packages", "cappuccino", "Frameworks");

    ["Release", "Debug"].forEach(function(aConfig)
    {
        colorPrint((action === "symlink" ? "Symlinking " : "Copying ") + aConfig + "...", "cyan");

        if (aConfig === "Debug")
            packageFrameworksPath = FILE.join(packageFrameworksPath, aConfig);

        if (!FILE.isDirectory(packageFrameworksPath))
            sudo(["mkdir", "-p", packageFrameworksPath]);

        var buildPath = FILE.absolute(FILE.join(buildDir, aConfig, productName)),
            targetPath = FILE.join(packageFrameworksPath, productName);

        if (action === "symlink")
            directoryOp(["ln", "-sf", buildPath, targetPath]);
        else
            directoryOp(["cp", "-rf", buildPath, targetPath]);
    });
};

var directoryOp = function(cmd)
{
    var targetPath = cmd[cmd.length - 1];

    if (FILE.isDirectory(targetPath))
        sudo(["rm", "-rf", targetPath]);

    sudo(cmd);
};

var sudo = function(cmd)
{
    if (OS.system(cmd))
        OS.system(["sudo"].concat(cmd));
};

var describeTask = function(application, task, description)
{
    colorPrint("\n" + application + " " + task, "violet");
    description.split("\n").forEach(function(line)
    {
        stream.print("   " + line);
    });
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

var mergeRecursive = function(obj1, obj2) {

  var obj = JSON.parse(JSON.stringify(obj1)); // poor man's deep copy
  for (var p in obj2) {
    try {
      // Property in destination object set; update its value.
      if ( obj2[p].constructor==Object ) {
        obj[p] = mergeRecursive(obj[p], obj2[p]);

      } else {
        obj[p] = obj2[p];

      }

    } catch(e) {
      // Property in destination object not set; create it and set its value.
      obj[p] = obj2[p];

    }
  }

  return obj;
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

var storeLocale = function (data, filename)
{
    FILE.write(FILE.join(CLDR_DST_DIR, filename + ".plist"), CFPropertyList.stringFromPropertyList(CFType(data)));
    FILE.write(FILE.join(CLDR_DST_DIR, filename + ".json"),  JSON.stringify(data));
};

Array.prototype.unique = function() {
    var unique = [];
    for (var i = 0; i < this.length; i++) {
        if (unique.indexOf(this[i]) == -1) {
            unique.push(this[i]);
        }
    }
    return unique;
};

String.prototype.capitalize = function() {
    return this.replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); });
};

