<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:svg="http://www.w3.org/2000/svg"
                version="1.0">
    <xsl:param name="docbook.in" select="'doc.xml'"/>
    <xsl:param name="title" select="'My Title'"/>
    <xsl:param name="subtitle" select="'My SubTitle'"/>
    <xsl:param name="releaseinfo" select="'V1.0'"/>
    <xsl:param name="pubdate" select="'1/1/2010'"/>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:param name="textWithTitle">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="."/>
                <xsl:with-param name="replace" select="'$title$'"/>
                <xsl:with-param name="with" select="$title"/>
            </xsl:call-template>
        </xsl:param>
        <xsl:param name="textWithSubTitle">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="$textWithTitle"/>
                <xsl:with-param name="replace" select="'$subtitle$'"/>
                <xsl:with-param name="with" select="$subtitle"/>
            </xsl:call-template>
        </xsl:param>
        <xsl:param name="textWithReleaseInfo">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="$textWithSubTitle"/>
                <xsl:with-param name="replace" select="'$releaseinfo$'"/>
                <xsl:with-param name="with" select="$releaseinfo"/>
            </xsl:call-template>
        </xsl:param>
        <xsl:param name="textWithPubDate">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="$textWithReleaseInfo"/>
                <xsl:with-param name="replace" select="'$pubdate$'"/>
                <xsl:with-param name="with" select="$pubdate"/>
            </xsl:call-template>
        </xsl:param>
        <xsl:copy-of select="$textWithPubDate"/>
    </xsl:template>

    <xsl:template name="replaceText">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="with"/>

        <xsl:choose>
            <xsl:when test="contains($text,$replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$with"/>
                <xsl:value-of select="substring-after($text,$replace)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
