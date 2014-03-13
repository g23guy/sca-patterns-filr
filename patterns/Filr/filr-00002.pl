#!/usr/bin/perl

# Title:       Filr VM support
# Description: XEN, KVM, and Hyper-V support for Filr
# Modified:    2013 Jun 22

##############################################################################
#  Copyright (C) 2013 SUSE LLC
##############################################################################
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses/>.

#  Authors/Contributors:
#   Jason Record (jrecord@suse.com)

##############################################################################

##############################################################################
# Module Definition
##############################################################################

use strict;
use warnings;
use SDP::Core;
use SDP::Filr;

##############################################################################
# Overriden (eventually or in part) from SDP::Core Module
##############################################################################

@PATTERN_RESULTS = (
	PROPERTY_NAME_CLASS."=Filr",
	PROPERTY_NAME_CATEGORY."=VM",
	PROPERTY_NAME_COMPONENT."=Support",
	PROPERTY_NAME_PATTERN_ID."=$PATTERN_ID",
	PROPERTY_NAME_PRIMARY_LINK."=META_LINK_TID",
	PROPERTY_NAME_OVERALL."=$GSTATUS",
	PROPERTY_NAME_OVERALL_INFO."=None",
	"META_LINK_TID=http://www.suse.com/support/kb/doc.php?id=7012421",
	"META_LINK_BUG=https://bugzilla.novell.com/show_bug.cgi?id=819473"
);




##############################################################################
# Local Function Definitions
##############################################################################

sub vmWareVM {
	SDP::Core::printDebug('> vmWareVM', 'BEGIN');
	my $RCODE = 0;
	my $FILE_OPEN = 'basic-environment.txt';
	my $SECTION = 'Virtualization';
	my @CONTENT = ();

	if ( SDP::Core::getSection($FILE_OPEN, $SECTION, \@CONTENT) ) {
		foreach $_ (@CONTENT) {
			next if ( m/^\s*$/ ); # Skip blank lines
			if ( /Hypervisor:.*VMware/i ) {
				SDP::Core::printDebug("PROCESSING", $_);
				$RCODE++;
				last;
			}
		}
	} else {
		SDP::Core::updateStatus(STATUS_ERROR, "ERROR: vmWareVM(): Cannot find \"$SECTION\" section in $FILE_OPEN");
	}
	SDP::Core::printDebug("< vmWareVM", "Returns: $RCODE");
	return $RCODE;
}

##############################################################################
# Main Program Execution
##############################################################################

SDP::Core::processOptions();
	my $FILR_VER = getFilrVersion();
	if ( "$FILR_VER" ne '' ) {
		if ( SDP::Core::compareVersions($FILR_VER, FILR1R1) < 0 ) {
			if ( vmWareVM() ) {
				SDP::Core::updateStatus(STATUS_ERROR, "Supported VM environment: VMware");
			} else {
				SDP::Core::updateStatus(STATUS_CRITICAL, "Unsupported Filr Appliance virtual machine environment");
			}
		} else {
			SDP::Core::updateStatus(STATUS_ERROR, "Filr v$FILR_VER is sufficient, non-VMware skipped");
		}
	} else {
		SDP::Core::updateStatus(STATUS_ERROR, "Novell Filr Appliance not installed");
	}
SDP::Core::printPatternResults();

exit;


