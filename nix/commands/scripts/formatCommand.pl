use strict;
use warnings;

my ($nameWidth, $helpWidth, $helpHeight, $name, $help) = @ARGV;

my $format;
my $delimiter = $help eq "" ? "" : "-";

sub getFormat {    
    my $line1 = "  @@{['<' x $nameWidth]}@|^@{['<' x $helpWidth]}";
    my $line2 = "\$name, \$delimiter, \$help";
    my $line3 = "~@{[' ' x ($nameWidth + 4)]}^@{['<' x $helpWidth]}";
    my $line4 = "\$help";

    $format = <<EOF;
format FORMAT_COMMAND =
$line1
$line2
@{["$line3\n$line4\n" x ($helpHeight - 1)]}.
EOF
}

getFormat();

eval($format);

select(STDOUT);
$~ = "FORMAT_COMMAND";
write;