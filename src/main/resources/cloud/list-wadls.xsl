<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"
    xmlns:d="http://docbook.org/ns/docbook" 
    xmlns:rax="http://docs.rackspace.com/api"
    exclude-result-prefixes="xs" version="2.0">

    <!--    
        This xslt creates a list of wadls to be normalized 
        and calculates the output path for each wadl by
        concatenating the output directory location AND
        inserting a checksum of the original path. 
        This information is then passed back to the pipeline
        through a secondary port/xsl:result-document.
    -->

    <xsl:param name="project.build.directory"/>
    <xsl:param name="targetHtmlContentDir"/>

    <xsl:variable name="wadls">
        <xsl:for-each select="//wadl:resource[@href]|//wadl:resources[@href]">
            <xsl:variable name="href">
              <xsl:choose>
                <xsl:when test="starts-with(@href,'.') or contains(@href, ':/')"><xsl:value-of select="@href"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="concat('./',@href)"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="contains($href,'#')">
                    <wadl href="{resolve-uri(substring-before(normalize-space($href),'#'), base-uri())}"/>
                </xsl:when>
                <xsl:otherwise>
                    <wadl href="{resolve-uri(normalize-space($href), base-uri())}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="wadllist"> 
        <root>         
            <xsl:for-each
                select="distinct-values($wadls/wadl/@href)">
                <xsl:variable name="checksum" select="rax:checksum(.)"/>
                <xsl:variable name="wadl-filename" select="replace(., '^(.*/)?([^/]+)$', '$2')"/>
                <xsl:variable name="wadl-filename-base" select="if(contains($wadl-filename,'.')) then (string-join(tokenize($wadl-filename, '\.')[not(position() = last())],'.')) else $wadl-filename"/>
                <xsl:variable name="newhref" select="concat($project.build.directory,'/generated-resources/xml/xslt/',$checksum,'-',$wadl-filename)"/>
                <!-- Only add this wadl to the list if the new wadl does not already exist -->
                <xsl:choose>
                    <xsl:when test="unparsed-text-available(.)">
                        <xsl:choose>
                            <xsl:when test="not(unparsed-text-available($newhref))">
                                <wadl href="{.}" newhref="{$newhref}" checksum="{$checksum}" targetHtmlContentDir="{$targetHtmlContentDir}" basefilename="{$wadl-filename-base}"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <wadl-already-normalized href="{.}" newhref="{$newhref}" checksum="{$checksum}" targetHtmlContentDir="{$targetHtmlContentDir}" basefilename="{$wadl-filename-base}"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <wadl-missing-file href="{.}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </root>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:if test="count($wadllist//@basefilename) != count(distinct-values($wadllist//@basefilename))">
            <xsl:message>
                WARNING: This document contains more than one wadl with the same base file name.
            </xsl:message>
        </xsl:if>
        <xsl:result-document href="/tmp/wadllist.xml">
                <xsl:copy-of select="$wadllist/*"/>
        </xsl:result-document>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="wadl:resource[@href]|wadl:resources[@href]">
        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="contains(@href,'#')">
                    <xsl:value-of select="resolve-uri(substring-before(@href,'#'), base-uri(.))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="resolve-uri(@href, base-uri(.))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="suffix"><xsl:if test="contains(@href,'#')">#<xsl:value-of select="substring-after(@href,'#')"/></xsl:if></xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*[not(local-name(.) = 'href')]"/>
            <xsl:attribute name="href" select="concat($wadllist/root/*[@href = $href]/@newhref,$suffix)"/>
            <xsl:attribute name="remaphref" select="@href"/>
            <xsl:attribute name="remaphrefvar" select="$href"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <!-- Found these functions here: http://stackoverflow.com/questions/6753343/using-xsl-to-make-a-hash-of-xml-file -->
    <xsl:function name="rax:checksum" as="xs:integer">
        <xsl:param name="str" as="xs:string"/>
        <xsl:variable name="codepoints" select="string-to-codepoints($str)"/>
        <xsl:value-of select="rax:fletcher16($codepoints, count($codepoints), 1, 0, 0)"/>
    </xsl:function>
    
    <xsl:function name="rax:fletcher16">
        <xsl:param name="str" as="xs:integer*"/>
        <xsl:param name="len" as="xs:integer" />
        <xsl:param name="index" as="xs:integer" />
        <xsl:param name="sum1" as="xs:integer" />
        <xsl:param name="sum2" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$index ge $len">
                <xsl:sequence select="$sum2 * 256 + $sum1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="newSum1" as="xs:integer"
                    select="($sum1 + $str[$index]) mod 255"/>
                <xsl:sequence select="rax:fletcher16($str, $len, $index + 1, $newSum1,
                    ($sum2 + $newSum1) mod 255)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

	<xsl:template match="d:SXXP0005">
	  <!-- This stupid template is here to avoid SXXP0005 errors from Saxon -->
	  <xsl:apply-templates/>
	</xsl:template>

    
</xsl:stylesheet>
