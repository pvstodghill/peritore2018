#! /bin/bash -x

export PATH=/usr/bin:/bin
export PERL5LIB=

if ( type -p getorf > /dev/null ) ; then
   : ok
else
    echo 1>&2 getorf is missing. try installing EMBOSS.
    exit 1
fi


rm -rf work
mkdir work

./scripts/make-db-6ft -f work/foo.faa -g work/foo.gff -s $[3*16] data/genbank.fna
./scripts/db-mine-to-daves.pl work/foo.faa work/foo.gff > work/bar.faa

export LANG=C

comm -3 \
     <(cat data/6ft.faa | ./scripts/fasta2seq |sort) \
     <(cat work/bar.faa | ./scripts/fasta2seq | sort)
