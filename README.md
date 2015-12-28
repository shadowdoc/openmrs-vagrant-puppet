Radiology OpenMRS research repository
=======

Description
=======
The purpose of this server is to provide a mechanism for sophisticated research data collection and analysis beyond the capabilities provided by RedCap and other CTSI tools.

Requirements
============
1. Vagrant : https://www.vagrantup.com/downloads.html
2. VirtualBox : https://www.virtualbox.org/wiki/Downloads
3. Git : http://git-scm.com/downloads


Setup - One time
================

1. Ensure you have the applications specified in the <b>Requirements </b> section installed 


2. Clone the repository into a local directory using the following command 

```
https://github.com/shadowdoc/openmrs-puppet-vagrant.git
```

3. Change into the openmrs directory and run the following vagrant command to set up your instance

```
vagrant up
```

You will get a notice similar to the one below once vagrant is done running successfully

```
==> default: Notice: Finished catalog run in 354.92 seconds
```

After vagrant has finished running, you are ready  to run the openmrs system. Point your browser to the link 
http://localhost:8080/openmrs/

You will be directed to the login page. To access the account use these credentials <b>  username: admin <b/> and <b> password: Admin123 </b>

![alt tag](https://github.iu.edu/radyops/openmrs/raw/master/images/login.png)


Form Creation
==============

Read on the OpenMRS forms schema here to get started working on your own forms 

https://wiki.openmrs.org/display/docs/Administering+Forms

Xforms is our preferred method of displaying and editing forms.  

Refer to this guide : https://wiki.openmrs.org/display/docs/XForms+Module+User+Guide

https://wiki.openmrs.org/display/docs/XForms+Module+Form+Designer

Video on xforms : http://connect.iu.edu/p4gxh601oxv/

Exporting Forms
===============

https://wiki.openmrs.org/display/docs/User%27s+Guide+for+Metadata+Sharing+Module

