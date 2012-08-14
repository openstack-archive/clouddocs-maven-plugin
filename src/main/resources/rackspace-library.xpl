<p:library xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:ml="http://xmlcalabash.com/ns/extensions/marklogic"
    xmlns:ut="http://grtjn.nl/ns/xproc/util"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    version="1.0">
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:declare-step version="1.0"
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:l="http://xproc.org/library"
        type="l:validate-transform"
        name="main">
        
        <p:input port="source" /> <!--sequence="false" primary="true"-->
        <p:input port="schema" sequence="true" >
            <p:document  href="classpath:/rng/rackbook.rng"/> <!--http://docs-beta.rackspace.com/oxygen/13.1/mac/author/frameworks/rackbook/5.0/-->
        </p:input>
        <p:input port="parameters" kind="parameter"/>
        
        <p:output port="result" primary="true">  
            <p:pipe step="tryvalidation" port="result"/>  
        </p:output>  
        <p:output port="report" sequence="true">  
            <p:pipe step="tryvalidation" port="report"/>  
        </p:output>
        
        <p:try name="tryvalidation"> 
            <p:group> 
                <p:output port="result"> 
                    <p:pipe step="xmlvalidate" port="result"/>  
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
                
            </p:group>  
            <p:catch name="catch">  
                <p:output port="result">  
                    <p:pipe step="main" port="source"/>  
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
                                
                                <xsl:param name="failOnValidationError">yes</xsl:param>
                                <xsl:param name="security"/>
                                
                                <xsl:template match="node()|@*">
                                    <xsl:message terminate="{$failOnValidationError}">
                                        @@@@@@@@@@@@@@@@@@@@@@
                                        !!!VALIDATION ERROR!!!
                                        !!!!!!!!!!!!!!!!!!!!!!
                                        <xsl:copy-of select="."/>
                                        !!!!!!!!!!!!!!!!!!!!!!
                                        !!!VALIDATION ERROR!!!                    
                                        @@@@@@@@@@@@@@@@@@@@@@
                                    </xsl:message>    
                                    <xsl:copy>
                                        <xsl:apply-templates select="node() | @*"/>
                                    </xsl:copy>
                                </xsl:template>
                                
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                    <p:input port="parameters" >
                        <p:pipe step="main" port="parameters"/>
                    </p:input>
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
                        
			<xsl:template match="*[(ancestor::db:programlisting and not(self::db:emphasis) and not(self::db:co)) or 
					       (ancestor::db:screen         and not(self::db:emphasis) and not(self::db:co)) or 
					       (ancestor::db:literallayout  and not(self::db:emphasis) and not(self::db:co))]"><xsl:apply-templates select="node() | @*"/></xsl:template>

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
        
        <p:input port="source"/>
        
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
                <p:document href="classpath:/cloud/extensions.xsl"/>
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

        <!-- 
            TODO: 
            * Test to make sure this works when wadls, xsds, are fetched over http, https 
            * Test with api.openstack.org xpl
        -->

        <p:input port="source"/>

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
                    <p:document href="classpath:/cloud/list-wadls.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:pipe step="normalize-wadls-step" port="parameters"/>
                </p:input>
            </p:xslt>
            
            <cx:message>
                <p:with-option name="message" select="'About to iterate over wadls'"/>
            </cx:message>
            
            
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
                <p:load name="wadl">
                    <p:with-option name="href" select="$href"/>
                </p:load>
                    <p:xslt name="normalize-wadl">  
                        <p:input port="source">
                            <p:pipe port="result" step="wadl"/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="classpath:/cloud/normalizeWadl/normalizeWadl.xsl"/>
                        </p:input>
                        <p:with-param name="checksum" select="$checksum"/>
                        <p:input port="parameters">
                            <p:pipe step="normalize-wadls-step" port="parameters"/>
                        </p:input>
                    </p:xslt>
                  <p:store encoding="utf-8" indent="true" omit-xml-declaration="false">
                   <p:with-option name="href" select="$newhref"/>
                  </p:store>
              <p:for-each>
              <p:iteration-source>
               <p:pipe step="normalize-wadl" port="secondary"/>
              </p:iteration-source>
              <p:store encoding="utf-8" indent="true" omit-xml-declaration="false">
               <p:with-option name="href"
                select="concat('file://',$project.build.directory,'/generated-resources/xml/xslt/',$checksum,'-',replace(base-uri(/*), '^(.*/)?([^/]+)$', '$2'))"
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
   	        <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
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
                select="concat('file://',$project.build.directory,'/docbkx/',$inputSrcFile)"
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
        
        <p:input port="source"/>
        
        <p:output port="result" primary="true">
            <p:pipe step="process-embedded-wadl-xslt" port="result"/>
        </p:output>
        
        <p:input port="parameters" kind="parameter"/>
        
        <p:xslt name="process-embedded-wadl-xslt">
            <p:input port="source"> 
                <p:pipe step="process-embedded-wadl-step" port="source"/> 
            </p:input> 
            <p:input port="stylesheet">
                <p:document href="classpath:/cloud/process-embedded-wadl.xsl"/>
            </p:input>
            <p:input port="parameters" >
                <p:pipe step="process-embedded-wadl-step" port="parameters"/>
            </p:input>
        </p:xslt>
        
    </p:declare-step>
</p:library>