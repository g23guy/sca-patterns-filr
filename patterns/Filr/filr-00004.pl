#!/usr/bin/perl

# Title:       Filr root access denied
# Description: Configuring Filr appliance gives Unable to set root password error
# Modified:    2013 Jun 27

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
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

#  Authors/Contributors:
#   Jason Record (jrecord@suse.com)

##############################################################################

##############################################################################
# Module Definition
##############################################################################

use strict;
use warnings;
use SDP::Core;
use SDP::SUSE;
use SDP::Filr;

##############################################################################
# Overriden (eventually or in part) from SDP::Core Module
##############################################################################

@PATTERN_RESULTS = (
	PROPERTY_NAME_CLASS."=Filr",
	PROPERTY_NAME_CATEGORY."=MySQL",
	PROPERTY_NAME_COMPONENT."=Config",
	PROPERTY_NAME_PATTERN_ID."=$PATTERN_ID",
	PROPERTY_NAME_PRIMARY_LINK."=META_LINK_TID",
	PROPERTY_NAME_OVERALL."=$GSTATUS",
	PROPERTY_NAME_OVERALL_INFO."=None",
	"META_LINK_TID=http://www.suse.com/support/kb/doc.php?id=7012716",
	"META_LINK_BUG=https://bugzilla.novell.com/show_bug.cgi?id=819234",
	"META_LINK_Master=http://www.suse.com/support/kb/doc.php?id=7012400"
);

##############################################################################
# Local Function Definitions
##############################################################################

sub bootRootError {
	SDP::Core::printDebug('> bootRootError', 'BEGIN');
	my $RCODE = 0;
	my $FILE_OPEN = 'boot.txt';
	my $SECTION = 'boot.msg';
	my @CONTENT = ();

	SDP::Core::getSection($FILE_OPEN, $SECTION, \@CONTENT);
	foreach $_ (@CONTENT) {
		next if ( m/^\s*$/ ); # Skip blank lines
		if ( /Can.*t connect to local MySQL server through socket.*mysql\/mysql.sock/i ) {
			SDP::Core::printDebug("  bootRootError FOUND", $_);
			$RCODE++;
			last;
		}
	}
	SDP::Core::printDebug("< bootRootError", "Returns: $RCODE");
	return $RCODE;
}

sub jettyRootError {
	SDP::Core::printDebug('> jettyRootError', 'BEGIN');
	my $RCODE = 0;
	my $FILE_OPEN = 'plugin-vadump_base.txt';
	my $SECTION = 'jetty.stderr';
	my @CONTENT = ();

	SDP::Core::getSection($FILE_OPEN, $SECTION, \@CONTENT);
	foreach $_ (@CONTENT) {
		next if ( m/^\s*$/ ); # Skip blank lines
		if ( /ERROR.*Access denied for user.*root.*@.*localhost.*using password: YES/i ) {
			SDP::Core::printDebug("  jettyRootError FOUND", $_);
			$RCODE++;
			last;
		}
	}
	SDP::Core::printDebug("< jettyRootError", "Returns: $RCODE");
	return $RCODE;
}

##############################################################################
# Main Program Execution
##############################################################################

SDP::Core::processOptions();
	my $FILR_VER = SDP::Filr::getFilrVersion();
	if ( "$FILR_VER" ne '' ) {
		if ( bootRootError() ) {
			SDP::Core::updateStatus(STATUS_WARNING, "Root password may not be set for Filr access");
			if ( jettyRootError() ) {
				SDP::Core::updateStatus(STATUS_CRITICAL, "Confirm root access to MySQL database");
			}
		} elsif ( jettyRootError() ) {
			SDP::Core::updateStatus(STATUS_CRITICAL, "Confirm root access to MySQL database");
		} else {
			SDP::Core::updateStatus(STATUS_ERROR, "No root MySQL password errors detected");
		}
	} else {
		SDP::Core::updateStatus(STATUS_ERROR, "Novell Filr not installed, skipping disk full test");
	}
SDP::Core::printPatternResults();
exit;


