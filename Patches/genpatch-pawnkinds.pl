#!/usr/bin/perl
use strict;
use warnings;

my @PAWNKINDS = qw(
    PJ_ImpInspector
    PJ_ImpTaxOfficer
    PJ_ImpSoldier
    PJ_ImpTrader
    PJ_Stormtrooper
    PJ_StormtrooperSO
    PJ_ImpCommander
    PJ_ScoutTrooper
    PJ_RebVillager
    PJ_RebCouncilman
    PJ_RebTrader
    PJ_RebGuard
    PJ_RebSoldier
    PJ_RebLAVSoldier
    PJ_RebNadeSoldier
    PJ_RebPilot
    PJ_RebMerc
    PJ_ScumSoldier
    PJ_Ruffian
    PJ_ScumBoss
    PJ_BountyHunter
);

my $OUTFILE = "./PawnkindDefs/Pawnkinds-CE-patch.xml";
open(OUTFILE, ">", $OUTFILE) or die("ERR: open/write $OUTFILE: $!\n");
print("Generating patch file: $OUTFILE\n");

print OUTFILE (<<EOF);
<?xml version="1.0" encoding="utf-8" ?>
<Patch>

EOF

foreach my $pawnkind (@PAWNKINDS)
{
    print OUTFILE (<<EOF);
  <Operation Class="PatchOperationAddModExtension">
    <xpath>Defs/PawnKindDef[defName="$pawnkind"]</xpath>
    <value>
      <li Class="CombatExtended.LoadoutPropertiesExtension">
        <primaryMagazineCount>
          <min>3</min>
          <max>5</max>
        </primaryMagazineCount>
      </li>
    </value>
  </Operation>

EOF
}

print OUTFILE (<<EOF);
</Patch>

EOF

close(OUTFILE) or warn("WARN: close $OUTFILE: $!\n");

exit(0);

__END__

