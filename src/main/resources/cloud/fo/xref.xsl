<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
		xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:exsl="http://exslt.org/common"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                exclude-result-prefixes="exsl xlink d"
                version='1.0'>

<!-- ********************************************************************
     $Id: xref.xsl 9723 2013-02-06 13:08:06Z kosek $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://docbook.sf.net/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->

<!-- Use internal variable for olink xlink role for consistency -->
<xsl:variable 
      name="xolink.role">http://docbook.org/xlink/role/olink</xsl:variable>


<xsl:template match="d:olink" name="olink">
  <!-- olink content may be passed in from xlink olink -->
  <xsl:param name="content" select="NOTANELEMENT"/>

  <xsl:choose>
    <!-- olinks resolved by stylesheet and target database -->
    <xsl:when test="@targetdoc or @targetptr or
                    (@xlink:role=$xolink.role and
                     contains(@xlink:href, '#') )" >

      <xsl:variable name="targetdoc.att">
        <xsl:choose>
          <xsl:when test="@targetdoc != ''">
            <xsl:value-of select="@targetdoc"/>
          </xsl:when>
          <xsl:when test="@xlink:role=$xolink.role and
                       contains(@xlink:href, '#')" >
            <xsl:value-of select="substring-before(@xlink:href, '#')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="targetptr.att">
        <xsl:choose>
          <xsl:when test="@targetptr != ''">
            <xsl:value-of select="@targetptr"/>
          </xsl:when>
          <xsl:when test="@xlink:role=$xolink.role and
                       contains(@xlink:href, '#')" >
            <xsl:value-of select="substring-after(@xlink:href, '#')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="olink.lang">
        <xsl:call-template name="l10n.language">
          <xsl:with-param name="xref-context" select="true()"/>
        </xsl:call-template>
      </xsl:variable>
    
      <xsl:variable name="target.database.filename">
        <xsl:call-template name="select.target.database">
          <xsl:with-param name="targetdoc.att" select="$targetdoc.att"/>
          <xsl:with-param name="targetptr.att" select="$targetptr.att"/>
          <xsl:with-param name="olink.lang" select="$olink.lang"/>
        </xsl:call-template>
      </xsl:variable>
    
      <xsl:variable name="target.database" 
          select="document($target.database.filename, /)"/>
    
      <xsl:if test="$olink.debug != 0">
        <xsl:message>
          <xsl:text>Olink debug: root element of target.database is '</xsl:text>
          <xsl:value-of select="local-name($target.database/*[1])"/>
          <xsl:text>'.</xsl:text>
        </xsl:message>
      </xsl:if>
    
      <xsl:variable name="olink.key">
        <xsl:call-template name="select.olink.key">
          <xsl:with-param name="targetdoc.att" select="$targetdoc.att"/>
          <xsl:with-param name="targetptr.att" select="$targetptr.att"/>
          <xsl:with-param name="olink.lang" select="$olink.lang"/>
          <xsl:with-param name="target.database" select="$target.database"/>
        </xsl:call-template>
      </xsl:variable>
    
      <xsl:if test="string-length($olink.key) = 0">
        <xsl:message>
          <xsl:text>Error: unresolved olink: </xsl:text>
          <xsl:text>targetdoc/targetptr = '</xsl:text>
          <xsl:value-of select="$targetdoc.att"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="$targetptr.att"/>
          <xsl:text>'.</xsl:text>
        </xsl:message>
      </xsl:if>

      <xsl:variable name="href">
	<!-- DWC: Hack to prevent olinks from being hot ever -->
        <!-- <xsl:call-template name="make.olink.href"> -->
        <!--   <xsl:with-param name="olink.key" select="$olink.key"/> -->
        <!--   <xsl:with-param name="target.database" select="$target.database"/> -->
        <!-- </xsl:call-template> -->
      </xsl:variable>

      <!-- Olink that points to internal id can be a link -->
      <xsl:variable name="linkend">
        <xsl:call-template name="olink.as.linkend">
          <xsl:with-param name="olink.key" select="$olink.key"/>
          <xsl:with-param name="olink.lang" select="$olink.lang"/>
          <xsl:with-param name="target.database" select="$target.database"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="hottext">
        <xsl:choose>
          <xsl:when test="string-length($content) != 0">
            <xsl:copy-of select="$content"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="olink.hottext">
              <xsl:with-param name="olink.key" select="$olink.key"/>
              <xsl:with-param name="olink.lang" select="$olink.lang"/>
              <xsl:with-param name="target.database" select="$target.database"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="olink.docname.citation">
        <xsl:call-template name="olink.document.citation">
          <xsl:with-param name="olink.key" select="$olink.key"/>
          <xsl:with-param name="target.database" select="$target.database"/>
          <xsl:with-param name="olink.lang" select="$olink.lang"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="olink.page.citation">
        <xsl:call-template name="olink.page.citation">
          <xsl:with-param name="olink.key" select="$olink.key"/>
          <xsl:with-param name="target.database" select="$target.database"/>
          <xsl:with-param name="olink.lang" select="$olink.lang"/>
          <xsl:with-param name="linkend" select="$linkend"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$linkend != ''">
          <fo:basic-link internal-destination="{$linkend}"
                       xsl:use-attribute-sets="xref.properties">
            <xsl:call-template name="anchor"/>
            <xsl:copy-of select="$hottext"/>
            <xsl:copy-of select="$olink.page.citation"/>
          </fo:basic-link>
        </xsl:when>
        <xsl:when test="$href != ''">
          <xsl:choose>
            <xsl:when test="$fop1.extensions != 0">
              <xsl:variable name="mybeg" select="substring-before($href,'#')"/>
              <xsl:variable name="myend" select="substring-after($href,'#')"/>
              <fo:basic-link external-destination="url({concat($mybeg,'#dest=',$myend)})"
                             xsl:use-attribute-sets="olink.properties">
                <xsl:copy-of select="$hottext"/>
              </fo:basic-link>
              <xsl:copy-of select="$olink.page.citation"/>
              <xsl:copy-of select="$olink.docname.citation"/>
            </xsl:when>
            <xsl:when test="$xep.extensions != 0">
              <fo:basic-link external-destination="url({$href})"
                             xsl:use-attribute-sets="olink.properties">
                <xsl:call-template name="anchor"/>
                <xsl:copy-of select="$hottext"/>
              </fo:basic-link>
              <xsl:copy-of select="$olink.page.citation"/>
              <xsl:copy-of select="$olink.docname.citation"/>
            </xsl:when>
            <xsl:when test="$axf.extensions != 0">
              <fo:basic-link external-destination="{$href}"
                             xsl:use-attribute-sets="olink.properties">
                <xsl:copy-of select="$hottext"/>
              </fo:basic-link>
              <xsl:copy-of select="$olink.page.citation"/>
              <xsl:copy-of select="$olink.docname.citation"/>
            </xsl:when>
            <xsl:otherwise>
              <fo:basic-link external-destination="{$href}"
                             xsl:use-attribute-sets="olink.properties">
                <xsl:copy-of select="$hottext"/>
              </fo:basic-link>
              <xsl:copy-of select="$olink.page.citation"/>
              <xsl:copy-of select="$olink.docname.citation"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$hottext"/>
          <xsl:copy-of select="$olink.page.citation"/>
          <xsl:copy-of select="$olink.docname.citation"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <!-- olink never implemented in FO for old olink entity syntax -->
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
