#! /usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Carp::Always;

use FindBin;
# use lib "$FindBin::Bin";
# use Xyzzy;

use constant { TRUE => 1, FALSE => 0 };

# ------------------------------------------------------------------------
# Process command line
# ------------------------------------------------------------------------

sub usage {
  fprintf STDERR "Usage: $0 proteome.faa < all-peptides.txt > found-peptides.txt\n";
  exit(@_);
}

(scalar(@ARGV) == 1) || usage(1);

if ( $ARGV[0] eq "-h" ) { usage(0); }

my ($proteome_faa) = @ARGV;

# ------------------------------------------------------------------------
# read proteome
# ------------------------------------------------------------------------

my $n = 4;

my @proteome;
my %bins;

open(my $proteome_fh,"-|", "cat $proteome_faa | $FindBin::Bin/fasta2seq")
  || die "cannot open: <<$proteome_faa>>,";
my $size_proteome = 0;
while (<$proteome_fh>) {
  chomp;
  my $s = $_;
  push @proteome, $s;
  for (my $j=0; $j<=length($s)-$n; $j++) {
    my $key = substr($s,$j,$n);
    if (!defined($bins{$key})) {
      $bins{$key} = [];
    }
    push @{$bins{$key}}, $size_proteome;
  }
  $size_proteome++;
}
close $proteome_fh;
print STDERR "size of proteome: $size_proteome\n";

# ------------------------------------------------------------------------
# read peptides
# ------------------------------------------------------------------------

my $num_peptides = 0;
my $found_peptides = 0;

while (<STDIN>) {
  chomp;
  my $s = $_;
  $num_peptides++;
  (length($s) >= $n) || die;
  my $key = substr($s,0,$n);
  my $a = $bins{$key};
  if (!defined($a)) {
    next;
  }
  foreach my $i ( @$a ) {
    if (index($proteome[$i],$s) >= 0) {
      print $s,"\n";
      $found_peptides++;
      last;
    }
  }
}
print STDERR "num peptides: $num_peptides\n";
print STDERR "found peptides: $found_peptides\n";

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------



