<?xml version="1.0" encoding="utf-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:ml="http://xmlcalabash.com/ns/extensions/marklogic"
    xmlns:ut="http://grtjn.nl/ns/xproc/util"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    version="1.0">
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:declare-step version="1.0"
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:validate-transform-idrefs"
        name="main">
        
        <p:input port="source" primary="true"/> <!--sequence="false" primary="true"-->
        <p:input port="schema" sequence="true" >
            <p:document  href="classpath:///rng/rackbook.rng"/> 
        </p:input>

        <p:output port="result" primary="true">  
            <p:pipe step="tryvalidation" port="result"/>  
        </p:output>  
        <p:output port="report" sequence="true">  
            <p:pipe step="tryvalidation" port="report"/>  
        </p:output>

        <p:input port="parameters" kind="parameter"/>
        <ut:parameters name="params">
	  <p:input port="source">
	    <p:pipe step="main" port="parameters"/>
	  </p:input>
	</ut:parameters>
        <p:sink/>
        
        <p:try name="tryvalidation"> 
            <p:group> 
                <p:output port="result"> 
                    <p:pipe step="xmlvalidate" port="result"/>  
                </p:output> 
                <p:output port="report" sequence="true"> 
                    <p:empty/> 
                </p:output>      
                
                <p:validate-with-relax-ng name="xmlvalidate"  assert-valid="true" dtd-id-idref-warnings="true"> 
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
                    <p:pipe step="printerrors" port="result"/> 
                </p:output>
   	        <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
		  <p:pipe step="params" port="parameters"/>
		</p:variable>
		<p:variable name="invalidFile" select="concat($project.build.directory,'/',//c:param[@name = 'inputSrcFile']/@value,'-invalid-idrefs.xml')">
		  <p:pipe step="params" port="parameters"/>
		</p:variable>
                <p:store>
                    <p:with-option name="href" select="$invalidFile"/>
                    <p:input port="source">
                        <p:pipe port="source" step="main"/>
                    </p:input>
                </p:store>
                <p:xslt name="printerrors">
                    <p:input port="source">  
                        <p:pipe step="catch" port="error"/>  
                    </p:input>  
                    <p:input port="stylesheet">
                        <p:inline>
                            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

                                <xsl:param name="invalidFile"/>
                                <xsl:param name="failOnValidationError">yes</xsl:param>
                                <xsl:param name="failOnValidationErrorInternal">
                                    <xsl:choose>
                                        <xsl:when test="$failOnValidationError != 'yes' and $failOnValidationError != 'true' and $failOnValidationError != '1'">no</xsl:when>
                                        <xsl:otherwise>yes</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:param>
                                <xsl:template match="/">
<xsl:message><xsl:text>


@@@@@@@@@@@@@@@@@@@@@@
!!!VALIDATION ERRORS!!
!!!!!!!!!!!!!!!!!!!!!!

Note: Open the temporary file:

</xsl:text><xsl:value-of select="$invalidFile"/><xsl:text>

to see all the errors in context. 
You must correct the errors in the original 
source DocBook or wadl files however.

You can control whether build fails or not by 
setting failOnValidationError to no in your pom. 

</xsl:text><xsl:value-of select="concat('lineNumber: ', substring-after(c:errors,'lineNumber:'))"/><xsl:text>

!!!!!!!!!!!!!!!!!!!!!!
!!!VALIDATION ERRORS!!                    
@@@@@@@@@@@@@@@@@@@@@@

</xsl:text>
</xsl:message>          
<xsl:message terminate="{$failOnValidationErrorInternal}"/>
				</xsl:template>
                                
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                    <p:input port="parameters" >
                        <p:pipe step="main" port="parameters"/>
                    </p:input>
		    <p:with-param port="parameters" name="invalidFile" select="$invalidFile"/>    
                </p:xslt>
                <!--                <p:xslt name="id">
                    <p:input port="source">  
                        <p:pipe step="catch" port="error"/>  
                    </p:input>  
                    <p:input port="stylesheet">
                        <p:inline>
                            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                                
                                <xsl:param name="failOnValidationError">yes</xsl:param>
                                <xsl:param name="failOnValidationErrorInternal">
                                    <xsl:choose>
                                        <xsl:when test="$failOnValidationError != 'yes' and $failOnValidationError != 'true' and $failOnValidationError != '1'">no</xsl:when>
                                        <xsl:otherwise>yes</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:param>
                                
                                <xsl:param name="security"/>
                                
                                <xsl:template match="/">
                                    <xsl:message terminate="{$failOnValidationErrorInternal}"/>
                                </xsl:template>
                                
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                    <p:input port="parameters" >
                        <p:pipe step="main" port="parameters"/>
                    </p:input>
                </p:xslt>-->
            </p:catch>  
        </p:try>
        
    </p:declare-step>
    

    <p:declare-step version="1.0"
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:validate-transform"
        name="main">
        
        <p:input port="source" primary="true" /> 
        <p:input port="schema" sequence="true" >
            <p:document  href="classpath:///rng/rackbook.rng"/> 
        </p:input>

        <p:output port="result" primary="true">  
            <p:pipe step="tryvalidation" port="result"/>  
        </p:output>  
        <p:output port="report" sequence="true">  
            <p:pipe step="tryvalidation" port="report"/>  
        </p:output>

        <p:input port="parameters" kind="parameter"/>
        <ut:parameters name="params">
	  <p:input port="source">
	    <p:pipe step="main" port="parameters"/>
	  </p:input>
	</ut:parameters>
        <p:sink/>
        
        <p:try name="tryvalidation"> 
            <p:group> 
                <p:output port="result"> 
                    <p:pipe step="xmlvalidate" port="result"/>  
                </p:output> 
                <p:output port="report" sequence="true"> 
                    <p:empty/> 
                </p:output>                      
                <p:validate-with-relax-ng name="xmlvalidate"  assert-valid="true" dtd-id-idref-warnings="false"> 
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
                    <p:pipe step="printerrors" port="result"/> 
                </p:output>
   	        <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
		  <p:pipe step="params" port="parameters"/>
		</p:variable>
		<p:variable name="invalidFile" select="concat($project.build.directory,'/',//c:param[@name = 'inputSrcFile']/@value,'-invalid.xml')">
		  <p:pipe step="params" port="parameters"/>
		</p:variable>
                <p:store>
                    <p:with-option name="href" select="$invalidFile"/>
                    <p:input port="source">
                        <p:pipe port="source" step="main"/>
                    </p:input>
                </p:store>
                <p:xslt name="printerrors">
                    <p:input port="source">  
                        <p:pipe step="catch" port="error"/>  
                    </p:input>  
                    <p:input port="stylesheet">
                        <p:inline>
                            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                                <xsl:param name="invalidFile"/>
                                <xsl:param name="failOnValidationError">yes</xsl:param>
                                <xsl:param name="failOnValidationErrorInternal">
                                    <xsl:choose>
                                        <xsl:when test="$failOnValidationError != 'yes' and $failOnValidationError != 'true' and $failOnValidationError != '1'">no</xsl:when>
                                        <xsl:otherwise>yes</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:param>                                
                                <xsl:template match="/">
