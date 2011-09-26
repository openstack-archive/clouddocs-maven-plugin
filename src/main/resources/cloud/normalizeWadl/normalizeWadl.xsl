<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT flattens the xsds associated with the wadl.  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:xs="http://www.w3.org/2001/XMLSchema" 
		xmlns:wadl="http://wadl.dev.java.net/2009/02" 
		xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
		xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0" 
		exclude-result-prefixes="xs wadl xsd xsdxt" 
		version="2.0">

    <xsl:import href="normalizeWadl1.xsl"/>

    <xsl:param name="format">path-format</xsl:param>

    <xsl:param name="xsd.output.path">target/generated-resources/xml/xslt/</xsl:param>

    <xsl:param name="wadl2docbook">1</xsl:param>

</xsl:stylesheet>