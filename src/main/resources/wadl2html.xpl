<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:l="http://xproc.org/library"
  xmlns:classpath="http://docs.rackspace.com/api"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  name="main">
  
  <p:input port="source"/> 
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="classpath:/rackspace-library.xpl"/>
  
  <cx:message>
    <p:with-option name="message" select="'Entering xproc pipeline'"/>
  </cx:message>
  
  <l:validate-transform name="validate-pre-xinclude">
    <p:input port="schema" >
      <p:document href="classpath:/rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform>
 
  <p:add-xml-base/>
  <p:xinclude fixup-xml-base="true"/>
  
  <cx:message>
    <p:with-option name="message" select="'Validating post-xinclude'"/>
  </cx:message>
  
  <l:validate-transform name="validate-post-xinclude">
    <p:input port="schema" >
      <p:document  href="classpath:/rng/rackbook.rng"/> 
    </p:input>
  </l:validate-transform>
  
  <l:normalize-wadls name="normalize"/>
      
  <p:xslt name="process-embedded-wadl">
    <p:input port="source"> 
      <p:pipe step="normalize" port="result"/> 
    </p:input> 
    <p:input port="stylesheet">
      <p:document href="classpath:/cloud/apipage/process-embedded-wadl-apipage.xsl"/>
    </p:input>
    <p:input port="parameters" >
      <p:empty/>
    </p:input>
  </p:xslt>
  
<!--  <l:xhtml2docbook name="xhtml2docbook"/>   -->
  
 <!--
  <l:programlisting-keep-together name="programlisting-keep-together"/>
  -->
  
  <p:xslt name="docbook2apipage">
    <p:input port="source"> 
      <p:pipe step="process-embedded-wadl" port="result"/> 
    </p:input> 
    <p:input port="stylesheet">
      <p:document href="classpath:/cloud/apipage/apipage-main.xsl"/>
    </p:input>
    <p:input port="parameters" >
      <p:empty/>
    </p:input>
  </p:xslt>
  
<!--  <p:xslt name="foo">
    <p:input port="source"> 
      <p:pipe step="process-embedded-wadl" port="result"/> 
    </p:input> 
    <p:input port="stylesheet">
      <p:inline>
        
      </p:inline>
    </p:input>
  </p:xslt>-->
  
  <cx:message>
    <p:with-option name="message" select="'Exiting xproc pipeline'"/>
  </cx:message>
  
</p:declare-step>
