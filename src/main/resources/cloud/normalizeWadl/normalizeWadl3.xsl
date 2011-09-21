<?xml version="1.0" encoding="UTF-8"?>
<!-- 

This XSLT flattens or expands the path in the path attributes of the resource elements in the wadl. 

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02" xmlns="http://wadl.dev.java.net/2009/02" xmlns:xsd="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsd wadl xs xsl" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:param name="format">-format</xsl:param>
    <!-- path or tree -->
    
    <xsl:variable name="paths-tokenized">
        <xsl:apply-templates select="$normalizeWadl2" mode="tokenize-paths"/>
    </xsl:variable>

    <!-- keep-format mode means we don't touch the formatting -->
    <xsl:template match="node() | @*" mode="keep-format">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="keep-format"/>
        </xsl:copy>
    </xsl:template>

    <!--  prune-params mode: one final pass in tree-format mode where we prune redundant params  -->
    <xsl:template match="node() | @*" mode="prune-params">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="prune-params"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template 
        match="wadl:param" 
        mode="prune-params">
        <xsl:variable name="name" select="@name"/>
        <xsl:choose>
            <xsl:when test="parent::wadl:resource[ancestor::wadl:resource/wadl:param[(@style = 'template' or @style = 'header' or @style='matrix') and @name = $name]]"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*" mode="prune-params"/>
                </xsl:copy>
            </xsl:otherwise>                
        </xsl:choose>
    </xsl:template>

    <!-- Begin tree-format templates   -->

    <xsl:template match="node() | @*" mode="tree-format">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="tree-format"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:resources" mode="tree-format">
        <resources>
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="group">
                <xsl:with-param name="token-number" select="1"/>
                <xsl:with-param name="resources" select="wadl:resource"/>
            </xsl:call-template>
        </resources>
    </xsl:template>

    <xsl:template name="group">
        <xsl:param name="token-number"/>
        <xsl:param name="resources"/>
        <xsl:for-each-group select="$resources" group-by="wadl:tokens/wadl:token[$token-number]">

            <resource path="{current-grouping-key()}">
                <xsl:if test="count(wadl:tokens/wadl:token) = $token-number">
                    <xsl:apply-templates select="*[not(self::wadl:resource)]" mode="tree-format"/>
                </xsl:if>
                <!--
                <xsl:call-template name="group">
                    <xsl:with-param name="token-number" select="$token-number + 1"/>
                    <xsl:with-param name="resources" select="wadl:resource"/>
                </xsl:call-template>-->
                <xsl:call-template name="group">
                    <xsl:with-param name="token-number" select="1"/>
                    <xsl:with-param name="resources" select="wadl:resource"/>
                </xsl:call-template>
                <xsl:call-template name="group">
                    <xsl:with-param name="token-number" select="$token-number + 1"/>
                    <xsl:with-param name="resources" select="current-group()"/>
                </xsl:call-template>
            </resource>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="wadl:tokens" mode="tree-format"/>

    <!--  Tokenize paths  -->
    <xsl:template match="node() | @*" mode="tokenize-paths">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="tokenize-paths"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:resource" mode="tokenize-paths">
        <resource>
            <xsl:copy-of select="@*"/>
            <tokens>
                <xsl:for-each select="tokenize(replace(@path,'(.*)/$','$1'),'/')">
                    <token>
                        <xsl:value-of select="."/>
                    </token>
                </xsl:for-each>
            </tokens>
            <xsl:apply-templates select="node()" mode="tokenize-paths"/>
        </resource>
    </xsl:template>

    <!-- Begin path-format templates -->

    <xsl:template match="node() | @*" mode="path-format">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="path-format"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node() | @*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="copy"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:method[parent::wadl:resource]|wadl:param[ancestor::wadl:resource]" mode="path-format"/>

    <xsl:template match="wadl:resource[not(child::wadl:method)]" mode="path-format">
        <xsl:apply-templates select="wadl:resource" mode="path-format"/>
    </xsl:template>

    <xsl:template match="wadl:resource[wadl:method]" mode="path-format">
        <resource>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="path">
                <xsl:for-each select="ancestor-or-self::wadl:resource">
                    <xsl:sort order="ascending" select="position()"/>
                    <xsl:value-of select="replace(@path,'(.*)/$','$1')"/>
                    <xsl:if test="not(position() = last())">/</xsl:if>
                </xsl:for-each>
            </xsl:attribute>
            <xsl:apply-templates select="wadl:doc" mode="copy"/>
            <xsl:apply-templates select="ancestor-or-self::wadl:resource/wadl:param[@style = 'template' or @style = 'header' ]" mode="copy"/>
            <xsl:apply-templates select="wadl:method" mode="copy"/>
        </resource>
        <xsl:apply-templates mode="path-format"/>
    </xsl:template>

    <xsl:template match="processing-instruction('base-uri')|wadl:doc" mode="path-format"/>

</xsl:stylesheet>