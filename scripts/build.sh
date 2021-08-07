#!/bin/bash

set -e
set -o pipefail

# constants
THESIS_DOCUMENT_ROOT=Sample-Project_Your-Name
THESIS_COVER_ROOT=cover
BIBLIOGRAPHY=bibliography.bib
CITATION_STYLE=citation-style.csl
LATEX_TEMPLATE=util/template.latex

# enter source directory
pushd /source

# clear outputs
mkdir -p build
rm -rf build/* || true

# create the cover page markdown
cat cover/cover-page.md >> build/$THESIS_COVER_ROOT.md
cat util/pagebreak.md >> build/$THESIS_COVER_ROOT.md

# append each section to the thesis markdown
for FILENAME in `ls *.md | sort`; do
  echo Appending file: $FILENAME

  cat util/blank.md >> build/$THESIS_DOCUMENT_ROOT.md
  cat util/pagebreak.md >> build/$THESIS_DOCUMENT_ROOT.md
  cat $FILENAME >> build/$THESIS_DOCUMENT_ROOT.md
done

# convert cover to PDF
echo Building cover page PDF...
pandoc \
  build/$THESIS_COVER_ROOT.md \
  -o build/$THESIS_DOCUMENT_ROOT.cover.pdf

# convert thesis to PDF
echo Building document body PDF...
pandoc \
  --standalone \
  --number-sections \
  --table-of-contents \
  -f markdown+tex_math_dollars \
  --template=$LATEX_TEMPLATE \
  --citeproc \
  --csl=util/$CITATION_STYLE \
  --bibliography=$BIBLIOGRAPHY \
  build/$THESIS_DOCUMENT_ROOT.md \
  -o build/$THESIS_DOCUMENT_ROOT.body.pdf

# combine cover and thesis into main document
echo Combining documents...
pdfunite \
  build/$THESIS_DOCUMENT_ROOT.cover.pdf \
  build/$THESIS_DOCUMENT_ROOT.body.pdf \
  build/$THESIS_DOCUMENT_ROOT.pdf

# return to initial directory
popd

# describe output
echo "Word counts:"
wc -w /source/*.md
echo "Output document: source/build/$THESIS_DOCUMENT_ROOT.pdf"
