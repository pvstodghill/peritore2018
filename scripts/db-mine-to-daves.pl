#! /usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Carp::Always;

# use FindBin;
# use lib "$FindBin::Bin";
# use Xyzzy;

use constant { TRUE => 1, FALSE => 0 };

sub usage {
  print STDERR "Usage: $0 db_mine.fna db_mine.gff > db_daves.faa\n";
  exit(@_);
}
if ( defined($ARGV[0]) && $ARGV[0] eq "-h" ) {
  usage(0);
}
if ( scalar(@ARGV) != 2 ) {
  usage(1);
}

my ($db_faa,$db_gff) = @ARGV;

# ------------------------------------------------------------------------

use constant { NO_VALUE => ";no-value;" };

sub parse_gff_attributes {
  my ($raw_attributes) = @_;
  my $attributes = {};
  foreach my $key_val (split(/; */,$raw_attributes)) {
    my ($key,$val);
    if ( $key_val =~ /^([^=]+)=(.*)/ ) {
      ($key,$val) = ($1,$2);
    } else {
      ($key,$val) = ($key_val, NO_VALUE);
    }
    $attributes->{$key} = $val;
  }
  return $attributes;
}


my %accession_length;
my %orf_coords;

open(my $gff_fh,"<", $db_gff) || die "Cannot open <<$db_gff>>,";
while (<$gff_fh>) {
  chomp;
  if ( /^#/ ) {
    my @l = split;
    if ( $l[0] eq "##sequence-region" ) {
      my ($ignore,$accession,$lb,$ub) = @l;
      ($lb == 1) || die "lb=<<$lb>>,";
      $accession_length{$accession} = $ub;
    }
    next;
  }

  my ($seqname,$source,$feature,$start,$end,
      $score,$strand,$frame,$raw_attributes) = split(/\t/,$_);
  my $attributes = parse_gff_attributes($raw_attributes);
  my $name = $attributes->{name} || die "Cannot find orf name: <<$_>>,";
  my $length = $accession_length{$seqname} || die "Cannot find length of accession: <<$seqname>>,";
  if ( $start < 1 || $end < 1 || $length < $start || $length < $end ) {
    # ORF crosses origin. Dave did not include in 6FT database.
    $orf_coords{$name} = FALSE;
  } elsif ($strand eq "+") {
    $orf_coords{$name} = sprintf("%d..%d", $start, $end);
  } elsif ($strand eq "-") {
    $orf_coords{$name} = sprintf("complement(%d..%d)", $start, $end);
  } else {
    die "strand=<<$strand>>,";
  }
}
close $gff_fh;

# ------------------------------------------------------------------------

my $defline = undef;
my @seq = ();

sub emit {
  if (!defined($defline)) { return; }

  ($defline =~ /^>(.*)/) || die "defline=<<$defline>>,";
  my $name = $1;
  my $coords = $orf_coords{$name};
  (defined($coords)) || die "name=<<$name>>,";
  if ($coords && scalar(@seq) > 0) {
    $name =~ s/_([0-9]+$)/.$1/;
    print ">",$name," ",$name," ",$coords,"\n";
    print join("\n",@seq),"\n";
  } else {
    # ORF crosses origin. Dave did not include in 6FT database.
  }

  $defline = undef;
  @seq = ();
}


open(my $faa_fh, "<", $db_faa) || die "Cannot open <<$db_faa>>,";
while (<$faa_fh>) {
  chomp;
  if ( /^>/ ) {
    emit();
    $defline = $_;
  } else {
    push @seq, $_;
  }
}
emit();
close $faa_fh;

