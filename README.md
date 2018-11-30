# Scipts used in Peritore2018

This repository contains several scripts that were used to compute some
of the datasets and results used in,

> Franklin Peritore-Galve, David Schneider, Yong Yang, Theodore
> Thannhauser, Christine Smart, Paul Stodghill.
> "Proteome profile and genome refinement of the tomato-pathogenic
> bacterium Clavibacter michiganensis subsp.  michiganensis". [full
> citation will appear upon publication]. 2018.

In order to run the `scripts/make-db-6ft`, the program `getorf` from
the [EMBOSS programs](https://www.ebi.ac.uk/Tools/emboss/) must be on
the path. Apart from that, these scripts use [Bash
shell](https://www.gnu.org/software/bash/),
[Perl](https://www.perl.org/), and standard UNIX programs. These have
been tested on [Ubuntu](https://www.ubuntu.com/) 18.04.1 LTS and
should run on Linux and other UNIX-esque systems (e.g., MacOS and
Windows with [Cygwin](https://www.cygwin.com/)).

## Manifest

#### `README.md`

This file

#### `LICENSE.txt`

Notice that this work is in the public domain.

#### `make-6ft-database.bash`

A Bash script to generate the six-frame translation (6FT) protein
database used for paper's the protogenomics analysis. The genomic
sequence (`data/genbank.fna`) is read and the `getorf` is used to
generate the database in FASTA format. The resulting database is
then compared against the actual 6FT database used for the paper
(`data/6ft.faa`) to ensure its correctness.

#### `make-database-stats.bash`

A Bash script used to generate certain statistics about various
datasets used in the paper (e.g., number of unique proteins in the
6FT database, number of tryptic peptides from the 6FT that map onto
the _Cmm_ 382 genome, and so on).

#### `make-database-stats.known.txt`

This file contains the actual statistics used in the paper. The last
step of `make-database-stats.bash` is to compare the generated
statistics against these results to ensure their correctness.

#### `data/`

Various input datasets. E.g., the 6FT database, the _Cmm_ 382
genomic sequence, etc.

#### `scripts/`

The scripts used to perform these computations.

## References

Franklin Peritore-Galve, David Schneider, Yong Yang, Theodore
Thannhauser, Christine Smart, Paul Stodghill.  "Proteome profile and
genome refinement of the tomato-pathogenic bacterium Clavibacter
michiganensis subsp.  michiganensis". [full citation will appear
upon publication]. 2018.


<!-- Local variables: -->
<!-- markdown-input-format: "gfm" -->
<!-- markdown-output-extension: "html" -->
<!-- End: -->
