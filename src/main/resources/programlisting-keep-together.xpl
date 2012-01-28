<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:l="http://xproc.org/library"
    type="l:programlisting-keep-together"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
    name="main">
    
    <p:input port="source"/>
    <p:output port="result" primary="true">  
        <p:pipe step="programlisting-keep-together-xslt" port="result"/> 
    </p:output>  
    
    <p:xslt name="programlisting-keep-together-xslt">
        <p:input port="source"> 
            <p:pipe step="main" port="source"/> 
        </p:input> 
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:db="http://docbook.org/ns/docbook"
                    exclude-result-prefixes="xs" version="2.0">
                    
                    <xsl:template match="/">
                        <xsl:apply-templates/>
                        <xsl:message>
                            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            !!! In programlisting-keep-together-xslt !!!
                            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        </xsl:message>
                    </xsl:template>
                    
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