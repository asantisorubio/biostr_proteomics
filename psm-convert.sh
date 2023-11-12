#!/bin/bash

files=$(echo output/comet/*.pep.xml)
for i in $files ; do
	crux psm-convert --output-dir output/comet/ --overwrite T $i tsv
	mv output/comet/psm-convert.txt ${i%.pep.xml}.tsv
done
