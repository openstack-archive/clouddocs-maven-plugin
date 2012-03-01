<p:library xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:ml="http://xmlcalabash.com/ns/extensions/marklogic"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    version="1.0">
    
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
                        
                        <xsl:param name="max">8</xsl:param>
                        
                        <xsl:template match="db:programlisting">
                            <xsl:copy>
                                <xsl:apply-templates select="@*"/>
                                <xsl:if test="count(tokenize(.,'&#xA;')) &lt; $max">
                                    <xsl:processing-instruction name="rax-fo">keep-together</xsl:processing-instruction>
                                    <xsl:comment>linefeeds: <xsl:value-of select="count(tokenize(.,'&#xA;'))"/></xsl:comment>
                                </xsl:if>
                                <xsl:apply-templates select="node()"/>
                            </xsl:copy>
                        </xsl:template>
                        
                        <xsl:template match="processing-instruction('rax')[normalize-space(.) = 'fail']">
                            <xsl:message terminate="yes">
                                !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                &lt;?rax fail?> found in the document.
                                !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            </xsl:message>
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
    
</p:library>