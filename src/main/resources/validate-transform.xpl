<?xml version="1.0" encoding="utf-8"?>
<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:l="http://xproc.org/library"
  type="l:validate-transform"
  name="main">
  
  <p:input port="source" primary="true"/> <!--sequence="false" primary="true"-->
  <p:input port="schema" sequence="true" >
    <p:document  href="classpath:///rng/rackbook.rng"/> <!--http://docs-beta.rackspace.com/oxygen/13.1/mac/author/frameworks/rackbook/5.0/-->
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
              
              <xsl:param name="failonerror">no</xsl:param>
              
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