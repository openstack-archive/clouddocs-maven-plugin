<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:l="http://xproc.org/library"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:classpath="http://docs.rackspace.com/api"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  name="main">
  
  <p:input port="source" primary="true"/> 
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="classpath:///rackspace-library.xpl"/>
    
  <l:validate-transform name="validate-pre-xinclude">
    <p:input port="schema" >
      <p:document href="classpath:///rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform>
 
  <p:add-xml-base/>
  <p:xinclude fixup-xml-base="true"/>
  
  <l:validate-transform name="validate-post-xinclude">
    <p:input port="schema" >
      <p:document  href="classpath:///rng/rackbook.rng"/> 
    </p:input>
  </l:validate-transform>
  
  <l:normalize-wadls name="normalize"/>
    
    <p:xslt name="process-embedded-wadl-xslt-1">
      <p:input port="source"> 
        <p:pipe step="normalize" port="result"/> 
      </p:input> 
      <p:input port="stylesheet">
        <p:document href="classpath:///cloud/process-embedded-wadl-1.xsl"/>
      </p:input>
      <p:input port="parameters" >
        <p:pipe step="main" port="parameters"/>
      </p:input>
    </p:xslt>          
    
    <p:xslt name="process-embedded-wadl-xslt-2">
      <p:input port="source"> 
        <p:pipe step="process-embedded-wadl-xslt-1" port="result"/> 
      </p:input> 
      <p:input port="stylesheet">
        <p:document href="classpath:///cloud/process-embedded-wadl-2.xsl"/>
      </p:input>
      <p:input port="parameters" >
        <p:pipe step="main" port="parameters"/>
      </p:input>
    </p:xslt>
    
  
  <p:xslt name="docbook2apipage">
    <p:input port="source"> 
      <p:pipe step="process-embedded-wadl-xslt-2" port="result"/> 
    </p:input> 
    <p:input port="stylesheet">
      <p:document href="classpath:///cloud/apipage/apipage-main.xsl"/>
    </p:input>
    <p:input port="parameters" >
      <p:pipe step="main" port="parameters"/>
    </p:input>
  </p:xslt>
      
</p:declare-step>
