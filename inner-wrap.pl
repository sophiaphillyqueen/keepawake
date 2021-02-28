use strict;
use argola;
use wraprg;

my $cmdon;
my $mintm = 1;
my $maxtm;
my $nowo;
my $endo;
my $larmo = 'x';
my $volum;
my $dura_min = 10;
my $dura_sec = 0;
my $afta_min = 20;
my $afta_sec = 0;
my $aft_end;
my $afta_limit;
my $asflag = '-full'; # By default display stays awake
my $incresa = 1.02;
my $maxvol = 1;
my $goal_f_on = 0;
my $goal_f_at;
my $goal_f_is;
my $prefixar = '';
my $vibraton = 5;
my $minorivolume = 0.0001;
my $orivolume = 0.001;
my @haltfiles = ();
my $alarminterval = 3;

$afta_limit = ( 2 > 1 );

sub opto__rate_do {
  my $lc_a;
  $lc_a = ( 1 + ( &argola::getrg() / 100 ) );
  if ( $lc_a > 2 ) { die "\nFATAL ERROR: keepawake -rate option may not exceed 100.\n\n"; }
  if ( $lc_a < 1 ) { die "\nFATAL ERROR: keepawake -rate option may not be less than 0.\n\n"; }
  $incresa = $lc_a;
} &argola::setopt('-rate',\&opto__rate_do);

sub opto__xscr_do {
  # Just system stays awake
  $asflag = '-xscr1';
} &argola::setopt('-xscr',\&opto__xscr_do);

sub opto__max_do {
  my $lc_a;
  $lc_a = ( &argola::getrg() / 100 );
  if ( $lc_a > 1 ) { die "\nFATAL ERROR: keepawake -max option may not exceed 100.\n\n"; }
  if ( $lc_a < 0 ) { die "\nFATAL ERROR: keepawake -max option may not be less than 0.\n\n"; }
  $maxvol = $lc_a;
} &argola::setopt('-max',\&opto__max_do);

sub opto__scr_do {
  # Display stays awake
  $asflag = '-full';
} &argola::setopt('-scr',\&opto__scr_do);

sub opto__pfx_do {
  $prefixar = &argola::getrg();
} &argola::setopt('-pfx',\&opto__pfx_do);

sub opto__tm_do {
  $dura_min = &argola::getrg();
  $dura_sec = &argola::getrg();
} &argola::setopt('-tm',\&opto__tm_do);

sub opto__tmh_do {
  my $lc_a;
  $lc_a = &argola::getrg();
  $lc_a = int( ( $lc_a * 60 ) + &argola::getrg() + 0.2 );
  $dura_min = $lc_a;
  $dura_sec = &argola::getrg();
} &argola::setopt('-tmh',\&opto__tmh_do);

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

sub opto__ori_do {
  $orivolume = (&argola::getrg() / 100);
  if ( $orivolume < $minorivolume ) { $orivolume = $minorivolume; }
  if ( $orivolume > 1 ) { $orivolume = 1; }
} &argola::setopt('-ori',\&opto__ori_do);

sub opto__wf_do {
  $goal_f_at = &argola::getrg();
  $goal_f_is = &argola::getrg();
  $goal_f_on = 10;
} &argola::setopt('-wf',\&opto__wf_do);

sub opto__halt_do {
  @haltfiles = (@haltfiles,&argola::getrg());
} &argola::setopt('-halt',\&opto__halt_do);

sub opto__larm_do {
  $larmo = &argola::getrg();
} &argola::setopt('-larm',\&opto__larm_do);

sub opto__larmivl_do {
  $alarminterval = &argola::getrg();
  if ( $alarminterval < 2 ) { $alarminterval = 2; }
} &argola::setopt('-larmivl',\&opto__larmivl_do);

