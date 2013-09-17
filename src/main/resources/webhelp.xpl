<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:db="http://docbook.org/ns/docbook"
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

  <p:add-xml-base/>
  
  <p:xinclude fixup-xml-base="true"/>

  <l:normalize-olinks/>

  <cx:message>
    <p:with-option name="message" select="'Fixing pubdate if necessary'"/>
  </cx:message>
  <l:process-pubdate/>

  <p:delete match="//@security[. = '']"/>

  <cx:message>
    <p:with-option name="message" select="'Profiling'"/>
  </cx:message>
  <l:docbook-xslt2-preprocess/>
  
  <l:validate-transform name="validate-post-xinclude">
    <p:input port="schema">
      <p:document href="classpath:/rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform>

  <p:delete match="//@format[parent::db:imagedata and matches(normalize-space(.),'[sS][vV][gG]')]"/>
  <p:delete match="//db:imageobject[@role='fo']"/>
  <p:delete match="//db:imageobject/@role[. ='html']"/>

  <l:normalize-space-glossterm/>

  <cx:message>
    <p:with-option name="message" select="'Validating, copying and transforming images'"/>
  </cx:message>
  <l:copy-and-transform-images/>

  <cx:message  name="msg4">
    <p:with-option name="message" select="'Remove non-bold markup from inside code listings.'"/>
  </cx:message>
  <l:programlisting-strip-inlines/>

  <p:delete match="//raxm:metadata[./raxm:type = 'tutorial']" 
	    xmlns:raxm="http://docs.rackspace.com/api/metadata"/>

  <cx:message>
    <p:with-option name="message" select="'Generating bookinfo.xml'"/>
  </cx:message>
  <l:bookinfo/>

  <cx:message>
    <p:with-option name="message" select="'Adding extension info'"/>
  </cx:message>
  <l:extensions-info/>
      
  <cx:message>
    <p:with-option name="message" select="'Normalize wadls (if necessary)'"/>
  </cx:message>
  <l:normalize-wadls />
  
  <cx:message>
    <p:with-option name="message" select="'Process embedded wadls (if necessary)'"/>
  </cx:message>
  <l:process-embedded-wadl/>

  <p:delete match="//@rax:original-wadl" xmlns:rax="http://docs.rackspace.com/api"/>
 
  <cx:message>
    <p:with-option name="message" select="'Making replacements'"/>
  </cx:message>
  <l:search-and-replace/>

  <p:add-attribute match="//db:table[not(@role) and .//db:td]|//db:informaltable[not(@role) and .//db:td]" attribute-name="rules" attribute-value="all"/>
  <p:delete match="//db:td/db:para[not(./*) and normalize-space(.) ='']"/>
  
  <l:validate-transform-idrefs name="validate-post-wadl" >
    <p:input port="schema">
      <p:document href="classpath:/rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform-idrefs>
  
</p:declare-step>
