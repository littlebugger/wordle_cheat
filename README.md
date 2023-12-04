# wordle_cheat
Module to make wordle game easier.

Run: perl 5letter.pl -x ~/dict.utf-8.txt -e 'упериняктад' -p 'с...о' -i 'р'
     perl 5letter.pl -d ~/dict.utf-8.txt -e 'кшапиргмет' -i 'ол' -p '[^о][^о][^л][^о].'
You can use any kind of perl regexp in pattern.

The necessary dictionary must be available in utf8 encoidng.
You may find helpful: iconv -f WINDOWS-1251 -t UTF-8 dict.1251.txt > dict.utf-8.txt


