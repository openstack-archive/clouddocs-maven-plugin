<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:l="http://xproc.org/library"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" name="main">

  <p:input port="source"/>
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result"/>
    
  <p:import href="classpath:/rackspace-library.xpl"/><!-- classpath:/ -->
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>


  <cx:message>
    <p:with-option name="message" select="'Entering xproc pipeline'"/>
  </cx:message>

  <cx:message>
    <p:with-option name="message" select="'Validating DocBook version'"/>
  </cx:message>

  <l:validate-docbook-format>
    <p:with-option name="docbookNamespace" select="'http://docbook.org/ns/docbook'"/>
  </l:validate-docbook-format>

  <l:validate-transform name="validate-pre-xinclude">
    <p:input port="schema">
      <p:document href="classpath:/rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform>


  <p:add-xml-base/>
  
  <p:xinclude fixup-xml-base="true"/>

  <cx:message>
    <p:with-option name="message" select="'Validating post-xinclude'"/>
  </cx:message>
  
  <l:validate-transform name="validate-post-xinclude">
    <p:input port="schema">
      <p:document href="classpath:/rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform>

  <cx:message>
    <p:with-option name="message" select="'Validating, copying and transforming images'"/>
  </cx:message>
  <l:copy-and-transform-images/>

  <cx:message>
    <p:with-option name="message" select="'Performing programlisting keep together'"/>
  </cx:message>
  <l:programlisting-keep-together/>

  <cx:message>
    <p:with-option name="message" select="'Profiling'"/>
  </cx:message>
  <l:docbook-xslt2-preprocess/>

  <cx:message>
    <p:with-option name="message" select="'Generating bookinfo.xml'"/>
  </cx:message>
  <l:bookinfo/>

  <cx:message>
    <p:with-option name="message" select="'Adding extension info'"/>
  </cx:message>
  <l:extensions-info/>
  
  <cx:message>
    <p:with-option name="message" select="'Making replacements'"/>
  </cx:message>
  <l:search-and-replace/>
    
  <cx:message>
    <p:with-option name="message" select="'Normalize wadls (if necessary)'"/>
  </cx:message>
  <l:normalize-wadls />
  
  <cx:message>
    <p:with-option name="message" select="'Process embedded wadls (if necessary)'"/>
  </cx:message>
  <l:process-embedded-wadl/>

</p:declare-step>
