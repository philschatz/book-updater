#!/bin/bash
cd "$(dirname "$0")/.." || exit 111
source ./script/bootstrap || exit 111

SOURCE=${1}
DEST=${2}
ROOT='.'
MIGRATE='./migrate'

EMPTY_BOOK=${ROOT}/book-template

CNXML_REPO=./subrepos/cnxml
CNXML_UTILS=./subrepos/rhaptos.cnxmlutils/rhaptos/cnxmlutils/xsl

JING_JAR_FILE="${CNXML_REPO}/cnxml/jing.jar"
TEXTBOOK_OR_CONTENTS_RNG_FILE="${CNXML_REPO}/textbook-html/textbook-html/book-or-contents.rng"

CNXML_TO_HTML_XSL=${CNXML_UTILS}/cnxml-to-html5.xsl
COLLXML_TO_HTML_XSL=${CNXML_UTILS}/collxml-to-html5.xsl

KRAMDOWN_CLEANUP_XSL=${MIGRATE}/kramdownify.xsl
POST_CLEANUP_XSL=${MIGRATE}/post-cleanup.xsl


function kramdownize {
  # 1. Clean up the HTML so the kramdown markup is cleaner (remove id's on paragraphs, convert <figure> to <img>)
  # 2. remove the XHTML namespace from elements so kramdown does not add it via {: xmlns="http://..."}
  # 3. disable line wrapping
  # 4. add the markdown="1" to figures so the contents is processed (BUG?)
  # 5. convert the <title> at the top of the file to a Liquid Template (for Jekyll)
  xsltproc ${KRAMDOWN_CLEANUP_XSL} - | xsltproc ${POST_CLEANUP_XSL} - | rbenv exec bundle exec kramdown --line-width 9999 -i html -o kramdown - | sed 's/ data-z-for-sed=""\}\ */\}\
\
/g' /dev/stdin | sed 's/<figure/<figure markdown="1"/g' /dev/stdin | sed 's/<page-title>/---\
title: "/g' /dev/stdin | sed 's/<\/page-title>/"\
layout: page\
---\
/g' /dev/stdin


  # TODO: Move inline MathML back to being inline
}


function kramdownize_html {
  # 1. Clean up the HTML so the kramdown markup is cleaner (remove id's on paragraphs, convert <figure> to <img>)
  # 2. remove the XHTML namespace from elements so kramdown does not add it via {: xmlns="http://..."}
  # 3. disable line wrapping
  # 4. add the markdown="1" to figures so the contents is processed (BUG?)
  # 5. convert the <title> at the top of the file to a Liquid Template (for Jekyll)
  xsltproc ${KRAMDOWN_CLEANUP_XSL} - | xsltproc ${POST_CLEANUP_XSL} -
}



echo "Copying all the Jekyll-specific templates"
cp -R ${EMPTY_BOOK}/_includes ${DEST}
cp -R ${EMPTY_BOOK}/_layouts ${DEST}
cp ${EMPTY_BOOK}/.gitignore ${DEST}/.gitignore
cp ${EMPTY_BOOK}/index.html ${DEST}/index.html
cp ${EMPTY_BOOK}/LICENSE.txt ${DEST}/LICENSE.txt
cp ${EMPTY_BOOK}/README.md ${DEST}/README.md


# # Copy resources (assume no name collisions)
# echo "Copying resources (assuming duplicate file names are OK)"
# mkdir -p ${DEST}/resources
#
# # cp ${SOURCE}/*/* ${DEST}/resources # "Args list is too long" commonly crops up
# find ${SOURCE} -type f -exec cp {} ${DEST}/resources \;
#
# rm ${DEST}/resources/*.cnxml



# Convert the ToC
echo "Building SUMMARY.md"
xsltproc ${COLLXML_TO_HTML_XSL} ${SOURCE}/collection.xml | kramdownize > ${DEST}/SUMMARY.md



mkdir -p ${DEST}/contents

echo "Building module .md files..."
# Loop through all the modules and convert them to markdown
for MODULE_NAME in $(cd ${SOURCE} && ls | grep '^m')
do
  # echo "Building ${MODULE_NAME}.md"
  MODULE_HTML=$(xsltproc ${CNXML_TO_HTML_XSL} ${SOURCE}/${MODULE_NAME}/index.cnxml)
  # print out the file for debugging
  echo "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><title></title></head>${MODULE_HTML}</html>" | xmllint --pretty 2 /dev/stdin > ${SOURCE}/${MODULE_NAME}/converted.xhtml
  # validate the XHTML
  # echo "Checking ${SOURCE}/${MODULE_NAME}/converted.xhtml"
  # java -jar "${JING_JAR_FILE}" "${TEXTBOOK_OR_CONTENTS_RNG_FILE}" ${SOURCE}/${MODULE_NAME}/converted.xhtml
  # VALIDATION_ERROR=$?
  # if [ ! ${VALIDATION_ERROR} -eq 0 ]; then
  #   echo "------------------------------"
  #   echo ""
  #   echo "ERROR_VALIDATING ${SOURCE}/${MODULE_NAME}/converted.xhtml"
  #   echo ""
  #   echo "------------------------------"
  #   exit 1
  # fi

  echo "<html xmlns=\"http://www.w3.org/1999/xhtml\">${MODULE_HTML}</html>" | kramdownize > ${DEST}/contents/${MODULE_NAME}.md
done

echo "Generating search index file"
node ${ROOT}/search-index.js ${DEST}/contents/ > ${DEST}/search-index.json
echo "Finished indexing ${DEST}"

# rm ${DEST}/search-index.json
