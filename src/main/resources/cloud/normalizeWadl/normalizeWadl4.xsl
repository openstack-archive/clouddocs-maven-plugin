<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT stashes information about the types used in the doc here in the wadl if $wadl2docbook is true so we can use them in generating the docs  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:rax="http://docs.rackspace.com/api"
  xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0"
  exclude-result-prefixes="xs wadl xsd xsdxt" version="2.0">

  <xsl:param name="normalizeWadl3.xsl"/>
  <xsl:param name="catalog"/>
  <xsl:param name="xsd.output.path"/>
  <xsl:param name="wadl2docbook"/>
  <xsl:variable name="root" select="/"/>
  <xsl:variable name="xsds" select="/"/>

  <xsl:template match="@*|node()" mode="normalizeWadl4">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="normalizeWadl4"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="wadl:application" mode="normalizeWadl4">
    <xsl:variable name="types">
         <xsl:apply-templates select="$normalizeWadl3.xsl" mode="collect-types"/>
    </xsl:variable>
    
    <wadl:application>
      <xsl:apply-templates select="@*" mode="normalizeWadl4"/>

        <rax:types>
          <xsl:for-each-group select="$types//rax:type" group-by="@namespace">
            <xsl:for-each-group select="current-group()" group-by="@name">
                <xsl:copy-of select="current-group()[1]"/>  
            </xsl:for-each-group>
          </xsl:for-each-group>
        </rax:types>

      <xsl:apply-templates select="node()" mode="normalizeWadl4"/>

    </wadl:application>
  </xsl:template>

  <xsl:template match="wadl:param" mode="collect-types">
    <xsl:variable name="prefix" select="substring-before(@type,':')"/>
    <xsl:variable name="namespace-uri" select="namespace-uri-for-prefix($prefix,.)"/>
    <xsl:variable name="name" select="substring-after(@type,':')"/>
    
    <xsl:if test="not($namespace-uri = 'http://www.w3.org/2001/XMLSchema')">
      <rax:type prefix="{$prefix}" namespace="{$namespace-uri}" name="{$name}">
        <!-- 
            Grab docs for this type and stash them here. 
                   $xsds/xsd:schema[@targetNamespace = $namespace-uri]//*[@name = current()/@name]/xsd:annotation/xsd:documentation            
        -->
        <xsl:copy-of select="$xsds/rax:xsd/xsd:schema[@targetNamespace = $namespace-uri]//*[@name = $name]/xsd:annotation/xsd:documentation"/>
      </rax:type>
    </xsl:if>
  </xsl:template>

<xsl:template match="text()" mode="collect-types"/>

</xsl:stylesheet>