<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rax="http://docs.rackspace.com/api"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"
    exclude-result-prefixes="rax wadl"
    version="2.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="wadl:application/rax:types|wadl:application/rax:responses|wadl:application/rax:resources|@rax:id[. = '']|wadl:application/@rax:original-wadl|comment()[contains(.,'This is a representation of the resources tree')]|comment()[starts-with(.,'Original xsd: ')]"/>
    
    <!--- This is to keep Saxon from complaining that there are no templates matching the default namespace -->
    <xsl:template match="wadl:dummy"/>
    
</xsl:stylesheet>