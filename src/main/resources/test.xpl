<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:l="http://xproc.org/library"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  name="main">
  
  <p:input port="source" /> 
  <p:output port="result"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <!--  <p:import href="validate-transform.xpl"/>-->
  <p:declare-step version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:l="http://xproc.org/library"
    type="l:validate-transform"
    name="main">
    
    <p:input port="source" /> <!--sequence="false" primary="true"-->
    <p:input port="schema" sequence="true" >
      <p:document  href="classpath:/rng/rackbook.rng"/> <!--http://docs-beta.rackspace.com/oxygen/13.1/mac/author/frameworks/rackbook/5.0/-->
    </p:input>

    <p:output port="result" primary="true">  
      <!--      <p:pipe step="programlisting-keep-together-xslt" port="result"/> -->
      <p:pipe step="tryvalidation" port="result"/>  
    </p:output>  
    <p:output port="report" sequence="true">  
      <p:pipe step="tryvalidation" port="report"/>  
    </p:output>
    
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
                    @@@@@@@@@@@@@@@@@@@@@@
                    !!!VALIDATION ERROR!!!
                    !!!!!!!!!!!!!!!!!!!!!!
                    <xsl:copy-of select="."/>
                    !!!!!!!!!!!!!!!!!!!!!!
                    !!!VALIDATION ERROR!!!                    
                    @@@@@@@@@@@@@@@@@@@@@@
                  </xsl:message>    
                  <xsl:copy>
                    <xsl:apply-templates select="node() | @*"/>
                  </xsl:copy>
                </xsl:template>
                
              </xsl:stylesheet>
            </p:inline>
          </p:input>
          <p:input port="parameters" >
            <p:empty/>
          </p:input>
        </p:xslt>
      </p:catch>  
    </p:try>
    
  </p:declare-step>
  
  <cx:message>
    <p:with-option name="message" select="'Entering xproc pipeline'"/>
  </cx:message>
  
  <l:validate-transform name="validate-pre-xinclude">
    <p:input port="schema" sequence="true" >
      <p:document  href="classpath:/rng/rackbook.rng"/> <!--http://docs-beta.rackspace.com/oxygen/13.1/mac/author/frameworks/rackbook/5.0/-->
    </p:input>
  </l:validate-transform>
 
  <cx:message>
    <p:with-option name="message" select="'Performing xinclude'"/>
  </cx:message>
  
  <p:xinclude/>
  
  <cx:message>
    <p:with-option name="message" select="'Validating post-xinclude'"/>
  </cx:message>
  
  <l:validate-transform name="validate-post-xinclude">
    <p:input port="schema" sequence="true" >
      <p:document  href="classpath:/rng/rackbook.rng"/> <!--http://docs-beta.rackspace.com/oxygen/13.1/mac/author/frameworks/rackbook/5.0/-->
    </p:input>
  </l:validate-transform>

  <p:xslt name="programlisting-keep-together-xslt">
    <p:input port="source"> 
      <p:pipe step="validate-post-xinclude" port="result"/> 
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
              <xsl:if test="count(tokenize(.,'&#xA;')) &lt; $max">
                <xsl:processing-instruction name="rax-fo">keep-together</xsl:processing-instruction>
                <xsl:comment>linefeeds: <xsl:value-of select="count(tokenize(.,'&#xA;'))"/></xsl:comment>
              </xsl:if>
              <xsl:apply-templates select="node()"/>
            </xsl:copy>
          </xsl:template>
          
          <xsl:template match="processing-instruction('rax')[normalize-space(.) = 'fail']">
            <xsl:message terminate="yes">
              !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              &lt;?rax fail?> found in the document.
              !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            </xsl:message>
          </xsl:template>
          
        </xsl:stylesheet>
      </p:inline>
      <!--<p:document href="cloud/code-listing-keep-together.xsl"/>-->
    </p:input>
    <p:input port="parameters" >
      <p:empty/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="process-embedded-wadl">
    <p:input port="source"> 
      <p:pipe step="programlisting-keep-together-xslt" port="result"/> 
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
          
          <xsl:template match="/">
            <xsl:apply-templates/>
            <xsl:message>
              !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              THIS WORKS!!!!!!!!!!!!!!!!!!!
              !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            </xsl:message>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
      <!--<p:document href="cloud/process-embedded-wadl.xsl"/>-->
    </p:input>
    <p:input port="parameters" >
      <p:empty/>
    </p:input>
  </p:xslt>
  
  <cx:message>
    <p:with-option name="message" select="'Exiting xproc pipeline'"/>
  </cx:message>
  
</p:declare-step>
