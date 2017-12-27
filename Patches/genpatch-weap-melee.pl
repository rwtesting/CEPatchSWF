#!/usr/bin/perl
use strict;
use warnings;

use lib "../../_lib";
use RWPatcher::Weapons::Melee;

#
# Generate CE patch for $SOURCEFILE:
# - add weapon bulk
# - add armor penetration (tools nodes)
# - add EC attribute to tools node entries
# - add CE weapon tags
# - add melee crit/parry chance as offsets (same as CE patches for core melee weapons)
# ? Do I need to do something with deflection?
#
# Write results to $OUTFILE (overwrite existing).
#
# Warn+Skip if weapon found in $SOURCEFILE that we don't have CE data for.
#
# Armor Penetration
#   - In a17 was per-weapon
#   - In b18 is per tools item
# For b18, we'll set armor pen based on tool capacity and default to a17 value
# only if tool capacity can't be determined/mapped.
#

my $SOURCEFILE = "../../918227266/Defs/WeaponDefs_Melee/PJ_VibroWeps.xml";
my $SOURCEMOD  = "Star Wars - Factions";

# CE Values for each melee weapon, from a17 patch by jaeger972.
my %CEDATA = (
    PJ_Vibroaxe => {
        Bulk		 => 2,
	armorPenetration => 0.3,	# was MeleeWeapon_Penetration in a17
	MeleeCritChance	 => 0.5,	# vanilla gladius
	MeleeParryChance => 0.65,	# vanilla gladius
	weaponTags	 => [qw(CE_Sidearm CE_OneHandedWeapon)],
    },
    PJ_Vibrosword => {
        Bulk		 => 1.5,
	armorPenetration => 0.15,
	MeleeCritChance	 => 1,		# vanilla longsword
	MeleeParryChance => 0.75,	# vanilla longsword
	weaponTags	 => [qw(CE_Sidearm CE_OneHandedWeapon)],
    },
    PJ_Vibrocleaver => {
        Bulk		 => 1.5,
	armorPenetration => 0.15,
	MeleeCritChance	 => 0.5,	# vanilla gladius
	MeleeParryChance => 0.65,	# vanilla gladius
	weaponTags	 => [qw(CE_Sidearm CE_OneHandedWeapon)],
    },
    PJ_VScythe => {
        Bulk		 => 2.5,
	armorPenetration => 0.3,
	MeleeCritChance	 => 1,		# vanilla longsword
	MeleeParryChance => 0.75,	# vanilla longsword
	weaponTags	 => [qw(CE_Sidearm CE_OneHandedWeapon)],
    },
    PJ_Vibrodouble => {
        Bulk		 => 3.5,
	armorPenetration => 0.25,
	MeleeCritChance	 => 1,		# vanilla longsword
	MeleeParryChance => 0.75,	# vanilla longsword
	weaponTags	 => [qw(CE_Sidearm)],
    },
    PJ_StaffX => {
        Bulk		 => 3.5,
	armorPenetration => 0.1,
	MeleeCritChance	 => 0.65,	# vanilla mace
	MeleeParryChance => 0.4,	# vanilla mace
	weaponTags	 => [qw(CE_Sidearm)],
    },
    PJ_TStaff => {  # New in b18, no a17 equivalent.  We'll copy CE values from PJ_StaffX.
        Bulk		 => 3.5,
	armorPenetration => 0.1,
	MeleeCritChance	 => 0.65,	# vanilla mace
	MeleeParryChance => 0.4,	# vanilla mace
	weaponTags	 => [qw(CE_Sidearm)],
    },
);

my $patcher = new RWPatcher::Weapons::Melee(
    #sourcemod => $SOURCEMOD,
    sourcefile => $SOURCEFILE,
    cedata     => \%CEDATA,
    expected_parents => "PJ_BaseVibroWeapon",
) or die("ERR: Failed new RWPatcher::Weapons::Melee: $!\n");

$patcher->generate_patches;

exit(0);

__END__

