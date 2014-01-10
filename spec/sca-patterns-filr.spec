# Copyright (C) 2013 SUSE LLC
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#

# norootforbuild
# neededforbuild

%define produser sca
%define prodgrp sdp
%define patuser root
%define patgrp root
%define patdir /var/opt/%{produser}/patterns
%define mode 544
%define category Filr

Name:         sca-patterns-filr
Summary:      Supportconfig Analysis Patterns for Filr
URL:          https://bitbucket.org/g23guy/sca-patterns-filr
Group:        Documentation/SuSE
Distribution: SUSE Linux Enterprise
Vendor:       SUSE Support
License:      GPL-2.0
Autoreqprov:  on
Version:      1.2
Release:      2
Source:       %{name}-%{version}.tar.gz
BuildRoot:    %{_tmppath}/%{name}-%{version}
Buildarch:    noarch
Requires:     sca-patterns-base

%description
Supportconfig Analysis (SCA) appliance patterns to identify known
issues relating to all versions of Filr

Authors:
--------
    Jason Record <jrecord@suse.com>

%prep
%setup -q

%build

%install
pwd;ls -la
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{patdir}/%{category}
install -m %{mode} patterns/%{category}/* $RPM_BUILD_ROOT/%{patdir}/%{category}

%files
%defattr(-,%{patuser},%{patgrp})
%dir /var/opt/%{produser}
%dir %{patdir}
%dir %{patdir}/%{category}
%attr(%{mode},%{patuser},%{patgrp}) %{patdir}/%{category}/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Fri Jan 10 2014 jrecord@suse.com
- added
  heap-7012478.py

* Wed Dec 20 2013 jrecord@suse.com
- separated as individual RPM package

