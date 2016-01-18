============
Introduction
============

This project is the OpenStack customization of the Docbkx
plug-in for creating documentation artifacts for OpenStack.

Example output
==============

OpenStack output:

- http://docs.openstack.org/
- http://api.openstack.org/api-ref.html

OpenStack source files:

- https://git.openstack.org/cgit/openstack/openstack-manuals
- https://git.openstack.org/cgit/openstack/api-site


Test changes to clouddocs-maven-plugin
======================================

Note: When you commit, be sure you are on a branch,
do a single commit, and do "git review" instead of pushing.

To test changes to clouddocs-maven-plugin on your local machine:

#. Run this command to clone clouddocs-maven-plugin:

        git clone https://git.openstack.org/openstack/clouddocs-maven-plugin

#. CD into the clouddocs-maven-plugin directory.

#. Edit the pom.xml file and set the version number on line #11 to include -SNAPSHOT.
   For example, 1.12.1-SNAPSHOT.

#. Make changes to clouddocs-maven-plugin.

#. Run this command to build clouddocs-maven-plugin locally:

        mvn clean install

#. Run this command to clone the api-site:

        git clone https://git.openstack.org/openstack/api-site

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
- http://docs.openstack.org/contributor-guide/tools-and-content-overview.html
