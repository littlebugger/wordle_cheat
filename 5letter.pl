use strict;
use warnings;
use Getopt::Long;

use utf8;
use open ':std', ':encoding(UTF-8)';
use Encode qw( decode_utf8 );

use 5.010;

# Initialize variables to store arguments
my $dictionary_file;
my $excluded_letters_opt = '';
my $pattern_opt = '.{5}';
my $help_opt;

# Function to calculate diversity score of a word
sub calculate_diversity {
    my ($word) = @_;

    my %count;
    my $score = 0;

    # Count different letters
    $count{lc($_)}++ for split('', $word);

    # Calculate score based on different letters with vowels weighted higher
    foreach my $letter (keys %count) {
        if ($letter =~ /[уеыаоэёяию]/i) {
            $score += 10; # Vowels: 10 points
        } else {
            $score += 1; # Consonants: 1 point
        }
    }

    return $score;
}

sub filer_words {
    my ($word, $excluded_letters, $pattern) = @_;

    return $word !~ /[$excluded_letters]/i && $word =~ /^$pattern$/i if $excluded_letters;
    $word =~ /^$pattern$/i;
}

# Function to display help instructions
sub display_help {
    print "Usage: perl script.pl -d <dictionary_file> [-e <excluded_letters>] [-p <pattern>] [-h]\n";
    print "-d <dictionary_file>: File containing the dictionary\n";
    print "-e <excluded_letters>: Letters to be excluded (optional)\n";
    print "-p <pattern>: Pattern of guessed letters (optional, default: any 5 characters)\n";
    print "-h: Display this message\n";
    exit;
}

# Get options from command line
GetOptions(
    'd=s' => \$dictionary_file, # -d for dictionary file
    'e:s' => \$excluded_letters_opt, # -e for excluded letters
    'p:s' => \$pattern_opt, # -p for pattern of guessed letters
    'h' => \&display_help # -h for help
);


# Check if required options are provided
&display_help unless ($dictionary_file);

# Read the dictionary file and store words in an array
open(my $fh, '<', $dictionary_file) or die "Can't open $dictionary_file: $!";
my @dictionary = <$fh>;
close($fh);

chomp(@dictionary);

my ($excluded_letters, $pattern) = (decode_utf8($excluded_letters_opt), decode_utf8($pattern_opt));
say "|$excluded_letters| |$pattern|";
# print scalar @dictionary, "\n";


# Filter words based on excluded letters and pattern of guessed letters
my @sorted = sort {
    calculate_diversity($b) <=> calculate_diversity($a)
} grep {
    filer_words($_, $excluded_letters, $pattern);
} @dictionary;

say "@sorted";
