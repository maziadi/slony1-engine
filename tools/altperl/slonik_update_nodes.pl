#!@@PERL@@
# $Id: slonik_update_nodes.pl,v 1.3 2008-02-14 16:41:35 cbbrowne Exp $
# Author: Christopher Browne
# Copyright 2004 Afilias Canada

use Getopt::Long;

# Defaults
$CONFIG_FILE = '@@SYSCONFDIR@@/slon_tools.conf';
$SHOW_USAGE  = 0;

# Read command-line options
GetOptions("config=s" => \$CONFIG_FILE,
	   "help"     => \$SHOW_USAGE);

my $USAGE =
"Usage: update_nodes [--config file]

    Updates the functions on all nodes.

";

if ($SHOW_USAGE) {
  print $USAGE;
  exit 0;
}

require '@@PERLSHAREDIR@@/slon-tools.pm';
require $CONFIG_FILE;

my $slonik = '';
$slonik .= genheader();
foreach my $node (@NODES) {
  $slonik .= "  update functions (id = $node);\n";
};

run_slonik_script($slonik, 'UPDATE FUNCTIONS');
