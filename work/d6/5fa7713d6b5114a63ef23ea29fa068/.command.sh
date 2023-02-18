#!/bin/bash -ue
wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=U81989&rettype=fasta&retmode=text" -O U81989.fasta
