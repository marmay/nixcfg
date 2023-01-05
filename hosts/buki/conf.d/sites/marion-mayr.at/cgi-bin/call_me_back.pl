#!/usr/bin/perl

use warnings;
use strict;

use CGI;
my $query = CGI->new;

print 'Content-type: text/html', "\n\n";

my $PHONE_FILE = '/home/marion/phone_file';

my $from = "/";
my $phone_number = "";

eval {
  $from = $query->param( "from" ) || die "Missing parameter: from\n";
  $phone_number = $query->param( "phone_number" ) || die "Missing parameter: phone_number\n";
  my $current_time = localtime(time);
  open my $fh, '>>', $PHONE_FILE
    || die "Could not open file: $!\n";
  print $fh "Number: $phone_number ; ",
            "From page: $from ; ",
            "Entered at: ", $current_time, " ; ",
            "IP-Address: ", $query->remote_host(), "\n"
    || die "Could not write to file: $!\n";
  close $fh
    || die "Could not close file: $!\n";
};

if( $@ )
{
  print <<EOF;
<!DOCTYPE html>
<html>
<head>
  <title>Fehler beim Erbitten um Rückruf!</title>
  <meta charset="utf-8" />
</head>
<body>
  <p>Herzlichen Dank, dass Sie um einen Rückruf gebeten haben.</p>
  <p style="text-color: 'red';"><strong>
    Leider ist bei der Bearbeitung Ihrer Anfrage ein Fehler
    aufgetreten! Bitte versuchen Sie es - gegebenfalls etwas
    später - noch einmal oder vereinbaren Sie direkt unter
    <a href="mailto:kontakt\@marion-mayr.at">kontakt\@marion-mayr.at</a>
    einen Termin.</strong></p>
  <p>Sollte der Fehler wiederholt auftreten, würde ich mich
    freuen, wenn Sie mich bei der Behebung unterstützen würden,
    indem Sie folgende Fehlermeldung an
    <a href="mailto:office\@marion-mayr.at">office\@marion-mayr.at</a>
    senden würden: "$@".</p>
  <p>Bitte entschuldigen Sie die Unannehmlichkeiten. Ich hoffe, dass
    wird trotzdem in Kontakt kommen.</p>
  <p><a href="/page/$from">Zurück zur Homepage</a></p>
</body>
</html>
EOF
}
else
{
  print <<EOF;
<!DOCTYPE html>
<html>
<head>
  <title>Rückruf wurde erbeten ...</title>
  <meta http-equiv="refresh" content="10; URL=/page/$from" />
  <meta charset="utf-8" />
</head>
<body>
  <p>Herzlichen Dank! Ich rufe Sie sobald als möglich unter
    der Telefonnummer $phone_number zurück!</p>
  <p>Sie werden in Kürze zurückgeleitet.</p>
  <p>Sollten das nicht schnell genug gehen, so klicken Sie bitte <a href="/page/$from">hier</a>.</p>
</body>
</html>
EOF
}

