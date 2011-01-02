<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:svg="http://www.w3.org/2000/svg"
                version="1.0">
    <xsl:param name="docbook.infile" select="'/Users/jorgew/projects/cloud-files-api-docs/src/docbkx/cfdevguide_d5.xml'"/>
    <xsl:param name="docbook" select="document(concat('file://',$docbook.infile))"/>
    <xsl:param name="plaintitle">
        <xsl:choose>
            <xsl:when test="$docbook/d:book/d:title">
                <xsl:copy-of select="$docbook/d:book/d:title"/>
            </xsl:when>
            <xsl:when test="$docbook/d:book/d:info/d:title">
                <xsl:copy-of select="$docbook/d:book/d:info/d:title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:text>This template requires a docbook title!</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="plainsubtitle">
        <xsl:choose>
            <xsl:when test="$docbook/d:book/d:subtitle">
                <xsl:copy-of select="$docbook/d:book/d:subtitle"/>
            </xsl:when>
            <xsl:when test="$docbook/d:book/d:info/d:subtitle">
                <xsl:copy-of select="$docbook/d:book/d:info/d:subtitle"/>
            </xsl:when>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="productname">
        <xsl:copy-of select="$docbook/d:book/d:info/d:productname"/>
    </xsl:param>
    <xsl:param name="title">
        <xsl:choose>
            <!--
                If there's a product name, and the product name is in the
                subtitle then use the product name for the title.
            -->
            <xsl:when test="$productname and contains($plaintitle,$productname)">
                <xsl:copy-of select="$productname"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$plaintitle"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="subtitle">
        <xsl:choose>
            <xsl:when test="$productname and contains($plaintitle,$productname)">
                <xsl:value-of select="substring-before($plaintitle,$productname)"/>
                <xsl:value-of select="substring-after($plaintitle,$productname)"/>
            </xsl:when>
            <xsl:when test="$plainsubtitle">
                <xsl:value-of select="$plainsubtitle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Missing &lt;subtitle/&gt; docbook tag!</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="releaseinfo">
        <xsl:choose>
            <xsl:when test="$docbook//d:info[1]/d:releaseinfo">
                <xsl:value-of select="$docbook//d:info[1]/d:releaseinfo"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:text>This template requires the &lt;releaseinfo/&gt; docbook tag!</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="pubdate">
        <xsl:choose>
            <xsl:when test="$docbook//d:info[1]/d:pubdate">
                <xsl:value-of select="$docbook//d:info[1]/d:pubdate"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>This template requires the &lt;pubdate/&gt; docbook tag!</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>

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
