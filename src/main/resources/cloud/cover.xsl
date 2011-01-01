<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:svg="http://www.w3.org/2000/svg"
                version="1.0">
    <xsl:param name="docbook.in" select="'doc.xml'"/>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:param name="textWithTitle">
            <xsl:call-template name="replaceTitle">
                <xsl:with-param name="in" select="."/>
            </xsl:call-template>
        </xsl:param>
        <xsl:copy-of select="$textWithTitle"/>
    </xsl:template>

    <xsl:template name="replaceTitle">
        <xsl:param name="in"/>
        <xsl:choose>
            <xsl:when test="contains($in,'$title$')">
                <xsl:call-template name="replaceText">
                    <xsl:with-param name="text" select="$in" />
                    <xsl:with-param name="replace" select="'$title$'"/>
                    <xsl:with-param name="with" select="'My Title'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="replaceText">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="with"/>

        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$with"/>
        <xsl:value-of select="substring-after($text,$replace)"/>
    </xsl:template>
</xsl:stylesheet>