<xsl:message><xsl:text>


@@@@@@@@@@@@@@@@@@@@@@
!!!VALIDATION ERRORS!!
!!!!!!!!!!!!!!!!!!!!!!

Note: Open the temporary file:

</xsl:text><xsl:value-of select="$invalidFile"/><xsl:text>

to see all the errors in context. 
You must correct the errors in the original 
source DocBook or wadl files however.

You can control whether build fails or not by 
setting failOnValidationError to no in your pom. 

</xsl:text><xsl:value-of select="concat('lineNumber: ', substring-after(c:errors,'lineNumber:'))"/><xsl:text>

!!!!!!!!!!!!!!!!!!!!!!
!!!VALIDATION ERRORS!!                    
@@@@@@@@@@@@@@@@@@@@@@

</xsl:text>
</xsl:message>          
                                    <xsl:message terminate="{$failOnValidationErrorInternal}"/>
                                </xsl:template>                                
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                    <p:input port="parameters" >
                        <p:pipe step="main" port="parameters"/>
                    </p:input>  
		    <p:with-param port="parameters" name="invalidFile" select="$invalidFile"/>  
                </p:xslt>
            </p:catch>  
        </p:try>        
    </p:declare-step>
    
    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:programlisting-keep-together"
        xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
        name="keep-together">
        
        <p:input port="source"/>
        <p:output port="result" primary="true">  
            <p:pipe step="programlisting-keep-together-xslt" port="result"/> 
        </p:output>  
        
        <p:xslt name="programlisting-keep-together-xslt">
            <p:input port="source"> 
                <p:pipe step="keep-together" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:db="http://docbook.org/ns/docbook"
                        exclude-result-prefixes="xs" version="2.0">
                        
                        <xsl:template match="node() | @*">
                            <xsl:copy>
                                <xsl:apply-templates select="node() | @*"/>
                            </xsl:copy>
                        </xsl:template>
                        
                        <xsl:param name="max">15</xsl:param>
                        
                        <xsl:template match="db:programlisting">
                            <xsl:copy>
                                <xsl:apply-templates select="@*"/>
                                <xsl:if test="count(tokenize(.,'&#xA;')) &lt; $max">
                                    <xsl:processing-instruction name="dbfo">keep-together="always"</xsl:processing-instruction>
                                </xsl:if>
                                <xsl:apply-templates select="node()"/>
                            </xsl:copy>
                        </xsl:template>                                               
                    </xsl:stylesheet>
                </p:inline>
                <!--<p:document href="cloud/code-listing-keep-together.xsl"/>-->
            </p:input>
            <p:input port="parameters" >
                <p:empty/>
            </p:input>
        </p:xslt>
        
    </p:declare-step>

    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:programlisting-strip-inlines"
        xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
        name="strip-inlines">
        
        <p:input port="source"/>
        <p:output port="result" primary="true">  
            <p:pipe step="programlisting-strip-inlines-xslt" port="result"/> 
        </p:output>  
        
        <p:xslt name="programlisting-strip-inlines-xslt">
            <p:input port="source"> 
                <p:pipe step="strip-inlines" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:db="http://docbook.org/ns/docbook"
                        exclude-result-prefixes="xs" version="2.0">
                        
                        <xsl:template match="node() | @*">
                            <xsl:copy>
                                <xsl:apply-templates select="node() | @*"/>
                            </xsl:copy>
                        </xsl:template>
                        
                        <xsl:template match="*[(ancestor::db:programlisting or ancestor::db:screen or ancestor::db:literallayout ) and 
                                               (not(self::db:emphasis) and not(self::db:co) and not(self::db:replaceable) ) ]"><xsl:apply-templates select="node()"/></xsl:template>
                        <xsl:template match="db:programlisting">
                            <xsl:copy>
                                <xsl:apply-templates select="@*"/>
                                <xsl:apply-templates select="node()"/>
                            </xsl:copy>
                        </xsl:template>                                               
                    </xsl:stylesheet>
                </p:inline>

            </p:input>
            <p:input port="parameters" >
                <p:empty/>
            </p:input>
        </p:xslt>
        
    </p:declare-step>
    
    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:xhtml2docbook"
        xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
        name="main">
        
        <p:input port="source"/>
        
        <p:output port="result" primary="true">  
            <p:pipe step="xhtml2docbook" port="result"/> 
        </p:output>  
        
        <p:xslt name="xhtml2docbook">
            <p:input port="source"/> 
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet
                        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:xhtml="http://www.w3.org/1999/xhtml"
                        xmlns="http://docbook.org/ns/docbook"
                        exclude-result-prefixes="xhtml" version="2.0">
                        
                        <xsl:template match="node() | @*">
                            <xsl:copy>
                                <xsl:apply-templates select="node() | @*"/>
                            </xsl:copy>
                        </xsl:template>
                        
                        <xsl:template match="xhtml:p"  >
                            <para>
                                <xsl:if test="@class='shortdesc'"><xsl:attribute name="role">shortdesc</xsl:attribute></xsl:if>
                                <xsl:apply-templates />
                            </para>
                        </xsl:template>
                        
                        <xsl:template match="@class"/>
                        
                        <xsl:template match="xhtml:b|xhtml:strong">
                            <emphasis role="bold"><xsl:apply-templates/></emphasis>
                        </xsl:template>
                        
                        <xsl:template match="xhtml:a[@href]">
                            <link xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{@href}"><xsl:apply-templates /></link>
                        </xsl:template>
                        
                        <xsl:template match="xhtml:i|xhtml:em">
                            <emphasis><xsl:apply-templates  /></emphasis>
                        </xsl:template>
                        
                        <xsl:template match="xhtml:code|xhtml:tt">
                            <code><xsl:apply-templates  /></code>
                        </xsl:template>
                        
                        <xsl:template match="xhtml:span|xhtml:div">
                            <xsl:apply-templates  />
                        </xsl:template>
                        
                        <xsl:template match="xhtml:ul">
                            <itemizedlist>
                                <xsl:apply-templates/>			
                            </itemizedlist>
                        </xsl:template>
                        
                        <xsl:template match="xhtml:ol" >
                            <orderedlist>
                                <xsl:apply-templates/>			
                            </orderedlist>
                        </xsl:template>
                        
                        <!-- TODO: Try to make this less brittle. What if they have a li/ul or li/table? -->
                        <xsl:template match="xhtml:li[not(xhtml:p)]">
                            <listitem>
                                <para>
                                    <xsl:apply-templates/>	
                                </para>
                            </listitem>
                        </xsl:template>
                        
                        <xsl:template match="xhtml:li[xhtml:p]">
                            <listitem>
                                <xsl:apply-templates/>	
                            </listitem>
                        </xsl:template>
                        
                        <xsl:template match="xhtml:table">
                            <informaltable>
                                <xsl:copy-of select="@*"/>
                                <xsl:apply-templates  mode="xhtml2docbookns"/>
                            </informaltable>
                        </xsl:template>
                        
                        <xsl:template match="xhtml:pre">
                            <programlisting><xsl:apply-templates/></programlisting>
                        </xsl:template>
                        
                    </xsl:stylesheet>
                </p:inline>
                <!--<p:document href="cloud/process-embedded-wadl.xsl"/>-->
            </p:input>
            <p:input port="parameters" >
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:declare-step>
    
    
    
    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:extensions-info"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        version="1.0"
        name="extensions-info-step">
        
        <p:input port="source" primary="true"/>
        
        <p:output port="secondary" primary="false" sequence="true"/>
        <p:output port="result" primary="true" >
            <p:pipe step="extensions-info-xslt" port="result"/> 
        </p:output>
        
        <p:input port="parameters" kind="parameter"/>
        
        <p:xslt name="extensions-info-xslt">
            <p:input port="source"> 
                <p:pipe step="extensions-info-step" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:document href="classpath:///cloud/extensions.xsl"/>
            </p:input>
            <p:input port="parameters" >
                <p:pipe step="extensions-info-step" port="parameters"/>
            </p:input>
        </p:xslt>
        
        <p:for-each>
            <p:iteration-source>
                <p:pipe step="extensions-info-xslt" port="secondary"/>
            </p:iteration-source>
            <p:store encoding="utf-8" indent="true"
                omit-xml-declaration="false">
                <p:with-option name="href" select="base-uri(/*)"/>
            </p:store>
        </p:for-each>

    </p:declare-step>

    <p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library" type="l:normalize-wadls"
        xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
        name="normalize-wadls-step">
        
        <p:documentation>
            This step takes any wadls mentioned in the source document and normalizes them. 
        </p:documentation>

        <p:input port="source" primary="true"/>

        <p:output port="result" primary="true">
            <p:pipe step="group" port="result"/>
        </p:output>

        <p:input port="parameters" kind="parameter"/>

        <ut:parameters name="params"/>
        <p:sink/>

        <p:group name="group">
            <p:output port="result" primary="true">
                <p:pipe step="lists-files" port="result"/>
            </p:output>
            <p:output port="secondary" primary="false" sequence="true"/>

            <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
                <p:pipe step="params" port="parameters"/>
            </p:variable>

            <p:xslt name="lists-files">
                <p:input port="source">
                    <p:pipe step="normalize-wadls-step" port="source"/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="classpath:///cloud/list-wadls.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:pipe step="normalize-wadls-step" port="parameters"/>
                </p:input>
            </p:xslt>                        
            
            <p:for-each>
                <p:iteration-source select="//wadl-missing-file">
                    <p:pipe step="lists-files" port="secondary"/>
                </p:iteration-source>
                <p:variable name="href" select="/*/@href"/>
                <cx:message>
                    <p:with-option name="message" select="concat('WADL NOT FOUND: ',$href)"/>
                </cx:message>
            </p:for-each>

            <p:for-each>
                <p:iteration-source select="//wadl-missing-file">
                    <p:pipe step="lists-files" port="secondary"/>
                </p:iteration-source>
                <p:variable name="href" select="/*/@href"/>
                <p:error code="RAX001" >
                    <p:input port="source">
                        <p:inline>
                            <message>One or more wadls referred to could not be located.</message>
                        </p:inline>
                    </p:input>
                </p:error>
            </p:for-each>

            <p:for-each>
                <p:iteration-source select="//wadl">
                    <p:pipe step="lists-files" port="secondary"/>
                </p:iteration-source>
                <p:variable name="href" select="/*/@href"/>
                <p:variable name="newhref" select="/*/@newhref"/>
                <p:variable name="checksum" select="/*/@checksum"/>
                <p:variable name="targetHtmlContentDir" select="/*/@targetHtmlContentDir"/>
                <p:variable name="basefilename" select="/*/@basefilename"/>
                <p:load name="wadl">
                    <p:with-option name="href" select="$href"/>
                </p:load>
		    <p:xslt name="filter-wadl">
		      <!-- Filter normalized wadl based on security attr -->
                      <p:input port="source">
                        <p:pipe port="result" step="wadl"/>
                      </p:input>
                        <p:input port="stylesheet">
			  <p:inline>
			    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
					    xmlns:db="http://docbook.org/ns/docbook"
					    version="2.0">
			      <xsl:param name="security">external</xsl:param>
			      <xsl:template match="@*|node()">
				<xsl:if test="not(@db:security) or @db:security = $security">
				  <xsl:copy>
				    <xsl:apply-templates select="@*|node()"/>
				  </xsl:copy>
				</xsl:if>
			      </xsl:template>
			    </xsl:stylesheet>
			  </p:inline>
                        </p:input>
                        <p:input port="parameters">
                            <p:pipe step="normalize-wadls-step" port="parameters"/>
                        </p:input>		      
		    </p:xslt>
                    <p:xslt name="normalize-wadl">  
                        <p:input port="source">
                            <p:pipe port="result" step="filter-wadl"/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="classpath:///cloud/normalizeWadl/normalizeWadl.xsl"/>
                        </p:input>
                        <p:with-param name="checksum" select="$checksum"/>
                        <p:input port="parameters">
                            <p:pipe step="normalize-wadls-step" port="parameters"/>
                        </p:input>
                    </p:xslt>
                  <p:store encoding="utf-8" indent="true" omit-xml-declaration="false">
                   <p:with-option name="href" select="$newhref"/>
                  </p:store>
                <p:xslt name="clean-wadl">
                    <p:input port="source">
                        <p:pipe port="result" step="normalize-wadl"/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="classpath:///cloud/webhelp/clean-wadl.xsl"/>
                    </p:input>
                    <p:input port="parameters">
                        <p:pipe step="normalize-wadls-step" port="parameters"/>
                    </p:input>
                </p:xslt>
                <p:store encoding="utf-8" indent="true" omit-xml-declaration="false">
                    <p:with-option name="href" select="concat($targetHtmlContentDir,'/', $basefilename, '.wadl')"/>
                </p:store>
                  <p:xslt name="wadl2jsonx">
                      <p:input port="source">
                          <p:pipe port="result" step="normalize-wadl"/>
                      </p:input>
                      <p:input port="stylesheet">
                          <p:document href="classpath:///cloud/normalizeWadl/wadl2apiary-jsonx.xsl"/>
                      </p:input>
                      <p:input port="parameters">
                          <p:pipe step="normalize-wadls-step" port="parameters"/>
                      </p:input>
                  </p:xslt>
                  <p:xslt name="jsonx2json">
                    <p:input port="source">
                        <p:pipe port="result" step="wadl2jsonx"/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="classpath:///cloud/normalizeWadl/jsonx2json.xsl"/>
                    </p:input>
                    <p:input port="parameters">
                        <p:pipe step="normalize-wadls-step" port="parameters"/>
                    </p:input>
                   </p:xslt>
                  <p:store encoding="utf-8" indent="true" method="text">
                      <p:with-option name="href" select="concat($targetHtmlContentDir,'/', $basefilename, '.json')"/>
                   </p:store>
                <p:for-each>
                    <p:iteration-source>
                        <p:pipe step="normalize-wadl" port="secondary"/>
                    </p:iteration-source>
                    <p:store encoding="utf-8" indent="true" omit-xml-declaration="false">
                        <p:with-option name="href"
                            select="concat($project.build.directory,'/generated-resources/xml/xslt/',$checksum,'-',replace(base-uri(/*), '^(.*/)?([^/]+)$', '$2'))"
                        />
                    </p:store>
                </p:for-each>
                <p:for-each>
                    <p:iteration-source>
                        <p:pipe step="normalize-wadl" port="secondary"/>
                    </p:iteration-source>
                    <p:store encoding="utf-8" indent="true" omit-xml-declaration="false">
                        <p:with-option name="href"
                            select="concat($targetHtmlContentDir,'/', $checksum,'-',replace(base-uri(/*), '^(.*/)?([^/]+)$', '$2'))"
                        />
                    </p:store>
                </p:for-each>
           </p:for-each>
        </p:group>
        
    </p:declare-step>

    <p:declare-step 
        xmlns:l="http://xproc.org/library" 
        xml:id="search-and-replace"
        xmlns:c="http://www.w3.org/ns/xproc-step" 
        type="l:write-temp-file"  
        name="write-temp-file-step">
        
        
        <p:option name="prefix" cx:type="xsd:string" required="true"/>
        
        <p:input port="source" primary="true" sequence="true"/>
        
        <p:output port="result" sequence="true">
            <p:pipe step="group" port="result"/>
        </p:output>
        
        <p:input port="parameters" kind="parameter"/>
        <ut:parameters name="params"/>
        <p:sink/>
        
        <p:group name="group">
            <p:output port="result" primary="true">
                <p:pipe step="ident" port="result"/>
            </p:output>
            <p:output port="secondary" primary="false" sequence="true"/>
            
            <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
                <p:pipe step="params" port="parameters"/>
            </p:variable>
            
            <p:identity name="ident">
                <p:input port="source">
                    <p:pipe step="write-temp-file-step" port="source"/>
                </p:input>
            </p:identity>
            
            <p:store encoding="utf-8" indent="true" omit-xml-declaration="false" name="store">
                <p:input port="source">
                    <p:pipe step="write-temp-file-step" port="source"/>
                </p:input>
                <p:with-option name="href" select="concat($project.build.directory, $prefix,'-',replace(base-uri(/*), '^(.*/)?([^/]+)$', '$2'))" />
            </p:store>
            
        </p:group>
    </p:declare-step>

	<p:declare-step 
		xmlns:l="http://xproc.org/library" 
		xml:id="search-and-replace"
		xmlns:c="http://www.w3.org/ns/xproc-step" 
		type="l:search-and-replace"  
		name="search-and-replace-step">
      <p:input port="source" primary="true" sequence="true"/>
      <p:output port="result" sequence="true">
      	<p:pipe step="group" port="result"/>
      </p:output>
   
        <p:input port="parameters" kind="parameter"/>
        <ut:parameters name="params"/>
        <p:sink/>
   
        <p:group name="group">
            <p:output port="result" primary="true">
                <p:pipe step="replace" port="result"/>
            </p:output>

   	        <p:variable name="inputSrcFile" select="//c:param[@name = 'inputSrcFile']/@value">
                <p:pipe step="params" port="parameters"/>
            </p:variable>
   	        <p:variable name="targetDirectory" select="//c:param[@name = 'targetDirectory']/@value">
                <p:pipe step="params" port="parameters"/>
            </p:variable>
            <p:variable name="replacementsFile" select="//c:param[@name = 'replacementsFile']/@value">
                <p:pipe step="params" port="parameters"/>
            </p:variable>
			<cx:replace-text name="replace">
            	<p:input port="source">
                    <p:pipe step="search-and-replace-step" port="source"/>
                </p:input>
				<p:with-option name="replacements.file" select="$replacementsFile">
	  			</p:with-option>
			</cx:replace-text>
			<p:store encoding="utf-8" indent="true" omit-xml-declaration="false">
               <p:with-option name="href"
                select="concat($targetDirectory,'/',$inputSrcFile)"
                />
            </p:store>
		</p:group>   	        
   </p:declare-step>

   <!-- Search and replace calabash extension -->
   <p:declare-step 
   		type="cx:replace-text" 
   		xml:id="replace-text">
      <p:input port="source" primary="true" sequence="true"/>
      <p:output port="result" primary="true" sequence="true"/>
      <p:option name="replacements.file" cx:type="xsd:string"/>
   </p:declare-step>
    
    <!--+========================================================+
