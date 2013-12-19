#!/usr/bin/perl

# Title:       Master TID: Filr
# Description: Determine if Novell Filr is installed
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
use SDP::Filr;

##############################################################################
# Overriden (eventually or in part) from SDP::Core Module
##############################################################################

@PATTERN_RESULTS = (
	PROPERTY_NAME_CLASS."=Filr",
	PROPERTY_NAME_CATEGORY."=Master TID",
	PROPERTY_NAME_COMPONENT."=All",
	PROPERTY_NAME_PATTERN_ID."=$PATTERN_ID",
	PROPERTY_NAME_PRIMARY_LINK."=META_LINK_Master",
	PROPERTY_NAME_OVERALL."=$GSTATUS",
	PROPERTY_NAME_OVERALL_INFO."=None",
	"META_LINK_Master=http://www.suse.com/support/kb/doc.php?id=7012400",
	"META_LINK_Product=https://www.novell.com/products/filr/"
);

##############################################################################
# Main Program Execution
##############################################################################

SDP::Core::processOptions();
	my $FILR_VER = SDP::Filr::getFilrVersion();
	if ( "$FILR_VER" ne '' ) {
		SDP::Core::updateStatus(STATUS_RECOMMEND, "Consider Master TID for Novell Filr Appliance v$FILR_VER");
	} else {
		SDP::Core::updateStatus(STATUS_ERROR, "Novell Filr Appliance not installed");
	}
SDP::Core::printPatternResults();

exit;


