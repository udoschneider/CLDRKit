CLDR_BASE_DIR=$(CURDIR)

BUILD_DIR=${CLDR_BASE_DIR}/build
DOWNLOAD_DIR=${CLDR_BASE_DIR}/download
JSON_DIR=${CLDR_BASE_DIR}/json

CLDR_VERSION=25
CLDR_BASEURL=http://unicode.org/Public/cldr/${CLDR_VERSION}

CLDR_CORE_URL=${CLDR_BASEURL}/core.zip
CLDR_CORE_DIR=${BUILD_DIR}/core_v${CLDR_VERSION}
CLDR_CORE_ZIP=${DOWNLOAD_DIR}/core_v${CLDR_VERSION}.zip

CLDR_TOOLS_URL=${CLDR_BASEURL}/tools.zip
CLDR_TOOLS_DIR=${BUILD_DIR}/tools_v${CLDR_VERSION}
CLDR_TOOLS_ZIP=${DOWNLOAD_DIR}/tools_v${CLDR_VERSION}.zip

ANT_VERSION=1.9.4
ANT_DIR=${BUILD_DIR}/apache-ant-${ANT_VERSION}
ANT_ZIP=${DOWNLOAD_DIR}/apache-ant-${ANT_VERSION}-bin.zip
ANT_URL=http://apache.openmirror.de/ant/binaries/apache-ant-${ANT_VERSION}-bin.zip
ANT=${ANT_DIR}/bin/ant

Ldml2JsonConverterClass=${CLDR_TOOLS_DIR}/tools/java/classes/org/unicode/cldr/json/Ldml2JsonConverter.class
Ldml2JsonConverterJava=${CLDR_TOOLS_DIR}/tools/java/org/unicode/cldr/json/Ldml2JsonConverter.java

CLASSPATH=${CLDR_TOOLS_DIR}/tools/java/classes:${CLDR_TOOLS_DIR}/tools/java/libs/icu4j.jar:${CLDR_TOOLS_DIR}/tools/java/libs/utilities.jar:${CLDR_TOOLS_DIR}/tools/java/libs/guava-16.0.1.jar

default: all

${BUILD_DIR}:
	@echo "### Create build dir"
	@mkdir -p $@

${DOWNLOAD_DIR}:
	@echo "### Create Download dir"
	@mkdir -p $@


${CLDR_CORE_DIR}: ${CLDR_CORE_ZIP} ${BUILD_DIR}
	@echo "### Extract core data"
	@unzip -d $@ ${CLDR_CORE_ZIP} > /dev/null

${CLDR_CORE_ZIP}: ${DOWNLOAD_DIR}
	@echo "### Download core data"
	@wget ${CLDR_CORE_URL} -O $@
	

${CLDR_TOOLS_DIR}: ${CLDR_TOOLS_ZIP} ${BUILD_DIR}
	@echo "### Extract tools"
	@unzip -d $@ ${CLDR_TOOLS_ZIP} > /dev/null

${CLDR_TOOLS_ZIP}: ${DOWNLOAD_DIR}
	@echo "### Download tools"
	@wget ${CLDR_TOOLS_URL} -O $@

	 
${ANT_DIR}: ${ANT_ZIP}
	@echo "### Extract ant"
	@unzip -d ${BUILD_DIR} $? > /dev/null

${ANT_ZIP}:
	@echo "### Download Ant"
	@wget ${ANT_URL} -O $@


${Ldml2JsonConverterClass}: ${CLDR_TOOLS_DIR} ${ANT_DIR} ${Ldml2JsonConverterJava}
	@echo "### Build Ldml2JsonConverter"
	@cd ${CLDR_TOOLS_DIR}/tools/java && ${ANT} json > /dev/null


json/main: ${Ldml2JsonConverterClass} ${CLDR_CORE_DIR}
	@echo "### Convert main XML to JSON"
	@CLDR_DIR=${CLDR_CORE_DIR} java -cp ${CLASSPATH} org.unicode.cldr.json.Ldml2JsonConverter -d ${JSON_DIR} -t main -r false -l modern | grep "Processing" # > /dev/null

json/supplemental: ${Ldml2JsonConverterClass} ${CLDR_CORE_DIR}
	@echo "### Convert supplemental XML to JSON"
	@CLDR_DIR=${CLDR_CORE_DIR} java -cp ${CLASSPATH} org.unicode.cldr.json.Ldml2JsonConverter -d ${JSON_DIR} -t supplemental -r false -l modern | grep "Processing" # > /dev/null


clean:
	@echo "### Clean build and json directories"
	@rm -fR ${BUILD_DIR} ${JSON_DIR}

clean-downloads:
	@echo "### Clean download directory"
	@rm -fR ${DOWNLOAD_DIR}

all: json/main json/supplemental

.PHONY: all clean clean-downloads