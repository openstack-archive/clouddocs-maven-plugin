<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT stashes information about the types used in the doc here in the wadl if $wadl2docbook is true so we can use them in generating the docs  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:rax="http://docs.rackspace.com/api"
  xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs wadl xsd xsdxt xsl rax" version="2.0">

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
    <xsl:variable name="responses">
         <xsl:apply-templates select="$normalizeWadl3.xsl//wadl:response" mode="collect-faults"/>
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
      
        <rax:responses>
          <xsl:comment>A list of unique responses in the wadl </xsl:comment>
          <xsl:for-each-group select="$responses//rax:response" group-by="@namespace">
            <xsl:for-each-group select="current-group()" group-by="@name">
                <xsl:copy-of select="current-group()[1]"/>  
            </xsl:for-each-group>
          </xsl:for-each-group>
        </rax:responses>

      <xsl:apply-templates select="node()" mode="normalizeWadl4"/>

    </wadl:application>
  </xsl:template>

  <xsl:template match="wadl:param" mode="collect-types">
    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="@rax:type"><xsl:value-of select="substring-before(@rax:type,':')"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="substring-before(@type,':')"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="namespace-uri" select="namespace-uri-for-prefix($prefix,.)"/>
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="@rax:type"><xsl:value-of select="substring-after(@rax:type,':')"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="substring-after(@type,':')"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:if test="not($namespace-uri = 'http://www.w3.org/2001/XMLSchema')">
      <rax:type prefix="{$prefix}" namespace="{$namespace-uri}" name="{$name}">
        <!-- 
            Grab docs for this type and stash them here. 
                   $xsds/xsd:schema[@targetNamespace = $namespace-uri]//*[@name = current()/@name]/xsd:annotation/xsd:documentation            
        -->
        <para>
        <xsl:apply-templates select="$xsds/rax:xsd/xsd:schema[@targetNamespace = $namespace-uri]//*[(self::xsd:simpleType or self::xsd:complexType) and @name = $name]" mode="collect-types"/>
          </para>
      </rax:type>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="xsd:annotation|xsd:documentation" mode="collect-types">
      <xsl:apply-templates select="node()" mode="collect-types"/>
  </xsl:template>
  
  <xsl:template match="xsd:restriction[xsd:enumeration]" mode="collect-types">
   Possible values:
     <itemizedlist>
        <xsl:apply-templates mode="collect-types"/>
     </itemizedlist>
  </xsl:template>

  <xsl:template match="xsd:enumeration" mode="collect-types">
    <listitem>
      <para><emphasis role="bold"><xsl:value-of select="@value"/>: </emphasis><xsl:apply-templates mode="collect-types"/></para>
    </listitem>
  </xsl:template>
  
  <!-- ================================ -->
  
  <xsl:template match="wadl:response" mode="collect-faults">
    <xsl:variable name="prefix" select="substring-before(wadl:representation[@mediaType='application/xml'][1]/@element,':')"/>
    <xsl:variable name="namespace-uri" select="namespace-uri-for-prefix($prefix,.)"/>
    <xsl:variable name="name" select="substring-after(wadl:representation[@mediaType='application/xml'][1]/@element,':')"/>
   
    <xsl:if test="not($namespace-uri = 'http://www.w3.org/2001/XMLSchema')">
      <rax:response status="{@status}" prefix="{$prefix}" namespace="{$namespace-uri}" name="{$name}">
        <para>
          <xsl:apply-templates select="$xsds/rax:xsd[1]/xsd:schema[@targetNamespace = $namespace-uri]//*[self::xsd:element[parent::xsd:schema] and @name = $name]" mode="collect-faults"/>
        </para>
      </rax:response>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>