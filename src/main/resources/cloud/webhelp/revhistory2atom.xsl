<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="http://exslt.org/dates-and-times" 
    xmlns:db="http://docbook.org/ns/docbook" 
    exclude-result-prefixes="date db"
    xmlns="http://www.w3.org/2005/Atom" 
    version="1.0">
    
    <xsl:param name="canonical.url.base">http://docs.rackspace.com/product/api/v1.0</xsl:param>

    <xsl:template name="revhistory2atom">
        <xsl:if test="//db:revhistory/db:revision">
          <xsl:call-template name="write.chunk">
            <xsl:with-param name="filename"><xsl:value-of select="concat($webhelp.base.dir,'/','atom.xml')"/></xsl:with-param>
            <xsl:with-param name="method" select="'xml'"/>
            <xsl:with-param name="encoding" select="'utf-8'"/>
            <xsl:with-param name="indent" select="'yes'"/>
            <xsl:with-param name="doctype-public" select="''"/> <!-- intentionally blank --> 
            <xsl:with-param name="doctype-system" select="''"/> <!-- intentionally blank -->
            <xsl:with-param name="content">
                 <xsl:apply-templates select="//db:revhistory[1]"/>
            </xsl:with-param>
          </xsl:call-template>
            </xsl:if>
    </xsl:template>

    <xsl:template match="db:revhistory">
        <xsl:variable name="escapechars"> &amp;"'&lt;?</xsl:variable>
        <feed>
            <title>Revision history for <xsl:value-of select="//db:title[1]"/></title>
            <link href="{$canonical.url.base}/atom.xml" rel="self"/>
            <link href="{$canonical.url.base}/content/index.html"/>
            <id>
                <xsl:choose>
                    <xsl:when test="/*/@xml:id"><xsl:value-of select="/*/@xml:id"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="translate(//title[1],$escapechars,'_')"/></xsl:otherwise>
                </xsl:choose>
                </id>
            <updated>
                <xsl:call-template name="datetime.format">  
                    <xsl:with-param name="date" select="date:date-time()"/>  
                    <xsl:with-param name="format" select="'Y-m-d'"/>  
                </xsl:call-template>T<xsl:call-template name="datetime.format">  
                    <xsl:with-param name="date" select="date:date-time()"/>  
                    <xsl:with-param name="format" select="'X'"/>  
                </xsl:call-template>
            </updated>
            <xsl:apply-templates select="db:revision"/>
        </feed>
    </xsl:template>

    <xsl:template match="db:revision">
        <entry>
            <title>
                <xsl:choose>
                    <xsl:when test="db:revnumber"><xsl:value-of select="db:revnumber"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="db:date"/></xsl:otherwise>
                </xsl:choose>
            </title>
            <link type="text/html" href="{$canonical.url.base}/content/index.html"/>
            <id><xsl:value-of select="concat(/*/@xml:id,'-',db:date)"/></id>
            <updated><xsl:value-of select="db:date"/></updated>
            <content type="xhtml"><xsl:apply-templates select="db:revdescription|db:revremark"/></content>
        </entry>
    </xsl:template>

    <xsl:template match="db:revdescription">
        <div xmlns="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

</xsl:stylesheet>