| Step parameters
|
| Short-cut for p:parameters which passes through input, and with primary parameters input.
+-->    
    <p:declare-step type="ut:parameters" name="current" >
        <p:input port="source" sequence="true" primary="true"/>
        <p:input port="in-parameters" kind="parameter" sequence="true" primary="true"/>
        <p:output port="result" sequence="true" primary="true">
            <!-- pipe input straight through to output -->
            <p:pipe step="current" port="source"/>
        </p:output>
        
        <!-- extra output port for cleaned params -->
        <p:output port="parameters" sequence="false" primary="false">
            <p:pipe step="params" port="result"/>
        </p:output>
        
        <p:parameters name="params">
            <p:input port="parameters">
                <p:pipe step="current" port="in-parameters"/>
            </p:input>
        </p:parameters>
    </p:declare-step>
    
    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:process-embedded-wadl"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        version="1.0"
        name="process-embedded-wadl-step">
        
        <p:input port="source" primary="true"/>
        
        <p:output port="result" primary="true">
            <p:pipe step="process-embedded-wadl-xslt-3" port="result"/>
        </p:output>
        
        <p:input port="parameters" kind="parameter"/>
        
        <p:xslt name="process-embedded-wadl-xslt-1">
            <p:input port="source"> 
                <p:pipe step="process-embedded-wadl-step" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:document href="classpath:///cloud/process-embedded-wadl-1.xsl"/>
            </p:input>
            <p:input port="parameters" >
                <p:pipe step="process-embedded-wadl-step" port="parameters"/>
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
                <p:pipe step="process-embedded-wadl-step" port="parameters"/>
            </p:input>
        </p:xslt>
 
        <p:xslt name="process-embedded-wadl-xslt-3">
            <p:input port="source"> 
                <p:pipe step="process-embedded-wadl-xslt-2" port="result"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:document href="classpath:///cloud/process-embedded-wadl-3.xsl"/>
            </p:input>
            <p:input port="parameters" >
                <p:pipe step="process-embedded-wadl-step" port="parameters"/>
            </p:input>
        </p:xslt>
        
    </p:declare-step>


    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:generate-war"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        version="1.0"
        name="generate-war-step">
        
        <p:input port="source"/>
        
        <p:output port="secondary" primary="false" sequence="true"/>
        <p:output port="result" primary="true">
	  <p:pipe step="generate-war-xslt" port="result"/>
	</p:output>
        
        <p:input port="parameters" kind="parameter"/>
        
        <p:xslt name="generate-war-xslt">
            <p:input port="source"> 
                <p:pipe step="generate-war-step" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:document href="target/docbkx/cloud/war/docbook.xsl"/>
            </p:input>
            <p:input port="parameters" >
                <p:pipe step="generate-war-step" port="parameters"/>
            </p:input>
        </p:xslt>
        
        <p:for-each>
            <p:iteration-source>
                <p:pipe step="generate-war-xslt" port="secondary"/>
            </p:iteration-source>
            <p:choose>
                <p:when test="ends-with(base-uri(/*),'.xml')">
                    <p:store encoding="utf-8" indent="true" method="xml" 
                        omit-xml-declaration="false">
                        <p:with-option name="href" select="base-uri(/*)"/>
                    </p:store>
                </p:when>
                <p:otherwise>
                    <p:xslt>
                        <p:input port="stylesheet">
                            <p:document href="target/docbkx/cloud/war/xhtml2html.xsl"/>
                        </p:input>
                    </p:xslt>
                   <!--
                       <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">                  

                        doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
                        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"                        
                   -->
                    <p:store encoding="utf-8" indent="true" method="xml" 
                        omit-xml-declaration="true" 
                        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" 
                        doctype-system="http://www.w3.org/TR/html4/loose.dtd">
                        <p:with-option name="href" select="base-uri(/*)"/>
                    </p:store>
                </p:otherwise>
            </p:choose>
        </p:for-each>

    </p:declare-step>

    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:docbook-xslt2-preprocess"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        version="1.0"
        name="docbook-xslt2-preprocess-step">
        
        <p:input port="source" primary="true"/>
        
        <p:output port="result" primary="true">
            <p:pipe step="group" port="result"/>
        </p:output>
        
        <p:input port="parameters" kind="parameter"/>
	<ut:parameters name="params"/>
        <p:sink/>

        <p:group name="group">
            <p:output port="result" primary="true">
                <p:pipe step="docbook-xslt2-preprocess-xslt" port="result"/>
            </p:output>
            <p:output port="secondary" primary="false" sequence="true"/>

            <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
                <p:pipe step="params" port="parameters"/>
            </p:variable>

            <p:variable name="targetDirectory" select="//c:param[@name = 'targetDirectory']/@value">
                <p:pipe step="params" port="parameters"/>
            </p:variable>

	    <p:load name="preprocess.xsl">
	      <p:with-option name="href"
			     select="concat(
			     (if ($targetDirectory != '') then $targetDirectory else $project.build.directory),
			     (if ($targetDirectory  = '') then '/docbkx' else ''),
			     '/cloud/war/preprocess.xsl')" >
		<p:empty/>
	      </p:with-option>		  
	    </p:load>

	    <p:xslt name="docbook-xslt2-preprocess-xslt">
	      <p:input port="source"> 
                <p:pipe step="docbook-xslt2-preprocess-step" port="source"/> 
	      </p:input> 
	      <p:input port="stylesheet">
		<p:pipe step="preprocess.xsl" port="result"/>
	      </p:input>
	      <p:input port="parameters" >
                <p:pipe step="docbook-xslt2-preprocess-step" port="parameters"/>
	      </p:input>
	    </p:xslt>                
	</p:group>
    </p:declare-step>

    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:process-embedded-wadl-war"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        version="1.0"
        name="process-embedded-wadl-step-war">
        
        <p:input port="source" primary="true"/>
        
        <p:output port="result" primary="true">
            <p:pipe step="process-embedded-wadl-xslt" port="result"/>
        </p:output>
        
        <p:input port="parameters" kind="parameter"/>
        
        <p:xslt name="process-embedded-wadl-xslt">
            <p:input port="source"> 
                <p:pipe step="process-embedded-wadl-step-war" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:document href="classpath:///cloud/process-embedded-wadl-standalone.xsl"/>
            </p:input>
            <p:input port="parameters" >
                <p:pipe step="process-embedded-wadl-step-war" port="parameters"/>
            </p:input>
        </p:xslt>
        
    </p:declare-step>
    
    
    
    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:add-stop-chunking-pis"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        version="1.0"
        name="add-stop-chunking-pis-step">
        
        <p:input port="source" primary="true"/>
        
        <p:output port="result" primary="true">
            <p:pipe step="add-stop-chunking-pis-xslt" port="result"/>
        </p:output>
        
        <p:input port="parameters" kind="parameter"/>
        
        <p:xslt name="add-stop-chunking-pis-xslt">
            <p:input port="source"> 
                <p:pipe step="add-stop-chunking-pis-step" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:document href="classpath:///cloud/war/add-stop-chunking-pis.xsl"/>
            </p:input>
            <p:input port="parameters" >
                <p:pipe step="add-stop-chunking-pis-step" port="parameters"/>
            </p:input>
        </p:xslt>
        
    </p:declare-step>
    
    
    
    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:bookinfo"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        version="1.0"
        name="bookinfo-step">
        
        <p:input port="source" primary="true"/>
        
        <p:output port="secondary" primary="false" sequence="true"/>
        
        <p:output port="result" primary="true">
            <p:pipe step="group" port="result"/>
        </p:output>
        
        <p:input port="parameters" kind="parameter"/>
	<ut:parameters name="params"/>
        <p:sink/>

        <p:group name="group">
            <p:output port="result" primary="true">
                <p:pipe step="bookinfo-xslt" port="result"/>
            </p:output>
            <p:output port="secondary" primary="false" sequence="true"/>

            <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
                <p:pipe step="params" port="parameters"/>
            </p:variable>

            <p:variable name="targetDirectory" select="//c:param[@name = 'targetDirectory']/@value">
                <p:pipe step="params" port="parameters"/>
            </p:variable>

	    <p:load name="bookinfo.xsl">
	      <p:with-option name="href"
			     select="concat(
			     (if ($targetDirectory != '') then $targetDirectory else $project.build.directory),
			     (if ($targetDirectory  = '') then '/docbkx' else ''),
			     '/cloud/webhelp/bookinfo.xsl')" >
		<p:empty/>
	      </p:with-option>		  
	    </p:load>
        
        <p:xslt name="bookinfo-xslt">
            <p:input port="source"> 
                <p:pipe step="bookinfo-step" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
	      <p:pipe step="bookinfo.xsl" port="result"/>
            </p:input>
            <p:input port="parameters" >
                <p:pipe step="bookinfo-step" port="parameters"/>
            </p:input>
        </p:xslt>
        
        <p:for-each>
            <p:iteration-source>
                <p:pipe step="bookinfo-xslt" port="secondary"/>
            </p:iteration-source>
            <p:choose>
                <p:when test="ends-with(base-uri(/*),'.xml')">
                    <p:store encoding="utf-8" indent="true" method="xml" 
                        omit-xml-declaration="false">
                        <p:with-option name="href" select="base-uri(/*)"/>
                    </p:store>
                </p:when>
                <p:otherwise>
                    <p:store encoding="utf-8" method="text"  media-type="text">
                        <p:with-option name="href" select="base-uri(/*)"/>
                    </p:store>
                </p:otherwise>
            </p:choose>
        </p:for-each>
	</p:group>        
    </p:declare-step>
    


	<p:declare-step
		xmlns:l="http://xproc.org/library"
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xml:id="validate-docbook-format"
		type="l:validate-docbook-format"
		name="validate-docbook-format-step">

		<p:input port="source" primary="true" sequence="true"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" primary="true">
			<p:pipe step="tryvalidation" port="result"/>
		</p:output>
		<p:output port="report" sequence="true">
			<p:pipe step="tryvalidation" port="report"/>
		</p:output>
		<p:option name="docbookNamespace" required="true" />
		<!-- p:variable name="docBookVersion" select="//*:book/@version/string()"/ -->
		<p:variable name="nameSpaceText" select="namespace-uri(/*)" />

        <p:try name="tryvalidation"> 
            <p:group> 
                <p:output port="result"> 
                    <p:pipe step="xmlvalidate" port="result"/>  
                </p:output> 
                <p:output port="report" sequence="true"> 
                    <p:empty/> 
                </p:output>      
                
                <p:choose name="xmlvalidate">
					<p:when test="$nameSpaceText!=$docbookNamespace" >	
						<p:output port="result">
							<p:pipe step="bad-document" port="result"/>
						</p:output>
						<p:output port="report" sequence="true">
							<p:inline>
								<c:errors xmlns:c="http://www.w3.org/ns/xproc-step">
								   <c:error line="1" column="1">Source XML is not a valid docbook 5 file</c:error>
								</c:errors>
							</p:inline>
						</p:output>
						<p:error xmlns:rax="http://www.rackspace.com/build/error" name="bad-document" code="rax:unsupported-version">
						   <p:input port="source">
							 <p:inline>
							   <message>
						@@@@@@@@@@@@@@@@@@@@@@
						!!!VALIDATION ERROR!!!
						!!!!!!!!!!!!!!!!!!!!!!
						The input document version is not supported by this build process. 
						Please upgrade your document to DocBook version 5. 
						Refer to the following link for more information http://wiki.openstack.org/Documentation/HowTo#docs.openstack.org_.28DocBook_5.29
						!!!!!!!!!!!!!!!!!!!!!!
						!!!VALIDATION ERROR!!!                    
						@@@@@@@@@@@@@@@@@@@@@@
								</message>
							 </p:inline>
						   </p:input>
						</p:error>
					</p:when>
					<p:otherwise>
						<p:output port="result">
							<p:pipe step="echo" port="result"/>
						</p:output>
						<p:output port="report" sequence="true">
							<p:empty />
						</p:output>
						<p:identity name="echo">
							<p:input port="source">
								<p:pipe step="validate-docbook-format-step" port="source"/>
							</p:input>
						</p:identity>
					</p:otherwise>
    	        </p:choose>     	        
            </p:group>  
            <p:catch name="catch">  
                <p:output port="result">  
                    <p:pipe step="validate-docbook-format-step" port="source"/>  
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
                                
                                <xsl:variable name="failOnValidationError">yes</xsl:variable>
                                <xsl:param name="failOnValidationErrorInternal">
                                    <xsl:choose>
                                        <xsl:when test="$failOnValidationError != 'yes' and $failOnValidationError != 'true' and $failOnValidationError != '1'">no</xsl:when>
                                        <xsl:otherwise>yes</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:param>
                                
                                <xsl:template match="node()|@*">
                                    <xsl:message terminate="{$failOnValidationErrorInternal}">
                                        <xsl:copy-of select="//message/text()"/>
                                    </xsl:message>    
                                    <xsl:copy>
                                        <xsl:apply-templates select="node() | @*"/>
                                    </xsl:copy>
                                </xsl:template>
                                
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                    <p:input port="parameters" >
                        <p:pipe step="validate-docbook-format-step" port="parameters"/>
                    </p:input>
                </p:xslt>
            </p:catch>  
        </p:try>
        
    </p:declare-step>
    
 	<p:declare-step 
	  xmlns:l="http://xproc.org/library" 
	  xmlns:c="http://www.w3.org/ns/xproc-step"
	  xml:id="validate-images"
	  type="l:validate-images"  
	  name="validate-images-step">
          <p:input port="source" primary="true" sequence="true"/>
          <p:output port="result" sequence="true">
            <p:pipe step="group" port="result"/>
          </p:output>
            <p:input port="parameters" kind="parameter"/>
            <ut:parameters name="params"/>
            <p:sink/>

            <p:group name="group">
                <p:output port="result" primary="true">
                    <p:pipe step="validateImages" port="result"/>
                </p:output>

                <!-- output type can be pdf of html -->
                <p:variable name="output.type" select="//c:param[@name = 'outputType']/@value">
                 <p:pipe step="params" port="parameters"/>
                </p:variable>
                <p:variable name="input.docbook.file" select="//c:param[@name = 'inputSrcFile']/@value">
                 <p:pipe step="params" port="parameters"/>
                </p:variable>
                <p:variable name="strict.image.validation" select="//c:param[@name = 'strictImageValidation']/@value">
                    <p:pipe step="params" port="parameters"/>
                </p:variable>

                <cx:copy-transform name="validateImages">
                    <p:input port="source">
                        <p:pipe step="validate-images-step" port="source"/>
                    </p:input>

                    <p:with-option name="inputFileName" select="concat($input.docbook.file,'')"/>
                    <p:with-option name="outputType" select="concat($output.type,'')"/>
                    <p:with-option name="fail-on-error" select="concat($strict.image.validation,'')"/>
                </cx:copy-transform>
            </p:group>
 		</p:declare-step>
    
 	<p:declare-step 
	  xmlns:l="http://xproc.org/library" 
	  xmlns:c="http://www.w3.org/ns/xproc-step"
	  xml:id="copy-and-transform-images"
	  type="l:copy-and-transform-images"  
	  name="copy-and-transform-images-step">
          <p:input port="source" primary="true" sequence="true"/>
          <p:output port="result" sequence="true">
            <p:pipe step="group" port="result"/>
          </p:output>

            <p:input port="parameters" kind="parameter"/>
            <ut:parameters name="params"/>
            <p:sink/>

            <p:group name="group">
                <p:output port="result" primary="true">
                    <p:pipe step="copyTransform" port="result"/>
                </p:output>

                <!-- output type can be pdf of html -->
                <p:variable name="output.type" select="//c:param[@name = 'outputType']/@value">
                 <p:pipe step="params" port="parameters"/>
                </p:variable>
                <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
                 <p:pipe step="params" port="parameters"/>
                </p:variable>
                <p:variable name="input.docbook.file" select="//c:param[@name = 'inputSrcFile']/@value">
                 <p:pipe step="params" port="parameters"/>
                </p:variable>
                <p:variable name="image.copy.dir" select="//c:param[@name = 'imageCopyDir']/@value">
                 <p:pipe step="params" port="parameters"/>
                </p:variable>
                <!-- this param is passed by WebhelpMojo and contains the path where final html output will be written.
                Comparing this path with the image copy dir param, we can find the relative path of the images to html -->
                <p:variable name="target.html.content.dir" select="//c:param[@name = 'targetHtmlContentDir']/@value">
                 <p:pipe step="params" port="parameters"/>
                </p:variable>

                <p:variable name="strict.image.validation" select="//c:param[@name = 'strictImageValidation']/@value">
                    <p:pipe step="params" port="parameters"/>
                </p:variable>

                <cx:copy-transform name="copyTransform">
                    <p:input port="source">
                        <p:pipe step="copy-and-transform-images-step" port="source"/>
                    </p:input>

                    <p:with-option name="target" select="concat($target.html.content.dir, '/figures')"/>
                    <p:with-option name="targetHtmlContentDir" select="$target.html.content.dir"/>
                    <p:with-option name="inputFileName" select="concat($input.docbook.file,'')"/>
                    <p:with-option name="outputType" select="concat($output.type,'')"/>
                    <p:with-option name="fail-on-error" select="concat($strict.image.validation,'')"/>
                </cx:copy-transform>
            </p:group>
 		</p:declare-step>
    
   <!-- copy and transform images calabash extension -->
   <p:declare-step 
   		type="cx:copy-transform" 
   		xml:id="copy-transform">

   		<p:input port="source" primary="true" sequence="true"/>
	    <p:output port="result" primary="true"/>
		<p:option name="target" required="false" cx:type="xsd:anyURI"/>
		<p:option name="targetHtmlContentDir" required="false" cx:type="xsd:anyURI"/>
		<p:option name="inputFileName" cx:type="xsd:string"/>
		<p:option name="outputType" cx:type="xsd:string"/>
	    <p:option name="fail-on-error" select="'true'" cx:type="xsd:boolean"/>
   </p:declare-step>
    
    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:process-pubdate"
        xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
        name="process-pubdate">
        
        <p:input port="source"/>
        <p:output port="result" primary="true">  
            <p:pipe step="process-pubdate-xslt" port="result"/> 
        </p:output>  
        
        <p:xslt name="process-pubdate-xslt">
            <p:input port="source"> 
                <p:pipe step="process-pubdate" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:xs="http://www.w3.org/2001/XMLSchema" 
			xmlns="http://docbook.org/ns/docbook"
			xmlns:db="http://docbook.org/ns/docbook"
                        exclude-result-prefixes="xs db cxf l ut c ml cx" 
			version="2.0">
                        
                        <xsl:template match="node() | @*">
                            <xsl:copy>
                                <xsl:apply-templates select="node() | @*"/>
                            </xsl:copy>
                        </xsl:template>
			
			<xsl:template match="db:pubdate">
			  <xsl:choose>
			    <xsl:when test="normalize-space(.) = ''">
			      <pubdate><xsl:value-of select="format-dateTime(current-dateTime(),'[Y]-[M,2]-[D,2]')"/></pubdate>
			    </xsl:when>
			    <xsl:when test="not(matches(normalize-space(.),'[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]'))">
			      <xsl:message terminate="yes">
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% ERROR                        %                       
				% Bad pubdate format!          %
				% "<xsl:value-of select="."/>" %
				% Please use YYYY-MM-DD format.%
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
			      </xsl:message>
			    </xsl:when>
			    <xsl:otherwise>
			      <xsl:copy>
                                <xsl:apply-templates select="node() | @*"/>
			      </xsl:copy>			      
			    </xsl:otherwise>
			  </xsl:choose>
			</xsl:template>

                     </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters" >
                <p:empty/>
            </p:input>
        </p:xslt>
        
    </p:declare-step>


    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:normalize-space-glossterm"
        xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
        name="normalize-space-glossterm">
        
        <p:input port="source"/>

        <p:output port="result" primary="true">  
            <p:pipe step="normalize-space-glossterm-xslt" port="result"/> 
        </p:output>  
        
        <p:xslt name="normalize-space-glossterm-xslt">
            <p:input port="source"> 
                <p:pipe step="normalize-space-glossterm" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:xs="http://www.w3.org/2001/XMLSchema" 
			xmlns:db="http://docbook.org/ns/docbook"
                        exclude-result-prefixes="xs" 
			version="2.0">
                        
                        <xsl:template match="node() | @*">
                            <xsl:copy>
                                <xsl:apply-templates select="node() | @*"/>
                            </xsl:copy>
                        </xsl:template>

                        <xsl:template match="db:glossterm[not(parent::db:glossentry) and not(./*)]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*"/>
				<xsl:value-of select="normalize-space(.)"/>
                            </xsl:copy>
                        </xsl:template>                                               

                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        
    </p:declare-step>


    <p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library" type="l:normalize-olinks"
        xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
        name="normalize-olinks">

        <p:documentation>This step turns olinks to xref if the
            targetdoc is the same as the current doc id. This assumes
            that we use the root element's xml:id as the current doc
            id. </p:documentation>

        <p:input port="source" primary="true"/>

        <p:output port="result" primary="true">
            <p:pipe step="normalize-olinks-xslt" port="result"/>
        </p:output>

        <p:xslt name="normalize-olinks-xslt">
            <p:input port="source">
                <p:pipe step="normalize-olinks" port="source"/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet
                        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:db="http://docbook.org/ns/docbook"
                        xmlns="http://docbook.org/ns/docbook"
                        exclude-result-prefixes="db cx cxf l xsd c ml ut"
                        version="2.0">

                        <xsl:template match="node() | @*">
                            <xsl:copy>
                                <xsl:apply-templates
                                   select="node() | @*"/>
                            </xsl:copy>
                        </xsl:template>

                        <xsl:template
                            match="db:olink[@targetdoc = /*/@xml:id]">
                            <xref linkend="{@targetptr}"/>
                        </xsl:template>

                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

    </p:declare-step>
    
    <p:declare-step 
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:transclusion-fixup"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        version="1.0"
        name="transclusion-fixup">
        
        <p:input port="source" primary="true"/>
        
        <p:output port="result" primary="true">
            <p:pipe step="transclusion-fixup-xslt" port="result"/>
        </p:output>
        
        <p:input port="parameters" kind="parameter"/>
        
        <p:xslt name="transclusion-fixup-xslt">
            <p:input port="source"> 
                <p:pipe step="transclusion-fixup" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:document href="classpath:///cloud/transclusion-fixup.xsl"/>
            </p:input>
            <p:input port="parameters" >
                <p:pipe step="transclusion-fixup" port="parameters"/>
            </p:input>
        </p:xslt>
        
    </p:declare-step>


</p:library>
