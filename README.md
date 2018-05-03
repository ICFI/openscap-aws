<img src="./docs/images/project.svg">

* **Website**: https://icfi.github.io/openscap-aws/
* **Docs**: https://icfi.github.io/openscap-aws/docs.html

### Overview

This openscap-aws rpm is intended to be used on CentOS or Red Hat AWS instances and will configure them to self-scan 
each day, publish score metrics to CloudWatch and optionally report any failures to an SNS topic. As the scan score is 
a percentage of pass/fail findings and some tests may not  be applicable to your environment the use of a tailoring file 
to specify which failures have been accepted by your organization makes this much more effective because then you can 
require that scans have a 100% score.

### RPM Creation

The project contains a Makefile which uses a CentOS 7 docker container to create the rpm package

Create the RPM

    make rpm
    
Clean up the artifacts

    make clean

### Installation

The rpm requires that the AWS CLI be installed but does not require that you do it using the official rpms. If you 
don't have a preference then ensuring you have the EPEL repo configured and installing using commands like the following
is the easiest method to install.

    yum -y install epel-release
    yum -y install awscli openscap-aws
    
### Configuration

The generated rpm file installs the OpenSCAP content to /opt/openscap-aws along with a configuration file and a script 
to execute the scan. The example below is one option to schedule the scan runs at random times throughout your fleet of 
instances.

    echo "$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1) * * * root /opt/openscap-aws/scan.sh" > /etc/cron.d/openscap-aws
    
### Example

An example [CloudFormation deployment template](example/openscap-aws.yaml) is provided as a quick demo and for ideas as 
to how you could integrate these concepts into your architecture.
