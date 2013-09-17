<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT flattens the xsds associated with the wadl.  -->
<!--
   Copyright 2011 Rackspace US, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:xs="http://www.w3.org/2001/XMLSchema" 
		xmlns:wadl="http://wadl.dev.java.net/2009/02" 
		xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
		xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0" 
		exclude-result-prefixes="xs wadl xsd xsdxt" 
		version="2.0">

    <xsl:import href="classpath:///cloud/normalizeWadl/normalizeWadl1.xsl"/>

    <xsl:param name="format">path-format</xsl:param>

    <xsl:param name="xsd.output.path">target/generated-resources/xml/xslt/</xsl:param>

    <xsl:param name="wadl2docbook">1</xsl:param>
    
    <xsl:param name="resource_types">omit</xsl:param>

</xsl:stylesheet>