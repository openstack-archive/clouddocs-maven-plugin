<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:l="http://xproc.org/library"
  xmlns:db="http://docbook.org/ns/docbook"
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

  <p:add-xml-base/>
  
  <p:xinclude fixup-xml-base="true"/>

  <cx:message>
    <p:with-option name="message" select="'Validating post-xinclude'"/>
  </cx:message>

  <l:docbook-xslt2-preprocess/>

  <l:validate-transform name="validate-post-xinclude">
    <p:input port="schema">
      <p:document href="classpath:/rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform>

  <cx:message>
    <p:with-option name="message" select="'Validating images'"/>
  </cx:message>
  <l:validate-images/>

  <cx:message>
    <p:with-option name="message" select="'Performing programlisting keep together'"/>
  </cx:message>

  <l:programlisting-keep-together/>

  <p:delete match="//db:imageobject[@role='html']"/>
  <p:delete match="//db:imageobject/@role[. ='fo']"/>

  <cx:message>
    <p:with-option name="message" select="'Adding extension info'"/>
  </cx:message>
  
  <l:extensions-info/>
  
  <cx:message>
    <p:with-option name="message" select="'Making replacements'"/>
  </cx:message>
  <l:search-and-replace/>
    
  <cx:message>
    <p:with-option name="message" select="'Normalize wadls'"/>
  </cx:message>

  <l:normalize-wadls />

  <l:process-embedded-wadl/>
  <p:delete match="//@rax:original-wadl" xmlns:rax="http://docs.rackspace.com/api"/>
  <p:delete match="//db:td/db:para[not(./*) and normalize-space(.) ='']"/>
  
  <l:validate-transform-idrefs name="validate-post-wadl-idrefs">
    <p:input port="schema">
      <p:document href="classpath:/rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform-idrefs>
  
<!--  <p:identity/>-->
  
</p:declare-step>
