<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"  
    xmlns:rax="http://docs.rackspace.com/api"
    version="1.0">
 
 
 <xsl:template match="/">
     <xsl:message>
         0="<xsl:value-of select="0"/>"
     </xsl:message>
     
 </xsl:template>
 <xsl:variable name="types">
    <rax:types>     
        <xsl:apply-templates select="//wadl:param" mode="types"/>
    </rax:types> 
 </xsl:variable>
 
 <xsl:template match="wadl:param" mode="types">
     <rax:type 
         type="{@type}" 
         namespace-prefix="{substring-before(@type,':')}" 
         namespace-uri="" 
         />
 </xsl:template>
 
</xsl:stylesheet>