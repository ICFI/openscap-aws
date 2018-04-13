## OpenSCAP AWS

### Overview

This deployment method is intended to be used on AWS instances and will configure them to self-scan each day and report 
any failures to an SNS topic. As the scan score is a percentage of pass/fail findings and some tests may not 
be applicable to your environment the use of a tailoring file to specify which failures have been accepted by your 
organization makes this much more effective because then you can require that scans have a 100% score.

### Installation

The RPM requires that the AWS CLI be installed but does not require that you do it using the official RPMs. If you 
don't have a preference then ensuring you have the EPEL repo configured and installing using commands like the following
is the easiest method to install.

    yum -y install epel-release
    yum -y install awscli openscap-aws
    
### Configuration

Installs to /opt/openscap-aws and contains etc directory containing a versioned copy of the scap-security-guide 
content and a configuration file along with a scanning script.

    echo "$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1) * * * root /opt/openscap-aws/scan.sh" > /etc/cron.d/openscap-aws
    