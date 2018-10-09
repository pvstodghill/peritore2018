#! /usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Carp::Always;

# use FindBin;
# use lib "$FindBin::Bin";
# use Xyzzy;

use constant { TRUE => 1, FALSE => 0 };

if (defined($ARGV[0]) && $ARGV[0] eq "-h") {
  print STDERR "Usage: $0 [min_length] < proteins.faa > tryptic-peptides.faa\n";
  print STDERR "min_length default is 6\n";
  exit(1);
}

my ($min_length) = @ARGV;
if (!defined($min_length)) {
  $min_length = 6;
}

my $num_peptides = 0;
my %peptides;

my $seq;

sub notice {
  my ($s) = @_;
  if (length($s) < $min_length) {
    return;
  }
  if ( !defined($peptides{$s}) ) {
    $peptides{$s} = 0;
  }
  $peptides{$s}++;
  $num_peptides++;
}

sub digest {
  if (!defined($seq)) {
    return;
  }

  my @partial_peptides;
  while ( $seq =~ /^([^KR]*[KR])(.*)/ ) {
    push @partial_peptides, $1;
    $seq = $2;
  }
  if ( $seq ne "" ) {
    push @partial_peptides, $seq;
  }

  if ( scalar(@partial_peptides) == 0 ) {
    die "No peptides found,";
  }

  my @tryptic_peptides;

  push @tryptic_peptides, (shift @partial_peptides);
  foreach my $peptide ( @partial_peptides ) {
    if ($peptide =~ /^P/) {
      $tryptic_peptides[-1] .= $peptide;
    } else {
      push @tryptic_peptides, $peptide;
    }
  }

  foreach my $peptide (@tryptic_peptides) {
    notice($peptide);
  }

  $seq = undef;
}

while (<STDIN> ) {
  chomp;
  if ( /^>/ ) {
    digest();
  } elsif ( /^ *#/ ) {
    digest();
  } elsif ( /^ *$/ ) {
    digest();
  } else {
    if (!defined($seq)) {
      $seq = "";
    }
    $seq .= uc($_);
  }
}

($num_peptides < 1000000) || die;
my $index_format = "x%06d";

my $i = 0;
foreach my $peptide (sort(keys(%peptides))) {
  for (my $j=0; $j<$peptides{$peptide}; $j++) {
    print ">",sprintf($index_format,$i),"\n";
    print $peptide,"\n";
    $i++;
  }
}
