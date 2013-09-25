<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  name="main">
  
  <p:input port="source" primary="true"/> <!--sequence="false" primary="true"-->
  <p:input port="schema" sequence="true" >
    <p:document  href="http://docs-beta.rackspace.com/oxygen/13.1/mac/author/frameworks/rackbook/5.0/rng/rackbook.rng"/> <!--http://docs-beta.rackspace.com/oxygen/13.1/mac/author/frameworks/rackbook/5.0/-->
  </p:input>

  <p:output port="result" primary="true">  
    <p:pipe step="programlisting-keep-together-xslt" port="result"/>  
  </p:output>  
  <p:output port="report" sequence="true">  
    <p:pipe step="tryvalidation" port="report"/>  
  </p:output>
  <p:serialization port="report" indent="true"/>
  <p:try name="tryvalidation"> 
    <p:group> 
      <p:output port="result"> 
        <p:pipe step="xmlvalidate" port="result"/>  
      </p:output> 
      <p:output port="report" sequence="true"> 
        <p:empty/> 
      </p:output>      
      
      <p:validate-with-relax-ng name="xmlvalidate"  assert-valid="true"> 
        <p:input port="source"> 
          <p:pipe step="main" port="source"/> 
        </p:input> 
        <p:input port="schema"> 
          <p:pipe step="main" port="schema"/>  
        </p:input>  
      </p:validate-with-relax-ng>  
     
    </p:group>  
    <p:catch name="catch">  
      <p:output port="result">  
        <p:pipe step="main" port="source"/>  
      </p:output>  
      <p:output port="report">  
        <p:pipe step="id" port="result"/> 
      </p:output>  
      <p:error name="relaxng-validation-error" code="rax:E001" xmlns:rax="http://docs.rackspace.com/api">
        <p:input port="source" >
          <p:inline><message>This document is invalid. No docs for you!</message></p:inline>
        </p:input>
      </p:error>
      <p:xslt name="id">
        <p:input port="source">  
          <p:pipe step="catch" port="error"/>  
        </p:input>  
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
              
              <xsl:param name="failonerror">yes</xsl:param>
              
              <xsl:template match="node()|@*">
                <xsl:message terminate="{$failonerror}">
                  <xsl:copy-of select="."/>
                </xsl:message>    
                <xsl:copy>
                  <xsl:apply-templates select="node() | @*"/>
                </xsl:copy>
              </xsl:template>
              
            </xsl:stylesheet>
          </p:inline>
        </p:input>
        <p:input port="parameters" sequence="true">
          <p:empty/>
        </p:input>
      </p:xslt>
    </p:catch>  
  </p:try>
  
  <p:xslt name="programlisting-keep-together-xslt">
    <p:input port="source"> 
      <p:pipe step="main" port="source"/> 
    </p:input> 
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
          xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:db="http://docbook.org/ns/docbook"
          exclude-result-prefixes="xs" version="2.0">
          
          <xsl:template match="node() | @*">
            <xsl:copy>
              <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
          </xsl:template>
          
          <xsl:param name="max">8</xsl:param>
          
          <xsl:template match="db:programlisting">
            <xsl:copy>
              <xsl:apply-templates select="@*"/>
              <xsl:if test="count(tokenize(.,'&#xA;')) &gt; $max">
                <xsl:processing-instruction name="dbfo">keep-together="always"</xsl:processing-instruction>
                <xsl:comment>linefeeds: <xsl:value-of select="count(tokenize(.,'&#xA;'))"/></xsl:comment>
              </xsl:if>
              <xsl:apply-templates select="node()"/>
            </xsl:copy>
          </xsl:template>
          
        </xsl:stylesheet>
      </p:inline>
      <!--<p:document href="cloud/code-listing-keep-together.xsl"/>-->
    </p:input>
    <p:input port="parameters" sequence="true">
      <p:empty/>
    </p:input>
  </p:xslt>

</p:declare-step>
