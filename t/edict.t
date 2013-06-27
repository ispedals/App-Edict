#!perl
use v5.16;
use warnings;
use utf8::all;
use Test::More tests => 18;

use App::Edict;

my $line =
'刖 [げつ] /(n) (arch) (obsc) (See 剕) cutting off the leg at the knee (form of punishment in ancient China)/EntL2542160/';
ok( !App::Edict::is_priority($line),
    'is_priority() detected non-priority word' );

$line =
  '１０００円(P);千円 [せんえん] /(n) 1000 yen/(P)/EntL1388780X/';
ok( App::Edict::is_priority($line), 'is_priority() detected priority word' );

my $field = App::Edict::get_word_field($line);
is(
    $field,
    '１０００円(P);千円 [せんえん]',
    'get_word_field() parsed kanji [single reading] field'
);
my @readings = App::Edict::get_readings($line);
my @expected = ('せんえん');
is_deeply( \@readings, \@expected,
    'get_readings() parsed reading from kanji [single reading] field' );

$line = '々 [くりかえし;おなじ;おなじく;のま;どうのじてん] /(n) repetition of kanji (sometimes voiced)/EntL1000060X/';
$field = App::Edict::get_word_field($line);
is(
    $field,
    '々 [くりかえし;おなじ;おなじく;のま;どうのじてん]',
    'get_word_field() parsed kanji [multiple reading] field'
);

@readings = App::Edict::get_readings($line);
@readings = sort @readings;
@expected = sort qw/くりかえし おなじ おなじく のま どうのじてん/;
is_deeply(
    \@readings,
    \@expected,
    'get_readings() parsed reading from kanji [multiple reading] field'
);

$line = 'くりかえし /(n) repetition of kanji (sometimes voiced)/EntL1000060X/';
@readings = App::Edict::get_readings($line);
@expected = ('くりかえし');
is_deeply( \@readings, \@expected,
    'get_readings() parsed single hiragana word' );

$field = App::Edict::get_word_field($line);
ok( App::Edict::is_all_kana($field),
    'is_all_kana() identifed hiragana word correctly' );

$line = 'くりかえし;おなじ;おなじく;のま;どうのじてん /(n) repetition of kanji (sometimes voiced)/EntL1000060X/';
@readings = App::Edict::get_readings($line);
@readings = sort @readings;
@expected = sort qw/くりかえし おなじ おなじく のま どうのじてん/;
is_deeply(
    \@readings,
    \@expected,
    'get_readings() parsed multiple kana words'
);

$line = '＠ [アットマーク] /(n) "at" mark/EntL2020550X/';
@readings = App::Edict::get_readings($line);
@expected = ('あっとまーく');
is_deeply( \@readings, \@expected,
    'get_readings() converted katakana reading to hiragana' );

$line = 'アットマーク /(n) "at" mark/EntL2020550X/';

$field =  App::Edict::get_word_field($line);
ok( App::Edict::is_all_kana($field),
    'is_all_kana() identifed katakana word as kana' );

@readings = App::Edict::get_readings($line);
@expected = ('あっとまーく');
is_deeply( \@readings, \@expected,
    'get_readings() converted katakana word to hiragana' );

$line = '× [ばつ;ぺけ;ペケ] /(n) (1) (See 罰点) x-mark (used to indicate an incorrect answer in a test, etc.)/(2) (ペケ only) (uk) impossibility/futility/uselessness/EntL2197150X/';
@readings = App::Edict::get_readings($line);
@expected = qw/ばつ ぺけ/;
is_deeply( \@readings, \@expected,
    'get_readings() collapsed duplicate kana readings' );

$line = 'ばつ;ぺけ;ペケ /(n) (1) (See 罰点) x-mark (used to indicate an incorrect answer in a test, etc.)/(2) (ペケ only) (uk) impossibility/futility/uselessness/EntL2197150X/';
@readings = App::Edict::get_readings($line);
@expected = qw/ばつ ぺけ/;
is_deeply( \@readings, \@expected,
    'get_readings() collapsed duplicate kana words' );

use IO::String;
my $string = do { local $/; <DATA> };
my $io = IO::String->new($string);
my $all_homophones = App::Edict::get_homophones($io);
cmp_ok( keys %$all_homophones,
    '==', 1, 'get_homophones() correctly identified single homophone reading' );

@readings = @{$all_homophones->{'しょうれい'}};
@readings = sort @readings;
$io->setpos(0);
my @lines = (<$io>);
@expected = sort map {chomp; $_} @lines;
is_deeply( \@readings,
    \@expected, 'get_homophones() correctly identified homophones' );

$io->setpos(0);
my $priority_homophones = App::Edict::get_homophones($io, 1);
cmp_ok( keys %$priority_homophones, '==', 1,
'get_homophones() correctly identified single homophone reading when filtering non-priority words'
);

@readings = @{$priority_homophones->{'しょうれい'}};
@readings = sort @readings;
$io->setpos(0);
@lines = (<$io>)[ 0, 1 ];
@expected = sort map {chomp; $_} @lines;
is_deeply( \@readings, \@expected,
'get_homophones() correctly identified homophones when filtering non-priority words'
);

__DATA__
症例 [しょうれい] /(n) (medical) case/(P)
省令 [しょうれい] /(n) ministerial ordinance/(P)
詔令 [しょうれい] /(n) imperial edict
瘴癘 [しょうれい] /(n) tropical disease (e.g. malaria)