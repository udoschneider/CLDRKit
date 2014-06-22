CLDR_VERSION=25
CLDR_BASEURL=http://unicode.org/Public/cldr/${CLDR_VERSION}
CLDR_CORE_URL=${CLDR_BASEURL}/core.zip
CLDR_CORE_DIR=$(CURDIR)/core
CLDR_TOOLS_URL=${CLDR_BASEURL}/tools.zip

ANT_VERSION=1.9.4
ANT_FOLDER=apache-ant-${ANT_VERSION}
ANT_ZIP=${ANT_FOLDER}-bin.zip
ANT_URL=http://apache.openmirror.de/ant/binaries/${ANT_ZIP}
ANT=$(CURDIR)/${ANT_FOLDER}/bin/ant

Ldml2JsonConverterClass=tools/tools/java/classes/org/unicode/cldr/json/Ldml2JsonConverter.class
Ldml2JsonConverterJava=tools/tools/java/org/unicode/cldr/json/Ldml2JsonConverter.java

CLASSPATH=tools/tools/java/classes:tools/tools/java/libs/icu4j.jar:tools/tools/java/libs/utilities.jar:tools/tools/java/libs/guava-16.0.1.jar

default: all

core:/ core.zip
	unzip -d core core.zip 

core.zip:
	wget ${CLDR_CORE_URL}
	
tools/: tools.zip
	unzip -d tools tools.zip

tools.zip:
	wget ${CLDR_TOOLS_URL}
	 
${ANT_FOLDER}/: ${ANT_ZIP}
	unzip ${ANT_ZIP}

${ANT_ZIP}:
	wget ${ANT_URL}

${Ldml2JsonConverterClass}: tools/ ${ANT_FOLDER} ${Ldml2JsonConverterJava}
	cd tools/tools/java && ${ANT} json

json/main/: ${Ldml2JsonConverterClass} core/
	CLDR_DIR=${CLDR_CORE_DIR} java -cp ${CLASSPATH} org.unicode.cldr.json.Ldml2JsonConverter -d json -t main -r false -l modern

json/supplemental/: ${Ldml2JsonConverterClass} core/
	CLDR_DIR=${CLDR_CORE_DIR} java -cp ${CLASSPATH} org.unicode.cldr.json.Ldml2JsonConverter -d json -t supplemental -r false -l modern

clean:
	rm -fR core tools ${ANT_FOLDER} json

clean-downloads:
	rm -fR core.zip tools.tip ${ANT_ZIP}

all: ${ICU4J_FOLDER}/ json/main/ json/supplemental/

.PHONY: all clean