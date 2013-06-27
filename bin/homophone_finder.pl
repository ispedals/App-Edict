#!perl
## no critic
# PODNAME: homophone_finder
# ABSTRACT:  Finds homophones in an EDICT file
use v5.16;
use warnings;
use utf8::all;

use App::Edict;
use JSON;

use Getopt::Long;
use Pod::Usage;

# VERSION

my $man  = 0;
my $help = 0;
my $only_priority;
GetOptions(
    'help|?'        => \$help,
    man             => \$man,
    'only_priority' => \$only_priority,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

say to_json App::Edict::get_homophones( \*STDIN, $only_priority ),
  { pretty => 1 };

=head1 SYNOPSIS

homophone_finder.pl [options] [file]


Options:
    -help brief help message
    -man full documentation
    -only_priority whether to only find priority homophones

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-only_priority>

whether to only find priority homophones

=back

=head1 DESCRIPTION

B<This program> will read the given EDICT file from STDIN and print a JSON representation of the homophones contained in the file in the form <reading:[lines from the EDICT file with the same reading]>. The reading will be in hiragana.

=cut
