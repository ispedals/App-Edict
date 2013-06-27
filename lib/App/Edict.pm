package App::Edict;

# ABSTRACT: Functions to interact with lines from an Edict file
use v5.16;
use warnings;
use utf8::all;
use Text::Trim;
use Lingua::JA::Kana;
use List::MoreUtils qw(uniq);

# VERSION

=head1 SYNOPSIS

    use App::Edict;

    my $line='';
    print'Line contains priority word' if App::Edict::is_priority $line;
    my $field = App::Edict::get_word_field $line; #$field contains the word field of the from <word> [optional readings]
    
    my($word, $readings) = split( / /, $field, 2);
    my @readings = App::Edict::get_readings $line;
    print "$word has the readings: ";
    print for @readings;

    #get homophones
    use JSON;    
    my $fh = \*STDIN;
    my $priority_homophones = App::Edict::get_homophones $fh, 1;
    my $all_homophones = App::Edict::get_homophones $fh;
    print to_json $all_homophones; #homophones in JSON format;    


=head1 DESCRIPTION

This modules provides functions to interact with lines from an Edict file. This module does not export any modules.

=cut

## no critic (ProhibitEscapedMetacharacters, Capitalization)

=function is_priority

 Given an EDICT line, return whether it contains a priority word

=cut

sub is_priority {
    my $line = shift;
    return $line =~ /\(P\)/;
}

=function InKana

 Defines a Unicode named group for kana characters. Use like c<\p{InKana}>

=cut

sub InKana {
    return <<'END';
+utf8::InHiragana
+utf8::InKatakana
-utf8::IsCn
END
}

=function is_all_kana

 Given a word, returns whether it contains only kana characters

=cut

sub is_all_kana {
    my $word = shift;
    chomp $word;
    return $word =~ /^\p{InKana}+$/;
}

=function get_word_field

 Given an EDICT line, returns the field contain the word and any potential readings

=cut

sub get_word_field {
    my $line = shift;
    chomp $line;
    my ($field) = trim split /\//, $line, 2;
    return $field;
}

=function get_readings

 Given an EDICT line, returns the readings of the word in hiragana

=cut

sub get_readings {
    my $line = shift;
    chomp $line;
    my $field = get_word_field $line;

    # we assume that $field contains multiple kana-only words
    my $readings = $field;

    # however, if $field contains a [, it is of the form <word [readings]>
    # so we need to get the readings contained in the brackets
    if ( $field =~ /\[/ ) {
        my ( $word, $reading ) = trim split / /, $field, 2;
        $reading =~ s/\[//g;
        $reading =~ s/\]//g;
	$readings = $reading;
    }

# readings are separated by a ;, each reading is either in katakana or hiragana and
# may have various tags in parentheses

    # fix mistake in seperator for 1 entry;
    $readings =~ s/、/;/;

    # the following transformations:
    # * separates readings
    # * remove parenthetical tags
    # * convert katakana to hiragana
    # * change the ascii long vowel character to the kana character
    # * only keep kana readings
    # * ensure readings are unique

    return uniq grep { is_all_kana($_) }
      map            { s/〜/ー/gr }
      map { kata2hira $_ } map { s/\(.+?\)//gr } trim split /;/, $readings;
}

=function get_homophones

 Given a filehandle refering to an EDICT file, returns a hashref of the form <reading:[homophones with the reading]>.
 The readings are in hiragana. One can pass a second argument indicating whether only priority words should be considered.

=cut

sub get_homophones {
    my $fh            = shift;
    my $only_priority = shift;

    my $homophones;

    while (<$fh>) {
        chomp;
        next if $only_priority and not is_priority $_;
        for my $reading ( get_readings $_) {
            push @{ $homophones->{$reading} }, $_;
        }
    }

    my @not_homophones =
      grep { @{ $homophones->{$_} } < 2 } keys %{$homophones};
    delete @{$homophones}{@not_homophones};

    return $homophones;
}

1;
