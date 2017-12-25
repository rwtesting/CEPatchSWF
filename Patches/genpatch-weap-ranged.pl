#!/usr/bin/perl
use strict;
use warnings;

use XML::Simple;
use File::Basename qw(basename);

use lib "../../_lib";
use RWPatcher::Weapons::Ranged;

#
# Generate CE patch for @SOURCEFILES:
# - Add missing CE values
# - Add <tools> node (gun melee values, use the same values for all blasters for now).
# - Verbatim copy <verbs> node to new CE <Properties> node.
#   (tried renaming <verbs> to Properties + changes, but <verbs> needs to remain)
#   (can't find a built-in method for copying a node via operations)
#
# Write results to $OUTFILE (overwrite existing).
#
# Warn+Skip if blaster found in source file that we don't have CE data for.
#

# The source (from source mod) files to be used to generate patches.
# The output file will have the same base name, with s/(-REF)?.txt/.xml/,
# and same parent dirname (under current dir).
# (.txt is sometimes used for copied ref/source files so that Rimworld doesn't read them)
my @SOURCEFILES = qw(
    ../../918227266/Defs/WeaponDefs_Ranged/Blaster_Weps.xml
    ../../918227266/Defs/WeaponDefs_Ranged/InstalledPart_Weps.xml
);

my $SOURCEMOD = "Star Wars - Factions";

# CE Values + ammo for each blaster, from a17 patch by jaeger972
# Add new b18 CE weapon tags and generate patch in b18 format.
my %CEDATA = (

    ##########################
    # FILE: Blaster_Weps.xml #
    ##########################

    PJ_E11Blaster => {
	SightsEfficiency => 1,
	ShotSpread	 => 0.07,
	SwayFactor	 => 1.30,
	Bulk		 => 6.50,
	weaponTags	 => [qw(CE_AI_AssaultWeapon)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',  # was projectileDef in a17

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 24,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 3,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DH17Blaster => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.11,
	SwayFactor	 => 1.02,
	Bulk		 => 2.17,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 15,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_Scoutblaster => {
	SightsEfficiency => 0.85,
	ShotSpread	 => 0.21,
	SwayFactor	 => 1.32,
	Bulk		 => 2.17,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 16,
	    reloadTime	 => 2,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 2,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',
    },
    PJ_SE14blaster => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.11,
	SwayFactor	 => 1.02,
	Bulk		 => 2.17,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 20,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 2,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DL44blaster => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.21,
	SwayFactor	 => 1.32,
	Bulk		 => 3,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 12,
	    reloadTime	 => 3.5,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DXR6Carb => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.21,
	SwayFactor	 => 1.32,
	Bulk		 => 3,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 14,
	    reloadTime	 => 3.2,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_JawaIon => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.21,
	SwayFactor	 => 1.32,
	Bulk		 => 3,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 18,
	    reloadTime	 => 3.7,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_NymSlug => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.26,
	SwayFactor	 => 1.64,
	Bulk		 => 3,
	weaponTags	 => [qw(CE_OneHandedWeapon CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_12Gauge_ElectroSlug',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 16,
	    reloadTime	 => 4,
	    ammoSet	 => 'AmmoSet_12Gauge',  # CE shotgun ammoset
	    #ammoSet	 => 'AmmoSet_Nym',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_LauncherP => {
	SightsEfficiency => 0.45,
	ShotSpread	 => 0.35,
	SwayFactor	 => 4.64,
	Bulk		 => 5.50,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_84x246mmR_HEAT',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 8,
	    reloadTime	 => 6,
	    ammoSet	 => 'AmmoSet_84x246mmR',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_T21Rifle => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.11,
	SwayFactor	 => 1.02,
	Bulk		 => 4,
	weaponTags	 => [qw(CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge_AP',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 18,
	    reloadTime	 => 2.4,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DC15Rifle => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.31,
	SwayFactor	 => 1.22,
	Bulk		 => 4,
	weaponTags	 => [qw(CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 20,
	    reloadTime	 => 2.4,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 2,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DLT19Rifle => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.31,
	SwayFactor	 => 1.22,
	Bulk		 => 4,
	weaponTags	 => [qw(MedievalShields_ValidSidearm CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 24,
	    reloadTime	 => 2.4,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 3,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_EE3Carbine => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.08,
	SwayFactor	 => 0.82,
	Bulk		 => 4,
	weaponTags	 => [qw(CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 30,
	    reloadTime	 => 1.9,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },

    ################################
    # FILE: InstalledPart_Weps.xml #
    ################################

    PJ_ATST_Blaster => {
	SightsEfficiency => 0.75,
	ShotSpread	 => 0.13,
	SwayFactor	 => 0.89,
	Bulk		 => 5.65,
	weaponTags	 => [],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWBigPlasmaGasCartridge_AP',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 6,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWBigPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	},
    },
    PJ_ATAT_Blaster => {
	SightsEfficiency => 0.75,
	ShotSpread	 => 0.13,
	SwayFactor	 => 0.89,
	Bulk		 => 5.65,
	weaponTags	 => [],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWBigPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 6,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWBigPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	},
    },
    PJ_Spd_Blaster => {
	SightsEfficiency => 0.75,
	ShotSpread	 => 0.13,
	SwayFactor	 => 0.89,
	Bulk		 => 5.65,
	weaponTags	 => [],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge_AP',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 10,
	    reloadTime	 => 1.2,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	},
    },

);

my $patcher = new RWPatcher::Weapons::Ranged(
    sourcefiles => \@SOURCEFILES,
    cedata      => \%CEDATA,
    #sourcemod	=> $SOURCEMOD,
) or die("ERR: Failed new RWPatcher::Weapons::Ranged: $!\n");

$patcher->generate_patches();

exit(0);

__END__

