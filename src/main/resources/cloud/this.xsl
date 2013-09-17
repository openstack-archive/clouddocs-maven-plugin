<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="d"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">
    <!--
        This replacement can happen on the title page.
    -->
    <xsl:template match="d:*[@role='this']" mode="titlepage.mode">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template match="d:productname[@role='this']">
        <xsl:call-template name="thisReference">
            <xsl:with-param name="this" select="/*/d:info/d:productname"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="thisReference">
        <xsl:param name="this"/>
        <xsl:choose>
            <xsl:when test="$this">
                <xsl:value-of select="$this"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="badMatch"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