sub opto__rjlarmivl_do {
  # Changes the alarm frequency (just like '-larmivl' does)
  # only this one also auto-adjusts the volime-increase rate to
  # compensate.
  my $lc_oldivl;
  my $lc_newinc;
  $lc_oldivl = $alarminterval;
  $alarminterval = &argola::getrg();
  if ( $alarminterval < 2 ) { $alarminterval = 2; }
  $lc_newinc = ( $incresa ** ( $alarminterval / $lc_oldivl ) );
  $incresa = $lc_newinc;
} &argola::setopt('-rjlarmivl',\&opto__rjlarmivl_do);



&argola::help_opt('--help','help-file.nroff');


&argola::runopts();




if ( $larmo eq 'x' ) {
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
$cmdon = 'chobakwrap-caff ' . $asflag . ' -sec ' . $maxtm;
$cmdon .= ' &bg';
$cmdon = '( ' . $cmdon . ' )';
$cmdon .= ' > /dev/null 2> /dev/null';


while ( $nowo < $endo )
{
  #system("date");
  system("echo", $prefixar . &vando(int(($endo - $nowo) + 0.2)));
  
  system($cmdon);
  sleep($mintm); &haltonic();
  
  $nowo = `date +%s`; chomp($nowo);
  &engoaler();
}

sub engoaler {
  my $lc_cm;
  my $lc_rs;
  if ( $goal_f_on < 5 ) { return; }
  if ( ! ( -f $goal_f_at ) ) { exit(0); }
  $lc_cm = 'cat ' . &wraprg::bsc($goal_f_at);
  $lc_rs = `$lc_cm`; chomp($lc_rs);
  if ( $lc_rs ne $goal_f_is ) { exit(0); }
}

sub haltonic {
  my $lc_eacho;
  my $lc_counto;
  $lc_counto = 0;
  foreach $lc_eacho (@haltfiles)
  {
    $lc_counto = int($lc_counto + 1.2);
    if ( -f $lc_eacho )
    {
      while ( -f $lc_eacho )
      {
        #system("echo",("HALTED BY: " . $lc_eacho));
        system("echo",$prefixar . ': HALT ' . $lc_counto . ':');
        sleep(3);
      }
    }
  }
}


# Generating Second-Round Caffeination Command:
$cmdon = 'chobakwrap-caff ' . $asflag . ' -sec ' . int(($alarminterval * 1.2) + 10.2);
$cmdon .= ' &bg';
$cmdon = '( ' . $cmdon . ' )';
$cmdon .= ' > /dev/null 2> /dev/null';


$aft_end = `date +%s`; chomp($aft_end);
$aft_end = int(($aft_end + ($afta_min * 60)) + 0.2);
$aft_end = int(($aft_end + $afta_sec) + 0.2);

$volum = $orivolume;
while ( 2 > 1 )
{
  my $lc_cm;
  $lc_cm = "afplay -v " . $volum . ' ' . &wraprg::bsc($larmo) . ' &bg';
  $lc_cm = "( " . $lc_cm . " ) > /dev/null 2> /dev/null";
  
  $nowo = `date +%s`; chomp($nowo);
  if ( $afta_limit )
  {
    if ( $nowo > $aft_end ) { exit(0); }
  }
  
  
  
  system("echo", $prefixar . &vando(int(($nowo - $endo) + 0.2)) . ": Current Volume: " . $volum . ":");
  
  if ( $vibraton > 3 )
  {
    my $lc2_vb;
    my $lc2_cm;
    $lc2_vb = int($volum * 1000 * 55);
    &smallify($lc2_vb,2500);
    $lc2_cm = "chobakwrap-para-vibrate -msec $lc2_vb";
    if ( $vibraton < 8 )
    {
      $lc2_cm .= ' &bg';
      $lc2_cm = '( ' . $lc2_cm . ' )';
      $lc2_cm .= ' > /dev/null 2> /dev/null';
    }
    system($lc2_cm);
  }
  
  system($lc_cm);
  system($cmdon);
  sleep($alarminterval); &haltonic();
  
  $volum = ( $volum * $incresa );
  if ( $volum > $maxvol ) { $volum = $maxvol; }
  &engoaler();
}

sub smallify {
  if ( $_[0] > $_[1] ) { $_[0] = $_[1]; }
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

