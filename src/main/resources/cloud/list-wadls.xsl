<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:variable name="wadls">
        <xsl:for-each
            select="//wadl:resource[@href]|//wadl:resources[@href]">
            <xsl:choose>
                <xsl:when test="contains(@href,'#')">
                    <wadl
                        href="{resolve-uri(substring-before(@href,'#'), base-uri(.))}"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <wadl href="{resolve-uri(@href,base-uri(.))}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="wadls-distinct">
        <xsl:for-each select="distinct-values($wadls/wadl/@href)">
            <xsl:if test="not(document(.)/*)">
                <xsl:message>
                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    WADL-file not found! <xsl:value-of select="."/>
                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                </xsl:message>
            </xsl:if>
            <wadl href="{.}"/>
        </xsl:for-each>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:result-document href="/tmp/wadllist.xml">
            <root>
                <xsl:for-each
                    select="distinct-values($wadls/wadl/@href)">
                    <xsl:if test="not(document(.)/*)">
                        <xsl:message terminate="yes"/>
                    </xsl:if>
                    <xsl:for-each
                        select="distinct-values($wadls/wadl/@href)">
                        <wadl href="{.}"/>
                    </xsl:for-each>
                </xsl:for-each>
            </root>
        </xsl:result-document>

        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>