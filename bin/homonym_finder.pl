#!perl
## no critic
# PODNAME: homonym_finder
# ABSTRACT:  Finds homonyms in an EDICT file
use v5.16;
use warnings;
use utf8::all;
use autodie;

use Text::Trim;
use JSON;
use File::Slurp;
use App::Edict;

# VERSION

use Getopt::Long;
use Pod::Usage;

my $man  = 0;
my $help = 0;
my $generate_homophones;
GetOptions(
    'help|?'              => \$help,
    man                   => \$man,
    'generate_homophones' => \$generate_homophones,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

my $homophones;
if ( @ARGV == 0 && !-t STDIN && $generate_homophones ) {
    $homophones = App::Edict::get_homophones \*STDIN;
}
elsif ( @ARGV == 0 ) {
    pod2usage("$0: No homophone file given");
}
else {
    die "Invalid filename $ARGV[0]" unless -e $ARGV[0];
    $homophones = decode_json read_file $ARGV[0];
}

while ( my ( $reading, $words ) = each %$homophones ) {
    my %seen_kanaless_words;

    for (@$words) {
        my ($field) = trim split( /\//, $_, 2 );
        my ($word) = map { s/\P{CJK_Unified_Ideographs}//gr } trim split / /,
          $field, 2;
        $seen_kanaless_words{$word}++ if length $word;
    }

    # more than one word with non-identical kanji
    if ( keys %seen_kanaless_words != 1 ) {
        delete $homophones->{$reading} and next;
    }

  # only saw the same kanji once (meaning that the other matches were kana only)
    elsif ( ( values %seen_kanaless_words )[0] == 1 ) {
        delete $homophones->{$reading} and next;
    }
}

print to_json( $homophones, { pretty => 1 } );

=head1 SYNOPSIS

homonym_finder.pl [options] [file]


Options:
    -help brief help message
    -man full documentation
    -generate_homophones whether to generate the homophones from the given EDICT file

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-generate_homophones>

If set, the given file will be used to generate the homophones. If this flag is not set, it is assumed the file passed is a JSON file of the form <reading:[lines from the EDICT file that have the same reading]> with reading in hiragana.

=back

=head1 DESCRIPTION

B<This program> will either take the given file of homophones or generate a list of homophones and print a JSON representation of the homonyms in the EDICT file of the form <reading:[lines that are homonyms]>.

=cut
