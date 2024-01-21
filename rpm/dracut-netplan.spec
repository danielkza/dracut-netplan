%define dracutlibdir %{_prefix}/lib/dracut
%global dracutconfdir %{_sysconfdir}/dracut.conf.d

%global pkgname dracut-netplan
%global repourl https://github.com/danielkza/%{pkgname}

%global debug_package %{nil}

Name:           %{pkgname}
Version:        0.1.0
Release:        1%{?dist}
Summary:        Netplan support for Dracut
License:        GPL-2.0

URL: %{repourl}

# For OBS, dont be smart with naming artifacts for git refs
%if %{?_obs:1}%{!?_obs:0}

%global archivename %{pkgname}-%{version}
Source0: %{archivename}.tar.gz
%else

%if %{?commit:1}%{!?commit:0}
%global gitref %{commit}
%elif %{?gittag:1}%{!?gittag:0}
%global gitref %{gittag}
%else
%global gitref master
%endif

%global archivename %{pkgname}-%{gitref}
Source0: %{repourl}/archive/%{gitref}/%{archivename}.tar.gz

%endif

BuildRequires: dracut

Requires: dracut-network
Requires: netplan

BuildArch: noarch

%description
Netplan support for Dracut

%prep
%autosetup -n %{archivename}

%build

%install

mkdir -p %{buildroot}/%{dracutconfdir}
install -m 0644 src/dracut.conf.d/netplan.conf %{buildroot}/%{dracutconfdir}/netplan.conf

mkdir -p %{buildroot}/%{dracutlibdir}/modules.d/40netplan/
install -m 0755 src/dracut/modules.d/40netplan/*.sh %{buildroot}/%{dracutlibdir}/modules.d/40netplan/

%check

%files

%license LICENSE
%doc README.md

%{dracutlibdir}/modules.d/*

%config(noreplace) %{dracutconfdir}/netplan.conf
