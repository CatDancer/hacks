(load "perl.arc")

(pr "can pass all 256 byte values unchanged to perl: ")

(= allbytes* (apply mz:bytes (range 0 255)))

(= program (bytestring "
use strict;

sub fail {
    print \"fail\\n\";
    exit 1;
}

my $a = " (strperl allbytes*) ";

# fail unless length($a) == 256;

for (my $i = 0;  $i < 5;  ++$i) {
    fail unless ord(substr($a, $i, 1)) == $i;
}

print \"ok\\n\";
"))

(fromstring program (system "perl"))

