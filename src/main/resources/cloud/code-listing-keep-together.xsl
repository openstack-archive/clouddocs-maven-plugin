<?xml version="1.0" encoding="UTF-8"?>
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
            <xsl:if test="count(tokenize(.,'&#xA;')) &gt; $max">
                <xsl:processing-instruction name="dbfo">keep-together="always"</xsl:processing-instruction>
                <xsl:comment>linefeeds: <xsl:value-of select="count(tokenize(.,'&#xA;'))"/></xsl:comment>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>