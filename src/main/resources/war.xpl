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
    <p:with-option name="message" select="'Entering xproc pipeline: war'"/>
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
  
  <l:programlisting-keep-together name="programlisting-keep-together"/>
  
  <l:generate-war name="my-generate-war"/>

  <cx:message>
    <p:with-option name="message" select="'Exiting xproc pipeline: war'"/>
  </cx:message>

</p:declare-step>
