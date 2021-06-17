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
cat 00*.md >> build/$THESIS_COVER_ROOT.md
cat 00*.md >> build/$THESIS_COVER_ROOT.formatted.md
cat util/pagebreak.md >> build/$THESIS_COVER_ROOT.formatted.md

# append each section to the thesis markdown
for I in 0{1..8}; do
  cat util/blank.md >> build/$THESIS_DOCUMENT_ROOT.md
  cat util/pagebreak.md >> build/$THESIS_DOCUMENT_ROOT.formatted.md

  for FILENAME in `ls $I*.md | sort`; do
    # FILENAME=$I*.md
    cat $FILENAME >> build/$THESIS_DOCUMENT_ROOT.md
    cat $FILENAME >> build/$THESIS_DOCUMENT_ROOT.formatted.md
  done
done

# convert cover to PDF
pandoc \
  build/$THESIS_COVER_ROOT.formatted.md \
  -o build/$THESIS_DOCUMENT_ROOT.cover.pdf

# convert thesis to PDF
pandoc \
  --standalone \
  --number-sections \
  --table-of-contents \
  -f markdown+tex_math_dollars \
  --template=$LATEX_TEMPLATE \
  --citeproc \
  --csl=util/$CITATION_STYLE \
  --bibliography=$BIBLIOGRAPHY \
  build/$THESIS_DOCUMENT_ROOT.formatted.md \
  -o build/$THESIS_DOCUMENT_ROOT.body.pdf

# combine cover and thesis into main document
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
