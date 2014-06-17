<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:l="http://xproc.org/library"
		xmlns:db="http://docbook.org/ns/docbook"
		xmlns:ut="http://grtjn.nl/ns/xproc/util"
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:cx="http://xmlcalabash.com/ns/extensions" name="main">

  <p:import href="classpath:///rackspace-library.xpl"/><!-- classpath:/// -->
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <p:input port="source" primary="true"/>
  <p:output port="result"/>

  <p:input port="parameters" kind="parameter"/>
  <ut:parameters name="params"/>
  <p:sink/>

  <p:group name="group">
    <p:output port="result" primary="true">
      <p:pipe step="validate-post-wadl-idrefs-pdf" port="result"/>
    </p:output>
    <p:output port="secondary" primary="false" sequence="true"/>
    
    <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
      <p:pipe step="params" port="parameters"/>
    </p:variable>
    <p:variable name="targetDirectory" select="//c:param[@name = 'targetDirectory']/@value">
      <p:pipe step="params" port="parameters"/>
    </p:variable>

    <l:validate-docbook-format name="validate-docbook-format">
      <p:input port="source">
	<p:pipe step="main" port="source"/>
      </p:input>
      <p:with-option name="docbookNamespace" select="'http://docbook.org/ns/docbook'"/>
    </l:validate-docbook-format>
    
    <p:xslt name="pdfprops">
      <p:input port="source">  
	<p:pipe step="main" port="source"/>  
      </p:input>  
      <p:input port="stylesheet">
	<p:inline>
	  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	    <xsl:param name="security"/>
	    <xsl:param name="branding">rackspace</xsl:param>
	    <xsl:param name="includeDateInPdfFilename">
	      <xsl:choose>
	        <xsl:when test="$branding = 'openstack'">0</xsl:when>
	        <xsl:otherwise>1</xsl:otherwise>
	      </xsl:choose>
	    </xsl:param>
	    <xsl:param name="pdfFilenameBase"/>
	    <xsl:template match="/">
	      <xsl:variable name="pubdate">
		<xsl:choose>
		  <xsl:when test="/*/db:info/db:pubdate and normalize-space(/*/db:info/db:pubdate) = ''"><xsl:value-of select="format-dateTime(current-dateTime(),'[Y]-[M,2]-[D,2]')"/></xsl:when>
		  <xsl:when test="/*/db:info/db:pubdate and not(matches(normalize-space(/*/db:info/db:pubdate),'[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]'))">
		    <xsl:message terminate="yes">
		      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		      % ERROR                        %                       
		      % Bad pubdate format!          %
		      % "<xsl:value-of select="/*/db:info/db:pubdate"/>" %
		      % Please use YYYY-MM-DD format.%
		      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
		    </xsl:message>
		    <xsl:value-of select="/*/db:info/db:pubdate"/>
		  </xsl:when>
		  <xsl:otherwise><xsl:value-of select="/*/db:info/db:pubdate"/></xsl:otherwise>
		</xsl:choose>
	      </xsl:variable>

<c:result xmlns:c="http://www.w3.org/ns/xproc-step">	
pdfsuffix=<xsl:if test="not($security = 'external') and not($security = '') and $pdfFilenameBase = ''">-<xsl:value-of select="$security"/></xsl:if><xsl:if test="/*/db:info/db:pubdate and $includeDateInPdfFilename = '1'">-<xsl:value-of select="translate($pubdate,'-','')"/></xsl:if>
</c:result>      
	    </xsl:template>
	  </xsl:stylesheet>
	</p:inline>
      </p:input>
      <p:input port="parameters" >
	<p:pipe step="main" port="parameters"/>
      </p:input>  
    </p:xslt>

    <p:store name="store" encoding="utf-8" method="text"  media-type="text">
      <p:with-option name="href" select="concat(
					 (if ($targetDirectory != '') then $targetDirectory else $project.build.directory),
					 (if ($targetDirectory  = '') then '/docbkx' else ''),
					 '/autopdf/pdf.properties')"/>
    </p:store>

    <p:add-xml-base name="adding-xml-base-pdf">
      <p:input port="source">
	<p:pipe step="main" port="source"/>
      </p:input>
    </p:add-xml-base>
    
    <p:xinclude cx:mark-roots="true" cx:copy-attributes="true" fixup-xml-base="true" name="xincluding-pdf"/>
    
    <l:transclusion-fixup/>

    <l:normalize-olinks name="normalize-olinks-pdf"/>

    <l:process-pubdate name="process-pubdate-pdf"/>

    <p:delete match="//@security[. = '']" name="delete-emtpy-security-attrs-pdf"/>

    <l:docbook-xslt2-preprocess name="preprocess-docbook-xslt2-pdf"/>

    <l:validate-transform name="validate-post-xinclude-pdf">
      <p:input port="schema">
	<p:document href="classpath:///rng/rackbook.rng"/>
      </p:input>
    </l:validate-transform>

    <l:validate-images name="validate-images-pdf"/>

    <l:programlisting-keep-together name="add-keep-togethers-to-codelistings-pdf"/>

    <p:delete match="//db:imageobject[@role='html']" name="remove-imageobject-role-html-pdf"/>
    <p:delete match="//db:imageobject/@role[. ='fo']" name="remove-imageobject-role-attrs-fo-pdf"/>

    <l:normalize-space-glossterm name="clean-glossterm-spaces-pdf"/>

    <l:extensions-info name="add-extensions-info-pdf"/>
        
    <l:normalize-wadls name="normalize-wadls-pdf"/>

    <l:process-embedded-wadl name="process-embedded-wadls-pdf"/>
    <p:delete match="//@rax:original-wadl" xmlns:rax="http://docs.rackspace.com/api" name="remove-rax-original-wadl-attr-pdf"/>

    <l:search-and-replace name="search-and-replace-pdf"/>
    
    <p:add-attribute match="//db:table[not(@role) and .//db:td]|//db:informaltable[not(@role) and .//db:td]" attribute-name="rules" attribute-value="all" name="add-rules-attr-to-tables-pdf"/>
    <p:delete match="//db:td/db:para[not(./*) and normalize-space(.) ='']" name="delete-empty-paras"/>
    
    <l:validate-transform-idrefs name="validate-post-wadl-idrefs-pdf">
      <p:input port="schema">
	       <p:document href="classpath:///rng/rackbook.rng"/>
      </p:input>
    </l:validate-transform-idrefs>

  </p:group>

</p:declare-step>
