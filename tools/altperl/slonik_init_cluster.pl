#!@@PERL@@
# $Id: slonik_init_cluster.pl,v 1.5 2006-11-07 16:08:41 cbbrowne Exp $
# Author: Christopher Browne
# Copyright 2004 Afilias Canada

use Getopt::Long;

# Defaults
my $CONFIG_FILE = '@@SYSCONFDIR@@/slon_tools.conf';
my $SHOW_USAGE  = 0;

# Read command-line options
GetOptions("config=s" => \$CONFIG_FILE,
	   "help"     => \$SHOW_USAGE);

my $USAGE =
"Usage: init_cluster [--config file]

    Generates the slonik commands necessary to create a cluster and
    prepare the nodes for use.  Also displays a report showing the
    relationships between the various nodes.

";

if ($SHOW_USAGE) {
  print $USAGE;
  exit 0;
}

require '@@PGLIBDIR@@/slon-tools.pm';
require $CONFIG_FILE;

# INIT CLUSTER
$slonik .=  "\n# INIT CLUSTER\n";
$slonik .=  genheader();
my ($dbname, $dbhost) = ($DBNAME[$MASTERNODE], $HOST[$MASTERNODE]);
$slonik .=  "  init cluster (id = $MASTERNODE, comment = 'Node $MASTERNODE - $dbname\@$dbhost');\n";

# STORE NODE
$slonik .=  "\n# STORE NODE\n";
foreach my $node (@NODES) {
  if ($node != $MASTERNODE) {		# skip the master node; it's already initialized!
    my ($dbname, $dbhost) = ($DBNAME[$node], $HOST[$node]);
    $slonik .=  "  store node (id = $node, event node = $MASTERNODE, comment = 'Node $node - $dbname\@$dbhost');\n";
  }
}
$slonik .=  "  echo 'Set up replication nodes';\n";

# STORE PATH
$slonik .=  "\n# STORE PATH\n";

$slonik .=  "  echo 'Next: configure paths for each node/origin';\n";
foreach my $nodea (@NODES) {
  my $dsna = $DSN[$nodea];
  foreach my $nodeb (@NODES) {
    if ($nodea != $nodeb) {
      my $dsnb = $DSN[$nodeb];
      my $providerba = $VIA[$nodea][$nodeb];
      my $providerab = $VIA[$nodeb][$nodea];
      if (!$printed[$nodea][$nodeb] and $providerab == $nodea) {
	$slonik .= "  store path (server = $nodea, client = $nodeb, conninfo = '$dsna');\n";
	$printed[$nodea][$nodeb] = "done";
      }
      if (!$printed[$nodeb][$nodea] and $providerba == $nodea) {
	$slonik .= "  store path (server = $nodeb, client = $nodea, conninfo = '$dsnb');\n";
	$printed[$nodeb][$nodea] = "done";
      }
    }
  }
}

$slonik .=  "  echo 'Replication nodes prepared';\n";
$slonik .=  "  echo 'Please start a slon replication daemon for each node';\n";
run_slonik_script($slonik, 'INIT CLUSTER');
