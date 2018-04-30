%define buildroot           %{_topdir}/BUILDROOT/openscap-aws-root
%define version             %{?_version}%{!?_version: 0.1.37}

%define name                openscap-aws
%define openscap_aws_home   /opt/%{name}

Name:           %{name}
Version:        %{version}
Release:        1%{?dist}
BuildRoot:      %{buildroot}
BuildArch:      noarch
Summary:        OpenSCAP scripts to automate running and reporting CloudWatch metrics
License:        BSD
URL:            https://github.com/OpenSCAP/scap-security-guide
Source1:        openscap-aws.conf
Source2:        aws-cloud-tailored.xml
Source3:        scan.sh
Source4:        LICENSE.txt
BuildRequires:  curl
BuildRequires:  sed
BuildRequires:  unzip
Requires:       aide
Requires:       bc
Requires:       cronie
Requires:       curl
Requires:       dracut-fips
Requires:       dracut-fips-aesni
Requires:       openscap
Requires:       openscap-utils
Requires:       prelink
Requires:       scap-security-guide
Requires:       sssd
Requires:       xmlstarlet

%description
OpenSCAP scripts to automate running and reporting CloudWatch metrics

%prep

%build

%install

mkdir -p %{buildroot}%{openscap_aws_home}/etc

# Download the specified version of the SCAP Security Guide
curl -sL https://github.com/OpenSCAP/scap-security-guide/releases/download/v%{version}/scap-security-guide-%{version}.zip > %{buildroot}%{openscap_aws_home}/etc/scap-security-guide-%{version}.zip
unzip -q %{buildroot}%{openscap_aws_home}/etc/scap-security-guide-%{version}.zip -d  %{buildroot}%{openscap_aws_home}/etc/
rm -f %{buildroot}%{openscap_aws_home}/etc/scap-security-guide-%{version}.zip

# Copy the default configuration files
install -m 0644 %{SOURCE1} %{buildroot}%{openscap_aws_home}/etc/openscap-aws.conf
install -m 0644 %{SOURCE2} %{buildroot}%{openscap_aws_home}/etc/aws-cloud-tailored.xml

# Copy the scripts, doing a token replace of versions and paths
mkdir -p %{buildroot}%{openscap_aws_home}/
install -m 0755 %{SOURCE3} %{buildroot}%{openscap_aws_home}/scan.sh
sed -i "s/\${SCAP_VERSION}/%{version}/g" %{buildroot}%{openscap_aws_home}/scan.sh
sed -i "s#\${REPORT_DIR}#%{openscap_aws_home}#g" %{buildroot}%{openscap_aws_home}/scan.sh

install -m 0644 %{SOURCE1} %{buildroot}%{openscap_aws_home}/LICENSE.txt

%files
%config %{openscap_aws_home}/etc/openscap-aws.conf
%config %{openscap_aws_home}/etc/aws-cloud-tailored.xml
%{openscap_aws_home}/scan.sh
%{openscap_aws_home}/LICENSE.txt

%defattr(0644, root, root, 0755)
%{openscap_aws_home}/etc/scap-security-guide-%{version}

%changelog
* Fri Apr 13 2018 Andy Spohn <andy.spohn@icf.com> - 0.1.38
- Updated OpenSCAP release version
* Fri Jan 19 2018 Andy Spohn <andy.spohn@icf.com> - 0.1.37
- First packaging
