use strict;
use argola;
use wraprg;

my $cmdon;
my $mintm = 1;
my $maxtm;
my $nowo;
my $endo;
my $larmo;
my $volum;
my $dura_min = 10;
my $dura_sec = 0;
my $afta_min = 20;
my $afta_sec = 0;
my $aft_end;
my $afta_limit;
my $asflag = '-d'; # By default display stays awake

$afta_limit = ( 2 > 1 );


sub opto__xscr_do {
  # Just system stays awake
  $asflag = '-i';
} &argola::setopt('-xscr',\&opto__xscr_do);

sub opto__scr_do {
  # Display stays awake
  $asflag = '-d';
} &argola::setopt('-scr',\&opto__scr_do);

sub opto__tm_do {
  $dura_min = &argola::getrg();
  $dura_sec = &argola::getrg();
} &argola::setopt('-tm',\&opto__tm_do);

sub opto__tma_do {
  $afta_min = &argola::getrg();
  $afta_sec = &argola::getrg();
  $afta_limit = ( 2 > 1 );
} &argola::setopt('-tma',\&opto__tma_do);

sub opto__u_do {
  $afta_limit = ( 1 > 2 );
} &argola::setopt('-u',\&opto__u_do);

sub opto__xu_do {
  $afta_limit = ( 2 > 1 );
} &argola::setopt('-xu',\&opto__xu_do);



&argola::help_opt('--help','help-file.nroff');


&argola::runopts();




{
  my $lc_a;
  my $lc_b;
  my @lc_c;
  $lc_a = `chobakwrap -rloc`; chomp($lc_a);
  $lc_b = `ls -1d $lc_a/so*/*bell-medit*.mp3`;
  @lc_c = split(/\n/,$lc_b);
  $larmo = $lc_c[0];
}

$nowo = `date +%s`; chomp($nowo);
$endo = $nowo;
$endo = int($endo + 0.2 + ( 60 * $dura_min ) );
$endo = int($endo + 0.2 + ( 1 * $dura_sec ) );

$maxtm = int(($mintm * 2) + 5.2);


# Generating First-Round Caffeination Command:
$cmdon = 'caffeinate ' . $asflag . ' -t ' . $maxtm;
$cmdon .= ' &bg';
$cmdon = '( ' . $cmdon . ' )';
$cmdon .= ' > /dev/null 2> /dev/null';


while ( $nowo < $endo )
{
  #system("date");
  system("echo",&vando(int(($endo - $nowo) + 0.2)));
  
  system($cmdon);
  sleep($mintm);
  
  $nowo = `date +%s`; chomp($nowo);
}


# Generating Second-Round Caffeination Command:
$cmdon = 'caffeinate ' . $asflag . ' -t 30';
$cmdon .= ' &bg';
$cmdon = '( ' . $cmdon . ' )';
$cmdon .= ' > /dev/null 2> /dev/null';


$aft_end = `date +%s`; chomp($aft_end);
$aft_end = int(($aft_end + ($afta_min * 60)) + 0.2);
$aft_end = int(($aft_end + $afta_sec) + 0.2);

$volum = 0.001;
while ( 2 > 1 )
{
  my $lc_cm;
  $lc_cm = "afplay -v " . $volum . " $larmo &bg";
  $lc_cm = "( " . $lc_cm . " ) > /dev/null 2> /dev/null";
  
  $nowo = `date +%s`; chomp($nowo);
  if ( $afta_limit )
  {
    if ( $nowo > $aft_end ) { exit(0); }
  }
  
  
  
  system("echo",&vando(int(($nowo - $endo) + 0.2)) . ": Current Volume: " . $volum . ":");
  
  system($lc_cm);
  system($cmdon);
  sleep(3);
  
  $volum = ( $volum * 1.02 );
  if ( $volum > 1 ) { $volum = 1; }
}



sub vando {
  my $lc_ret;
  my $lc_itm;
  my $lc_src;
  $lc_src = $_[0];
  $lc_ret = "";
  
  $lc_itm = &glean(3600,$lc_src);
  if ( $lc_itm < 9.5 ) { $lc_ret .= '0'; }
  $lc_ret .= $lc_itm;
  
  $lc_ret .= ':';
  
  $lc_itm = &glean(60,$lc_src);
  if ( $lc_itm < 9.5 ) { $lc_ret .= '0'; }
  $lc_ret .= $lc_itm;
  
  $lc_ret .= ':';
  
  $lc_itm = $lc_src;
  if ( $lc_itm < 9.5 ) { $lc_ret .= '0'; }
  $lc_ret .= $lc_itm;
  
  return $lc_ret;
}

sub glean {
  my $lc_a;
  my $lc_b;
  my $lc_c;
  $lc_a = $_[1] % $_[0];
  $lc_b = int(($_[1] - $lc_a) + 0.2);
  $lc_c = int(0.2 + ( $lc_b / $_[0] ) );
  $_[1] = $lc_a;
  return $lc_c;
}

