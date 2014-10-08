#!/usr/bin/perl

use strict;
use warnings;

my $usage = qq(
    solution.pl inputN.txt

);

my $input_file = $ARGV[0] || die $usage;
my $total_cost = 0;
my $total_sales_taxes = 0;
my $import_duty_rate = 5; # percentage
my $basic_tax_rate = 10; # percentage
my @output_rows;

#----------------------------------------------------------------------------- 
# Read input file.

open my $fh, '<', $input_file or die "cannot open $input_file: $!";
my @input_rows = <$fh>;

#----------------------------------------------------------------------------- 
# Parse input rows.

for my $input_row (@input_rows) {
  chomp $input_row;

  $input_row =~ /(.*) at (.*)/;
  my $item = $1;
  my $price = $2;

  my $tax = 0;
  my $tax_rate = 0;

  $tax_rate += $basic_tax_rate if not tax_exempt($item);
  $tax_rate += $import_duty_rate if is_imported($item);

  $tax = compute_tax($price, $tax_rate);

  $price += $tax;

  $total_sales_taxes += $tax;
  $total_cost += $price;

  my $output_row = sprintf "%s: %.2f", $item, $price;
  push @output_rows, $output_row;
}

#----------------------------------------------------------------------------- 
# Add totals.

my $sales_taxes_row = sprintf "Sales taxes: %.2f", $total_sales_taxes;
push @output_rows, $sales_taxes_row;

my $total_cost_row = sprintf "Total: %.2f", $total_cost;
push @output_rows, $total_cost_row;

#----------------------------------------------------------------------------- 
# Print output.

print "$_\n" for @output_rows;

#----------------------------------------------------------------------------- 
# Functions used.

sub compute_tax {
  my ($price, $tax_rate) = @_;

  my $import = $price * $tax_rate / 100;

  return rounded_up($import);
}

sub rounded_up {
  my $import = shift;

  my $rounded_import = int($import * 100);

  my $rounded_import_mod_5 = $rounded_import % 5;

  if ($rounded_import_mod_5 != 0) {
    $rounded_import += (5 - $rounded_import_mod_5);
  }

  $rounded_import /= 100;

  return $rounded_import;
}

sub is_imported { shift =~ /imported/ }

sub tax_exempt {
  my $item = shift;

  return 1 if is_book($item);
  return 1 if is_food($item);
  return 1 if is_medical($item);

  return 0;
}

sub is_book { shift =~ /book/ }

sub is_food { shift =~ /chocolate|apple|banana/ }

sub is_medical { shift =~ /pill/ }

