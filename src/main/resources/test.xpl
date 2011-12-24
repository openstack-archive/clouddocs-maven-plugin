<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  name="main">
  
  <p:input port="source" /> <!--sequence="false" primary="true"-->
  <p:input port="schema" sequence="true" >
    <p:document  href="rng/rackbook.rng"/> <!--http://docs-beta.rackspace.com/oxygen/13.1/mac/author/frameworks/rackbook/5.0/-->
  </p:input>
<!--  <p:input port="stylesheet" sequence="true">
    <p:document href="test.xsl"/>
  </p:input>-->
  
  <p:output port="result" primary="true">  
    <p:pipe step="tryvalidation" port="result"/>  
  </p:output>  
  <p:output port="report" sequence="true">  
    <p:pipe step="tryvalidation" port="report"/>  
  </p:output>
  <p:serialization port="report" indent="true"/>
  <p:try name="tryvalidation"> 
    <p:group> 
      <p:output port="result"> 
        <p:pipe step="programlisting-keep-together-xslt" port="result"/>  
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
      
      <p:xslt name="programlisting-keep-together-xslt">
        <p:input port="stylesheet">
          <p:document href="cloud/code-listing-keep-together.xsl"/>
        </p:input>
        <p:input port="parameters" sequence="true">
          <p:empty/>
        </p:input>
      </p:xslt>
      
    </p:group>  
    <p:catch name="catch">  
      <p:output port="result">  
        <p:pipe step="main" port="source"/>  
      </p:output>  
      <p:output port="report">  
        <p:pipe step="id" port="result"/> 
      </p:output>  
<!--      <p:error name="relaxng-validation-error" code="rax:E001" xmlns:rax="http://docs.rackspace.com/api">
        <p:input port="source">
          <p:inline><message>This document is invalid. No docs for you!</message></p:inline>
        </p:input>
        <p:log port="result" />
      </p:error>-->
      <p:identity name="id">  
        <p:input port="source">  
          <p:pipe step="catch" port="error"/>  
        </p:input>  
      </p:identity>
    </p:catch>  
  </p:try>
  

  
</p:declare-step>
