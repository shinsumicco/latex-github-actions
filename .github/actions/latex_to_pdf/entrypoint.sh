#!/bin/sh

# build PDF
STEM_FILENAME=$(echo ${LATEX_FILENAME} | sed "s/\.[^\.]*$//")
DVI_FILENAME=${STEM_FILENAME}.dvi
platex -synctex=1 -halt-on-error -interaction=nonstopmode -file-line-error -kanji=utf8 ${LATEX_FILENAME}
pbibtex -kanji=utf8 ${STEM_FILENAME}
platex -synctex=1 -halt-on-error -interaction=nonstopmode -file-line-error -kanji=utf8 ${LATEX_FILENAME}
platex -synctex=1 -halt-on-error -interaction=nonstopmode -file-line-error -kanji=utf8 ${LATEX_FILENAME}
dvipdfmx ${DVI_FILENAME}
