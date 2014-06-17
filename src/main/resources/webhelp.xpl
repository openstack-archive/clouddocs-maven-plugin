<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:l="http://xproc.org/library"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" name="main">

  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result"/>
    
  <p:import href="classpath:///rackspace-library.xpl"/><!-- classpath:/// -->
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <l:validate-docbook-format  name="validate-docbook-format-webhelp">
    <p:with-option name="docbookNamespace" select="'http://docbook.org/ns/docbook'"/>
  </l:validate-docbook-format>

  <p:add-xml-base name="adding-xml-base-webhelp"/>
  
  <p:xinclude cx:mark-roots="true" cx:copy-attributes="true" fixup-xml-base="true" name="xincluding"/>
  
  <l:transclusion-fixup/>

  <l:normalize-olinks name="normalize-olinks"/>

  <l:process-pubdate name="process-pubdate-webhelp"/>

  <p:delete match="//@security[. = '']" name="delete-emtpy-security-attrs-webhelp"/>

  <l:docbook-xslt2-preprocess name="preprocess-docbook-xslt2-webhelp"/>
  
  <l:validate-transform name="validate-post-xinclude-webhelp">
    <p:input port="schema">
      <p:document href="classpath:///rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform>

  <p:delete match="//@format[parent::db:imagedata and matches(normalize-space(.),'[sS][vV][gG]')]"/>
  <p:delete match="//db:imageobject[@role='fo']"/>
  <p:delete match="//db:imageobject/@role[. ='html']"/>

  <l:normalize-space-glossterm/>

  <l:copy-and-transform-images/>

  <l:programlisting-strip-inlines/>

  <p:delete match="//raxm:metadata[./raxm:type = 'tutorial']" 
	    xmlns:raxm="http://docs.rackspace.com/api/metadata"/>

  <l:bookinfo/>

  <l:extensions-info/>
      
  <l:normalize-wadls />
  
  <l:process-embedded-wadl/>

  <p:delete match="//@rax:original-wadl" xmlns:rax="http://docs.rackspace.com/api"/>
 
  <l:search-and-replace/>

  <p:add-attribute match="//db:table[not(@role) and .//db:td]|//db:informaltable[not(@role) and .//db:td]" attribute-name="rules" attribute-value="all"/>
  <p:delete match="//db:td/db:para[not(./*) and normalize-space(.) ='']"/>
  
  <l:validate-transform-idrefs name="validate-post-wadl-pdf" >
    <p:input port="schema">
      <p:document href="classpath:///rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform-idrefs>
  
</p:declare-step>
