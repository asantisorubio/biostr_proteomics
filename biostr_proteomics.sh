#!/bin/bash

# create a directory with the files/subdirectories included in this github repository
git clone https://github.com/asantisorubio/biostr_proteomics
cd biostr_proteomics

# download dataset from a human study registered in the PRIDE repository
wget -i data/PXD003557/ind_proteomes -P data/PXD003557

# download the human reference proteome from Uniprot
mkdir -p resources/proteome
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz -O resources/proteome/human.fasta.gz
gunzip resources/proteome/human.fasta.gz

# create a target-decoy database
decoypyrat resources/proteome/human.fasta -o resources/proteome/human.decoy.fasta --decoy_prefix DECOY
cat resources/proteome/human.fasta resources/proteome/human.decoy.fasta > resources/proteome/human.target-decoy.fasta

# search our input data (human study) against the target-decoy database
crux comet --output-dir output/comet --overwrite T --output_txtfile 0 data/PXD003557/*.mgf resources/proteome/human.target-decoy.fasta

# convert the pep.xml files into tsv files
chmod u+x psm-convert.sh
./psm-convert.sh

# merge the three tsv files into one to do the manual estimation of the FDR
cat output/comet/comet.guojiao2_2.target.tsv <(tail -n +2 output/comet/comet.guojiao2_3.target.tsv) <(tail -n +2 output/comet/comet.guojiao2_3.target.tsv) > output/comet/comet.guojiao2_234.target.tsv
# The mannual FDR calculation is in a folder inside ./output/

# calculate the FDR/q value using assign-confidence and percolator. 
crux assign-confidence --output-dir output/assign-confidence --overwrite T --decoy-prefix DECOY_ output/comet/*.pep.xml
crux percolator --output-dir output/percolator --overwrite T --decoy-prefix DECOY_ output/comet/*.pep.xml

# the comparison of the results is in the output folder.
