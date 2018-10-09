#! /bin/bash

export PATH=/usr/bin:/bin
export PERL5LIB=

export LANG=C

set -e

MIN_LENGTH=6

rm -rf work
mkdir work

NAME=genbank
GENOME=data/genbank.fna
PROTEOME=data/genbank.faa
SIXFT=data/6ft.faa

TPROTEOME=work/tproteome.faa
NOVEL=work/novel.faa
TNOVEL=work/tnovel.faa
TSIXFT=work/t6ft.faa

cat  ${SIXFT} \
    | tr '\n' '&' | sed -e 's/&>/\n>/g' \
    | fgrep -f data/novel-uuids.txt \
    | sed -e 's/&/\n/g' \
	  > ${NOVEL}

./scripts/trypsin-digest.pl $MIN_LENGTH < ${PROTEOME} > ${TPROTEOME}
./scripts/trypsin-digest.pl $MIN_LENGTH < ${NOVEL} > ${TNOVEL}
./scripts/trypsin-digest.pl $MIN_LENGTH < ${SIXFT} > ${TSIXFT}

# ------------------------------------------------------------------------

function genome_seqs {
    cat ${GENOME} | ./scripts/fasta2seq
}

function count_all_seqs {
    wc -l
}

function count_unique_seqs {
    sort -u | wc -l
}

function size_all_seqs {
    ./scripts/strings-length | ./scripts/profile-reduce + 0
}

function size_unique_seqs {
    sort -u | ./scripts/strings-length | ./scripts/profile-reduce + 0
}

echo "# - size of genome"
echo -n 'replicons: '
genome_seqs | count_all_seqs
echo -n 'based: '
genome_seqs | size_all_seqs

# ------------------------------------------------------------------------

function sixft_seq {
    cat ${SIXFT} | ./scripts/fasta2seq
}

echo "# - number of \"proteins\" in 6ft"
sixft_seq | count_all_seqs
echo "#   + number of unique"
sixft_seq | count_unique_seqs

# ------------------------------------------------------------------------

echo "# - number of aa' in 6ft (average length)"
sixft_seq | size_all_seqs
echo "#   + number of aa' in unqiue"
sixft_seq | size_unique_seqs

# ------------------------------------------------------------------------

function tsixft_seq {
    cat ${TSIXFT} | ./scripts/fasta2seq
}

echo "# - number of tryptic peptides in 6ft (t6ft)"
tsixft_seq | count_all_seqs
echo "#   + number of unique tryptic peptides"
tsixft_seq | count_unique_seqs

# ------------------------------------------------------------------------

echo "# - number of aa' in t6ft"
tsixft_seq | size_all_seqs
echo "#   + number of aa' in unqiue"
tsixft_seq | size_unique_seqs

# ------------------------------------------------------------------------

function tproteome_seq {
    cat ${TPROTEOME} | ./scripts/fasta2seq
}

echo "# - number of t6ft that map to ${NAME}"
tproteome_seq | fgrep -f <(tsixft_seq | sort -u) | count_all_seqs
echo "#   + number of unique t6ft that map to ${NAME}"
tproteome_seq | fgrep -f <(tsixft_seq | sort -u) | count_unique_seqs

# ------------------------------------------------------------------------

# and what proportion [of 6ft peptides] maps to putative novel
# coding regions)

function tnovel_seq {
    cat ${TNOVEL} | ./scripts/fasta2seq
}

echo "# - number of t6ft that map to novel"
tnovel_seq | fgrep -f <(tsixft_seq | sort -u) | count_all_seqs
echo "#   + number of unique t6ft that map to novel"
tnovel_seq | fgrep -f <(tsixft_seq | sort -u) | count_unique_seqs

# ------------------------------------------------------------------------

function to_peptides {
    fgrep 'peptide="' | sed -e 's/.*peptide="//' -e 's/".*//'
}

echo ''
echo '# total number of peptides identified in the high-value dataset (does not include modifications)'
echo ''

gzip -dc data/peptides_hv.gff.gz | to_peptides | wc -l

echo ''
echo '# total number of **unique** peptides identified in the high-value dataset'
echo ''

gzip -dc data/peptides_hv.gff.gz | to_peptides | sort -u > work/peptides.txt
cat work/peptides.txt | wc -l 

echo ''
echo '# how many (unique hv peptides) mapped to '${NAME}' CDSs'
echo ''

cat work/peptides.txt | ./scripts/search.pl ${PROTEOME} > work/proteome_cds_peptides.txt

echo ''
echo '# how many (unique hv peptides) mapped to novel CDSs'
echo ''

cat work/peptides.txt | ./scripts/search.pl work/novel.faa > work/novel_cds_peptides.txt

echo ''
echo '# peptides mapping to both '${NAME}' and novel CDSs (should be 0!)'
echo ''

comm -12 work/proteome_cds_peptides.txt work/novel_cds_peptides.txt > work/proteome+novel_cds_peptides.txt
cat work/proteome+novel_cds_peptides.txt | wc -l


