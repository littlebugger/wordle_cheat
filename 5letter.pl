use strict;
use warnings;

use utf8;
use open ':std', ':encoding(UTF-8)';
use Encode qw( decode_utf8 );

use Getopt::Long;

use 5.010;

# Initialize variables to store arguments
my $dictionary_file;
my $excluded_letters_opt = '';
my $included_letters_opt = '';
my $pattern_opt = '.{5}';
my $help_opt;


my %letterfrequencies = (
    'а' => 0.0895527899848591,
    'о' => 0.0759776948927213,
    'е' => 0.075386831123749,
    'и' => 0.063340596033827,
    'у' => 0.0547435281952805,
    'р' => 0.0537169023966912,
    'л' => 0.0520550980464567,
    'т' => 0.049374053694745,
    'к' => 0.048074153403006,
    'н' => 0.0446988441227519,
    'с' => 0.0418626980316851,
    'м' => 0.0394549281731231,
    'в' => 0.0317589275822593,
    'п' => 0.0301488238118099,
    'д' => 0.0274456220687618,
    'б' => 0.0223789652498246,
    'я' => 0.0205989881457956,
    'ы' => 0.0201706119132907,
    'г' => 0.0179696443738691,
    'з' => 0.0172015214742051,
    'ю' => 0.0168987037926068,
    'х' => 0.0153698437903911,
    'ш' => 0.0150153255290077,
    'ч' => 0.0141881162524465,
    'й' => 0.0127257284242402,
    'ж' => 0.0121200930610436,
    'ь' => 0.0106281620443886,
    'ф' => 0.00728978174969534,
    'ц' => 0.00643302928468555,
    'ё' => 0.00604896783485358,
    'щ' => 0.004335462904834,
    'э' => 0.00228959710476753,
    'ъ' => 0.000369289855607666,
);

sub calculate_frequencies {
    my $all_letters_cnt = 0;

    map {
        map {
            $letterfrequencies{lc($_)}++;
            $all_letters_cnt++;
            # $letterfrequencies{lc($_)} += /[уеыаоэёяию]/i ? 2 : 1; # vowels get slighly higher in dispersion;
        } split '', $_;
    } @_;

    map { $letterfrequencies{$_} /= $all_letters_cnt } keys %letterfrequencies;
}

sub uniq {
    my %uniq;
    map { $uniq{$_}++ } @_;

    keys %uniq;
}

# Function to calculate diversity score of a word
sub diversion_factor {
    my ($word) = @_;

    my $score = 0;

    # Count different letters
    map { $score += $letterfrequencies{lc($_)} } uniq(split '', $word);

    return $score;
}

sub filter_words {
    my ($word, $excluded_letters, $included_letters, $pattern) = @_;

    filter_pattern($word, $pattern) &&
        filter_exluded($word, $excluded_letters) &&
        filter_included($word, $included_letters);
}

sub filter_pattern {
    my ($word, $pattern) = @_;

    $word =~ /^$pattern$/i;
}

sub filter_exluded {
    my ($word, $excluded_letters) = @_;

    $excluded_letters ? $word !~ /[$excluded_letters]/i : 1;
}

sub filter_included {
    my ($word, $included_letters) = @_;

    $included_letters ? $word =~ /[$included_letters]/i : 1;
}



# Function to display help instructions
sub display_help {
    print "Usage: perl script.pl -d <dictionary_file> [-e <excluded_letters>] [-p <pattern>] [-h]\n";
    print "-d <dictionary_file>: File containing the dictionary\n";
    print "-e <excluded_letters>: Letters to be excluded (optional)\n";
    print "-p <pattern>: Pattern of guessed letters (optional, default: any 5 characters)\n";
    print "-i <included_letters>: Letters to be included (optional)\n";
    print "-h: Display this message\n";
    exit;
}

# Get options from command line
GetOptions(
    'd=s' => \$dictionary_file, # -d for dictionary file
    'e:s' => \$excluded_letters_opt, # -e for excluded letters
    'p:s' => \$pattern_opt, # -p for pattern of guessed letters
    'i:s' => \$included_letters_opt, # -i for excluded letters
    'h' => \&display_help # -h for help
);


# Check if required options are provided
&display_help unless ($dictionary_file);


my ($excluded_letters, $included_letters, $pattern) =
    (decode_utf8($excluded_letters_opt), decode_utf8($included_letters_opt), decode_utf8($pattern_opt));
say "+|$included_letters| -|$excluded_letters| =|$pattern|";

# Read the dictionary file and store words in an array
open(my $fh, '<', $dictionary_file) or die "Can't open $dictionary_file: $!";
my @dictionary = <$fh>;
close($fh);

chomp(@dictionary);

# calculate_frequencies(@dictionary);

# my @sorted_keys = sort { $letterfrequencies{$b} <=> $letterfrequencies{$a} } keys(%letterfrequencies);
# map {
#     say "'$_' => $letterfrequencies{$_},";
# } @sorted_keys;


# Filter words based on excluded letters and pattern of guessed letters
my @sorted = sort {
    diversion_factor($b) <=> diversion_factor($a)
} grep {
    filter_words($_, $excluded_letters, $included_letters, $pattern);
} @dictionary;

say "@sorted";
