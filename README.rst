Introduction
============

This project is the Rackspace/OpenStack customization of the Docbkx
plug-in for creating documentation artifacts for Rackspace, OpenStack,
and other OpenStack projects.

Example output
==============
Rackspace output: 

- http://docs.rackspace.com/files/api/v1/cf-devguide/content/Overview-d1e70.html

OpenStack output:

- http://docs.openstack.org/user-guide/content/
- http://api.openstack.org/api-ref.html

OpenStack source files:

- https://github.com/openstack/openstack-manuals/tree/master/doc/user-guide/src
- https://github.com/openstack/api-site/tree/master/api-ref


Test changes to clouddocs-maven-plugin
======================================

Note: When you commit, be sure you are on a branch,
do a single commit, and do "git review" instead of pushing.

To test changes to clouddocs-maven-plugin on your local machine:

#. Run this command to clone clouddocs-maven-plugin:

        git clone git@github.com:stackforge/clouddocs-maven-plugin.git

#. CD into the clouddocs-maven-plugin directory.

#. Edit the pom.xml file and set the version number on line #11 to include -SNAPSHOT.
   For example, 1.12.1-SNAPSHOT.

#. Make changes to clouddocs-maven-plugin.

#. Run this command to build clouddocs-maven-plugin locally:

        mvn clean install

#. Run this command to clone the api-site:

        git clone git@github.com:openstack/api-site.git

#. CD into the api-site directory.

#. Edit the pom.xml file and set the version number on line #42
   to the same version number as in the clouddocs-maven-plugin pom.xml file.
   For example, 1.12.1-SNAPSHOT.

#. Run the following command to build the api-site locally:

        mvn clean generate-sources -U

   The -U switch picks up the local build of clouddocs-maven-plugin.

How Tos
=======
- http://docs.rackspace.com/writers-guide
- http://wiki.openstack.org/Documentation/HowTo#Tools_Overview
