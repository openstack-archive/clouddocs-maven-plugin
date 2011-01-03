<?xml version="1.0"?>
<xsl:stylesheet exclude-result-prefixes="d"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

  <xsl:import href="urn:docbkx:stylesheet-orig" />
  <xsl:import href="urn:docbkx:stylesheet-orig/highlight.xsl" />
  <xsl:import href="titlepage.templates.xsl"/>

  <!-- Front-Cover Background Image, should be set by the plugin -->
  <xsl:param name="cloud.api.background.image" select="'images/cover.svg'"/>
  <xsl:param name="cloud.api.cc.image.dir" select="'images/cc/'"/>

  <xsl:variable name="plaintitle">
      <xsl:choose>
          <xsl:when test="/*/d:title">
              <xsl:copy-of select="/*/d:title"/>
          </xsl:when>
          <xsl:when test="/*/d:info/d:title">
              <xsl:copy-of select="/*/d:info/d:title"/>
          </xsl:when>
          <xsl:otherwise>
              <xsl:message terminate="yes">
                  <xsl:text>This template requires a docbook title!</xsl:text>
              </xsl:message>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:variable>

  <!--
      XSL-FO Extensions:

      These are used to do things like generate PDF Bookmarks, which
      are out of scope in standard XSL-FO 1.0, but which most XSL-FO
      solutions support via Extensions.

      XSL-FO 1.1, addresses the issue of bookmarks, with a new
      bookmark element, Apache FOP version > 0.90 supports XSL-FO 1.1.

      Enable 1 and only 1 extension, depending on the XSL-FO
      implementation.
  -->
  <xsl:param name="fop1.extensions" select="1"/> <!-- Apache FOP >= 0.90 -->
  <xsl:param name="fop.extensions"  select="0"/> <!-- Apache FOP < 0.90 -->
  <xsl:param name="axf.extensions"  select="0"/> <!-- Antenna House's XSL Formatter -->
  <xsl:param name="xep.extensions"  select="0"/> <!-- RenderX's XEP -->

  <xsl:param name="use.extensions" select="1"/>
  <xsl:param name="callouts.extension" select="1"/>
  <xsl:param name="textinsert.extension" select="1"/>
  <xsl:param name="title.fontset" select="'CartoGothic Std'"/>
  <!--
      Don't use dingbats for things like the copyright symbol.  Assume
      our font already has it.
  -->
  <xsl:param name="dingbat.font.family" select="''"/>

  <!-- Don't show links -->
  <xsl:param name="ulink.show" select="0"/>

  <!-- Define hard pagebreak -->
  <xsl:template match="processing-instruction('hard-pagebreak')">
    <fo:block break-after='page'/>
  </xsl:template>

  <!-- Root Text Properties  -->
  <xsl:attribute-set name="root.properties">
    <xsl:attribute name="font-family">CartoGothic Std</xsl:attribute>
    <xsl:attribute name="font-size">10.5pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- Title Properties (Sections/Components) -->
  <xsl:attribute-set name="component.title.properties">
    <xsl:attribute name="font-family">CartoGothic Std</xsl:attribute>
    <xsl:attribute name="color">rgb(196,0,34)</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="section.title.properties">
    <xsl:attribute name="color">rgb(196,0,34)</xsl:attribute>
    <xsl:attribute name="font-family">CartoGothic Std</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="header.content.properties">
      <xsl:attribute name="font-family">CartoGothic Std</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="footer.content.properties">
      <xsl:attribute name="font-family">CartoGothic Std</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="formal.title.properties">
      <xsl:attribute name="color">rgb(176,0,14)</xsl:attribute>
      <xsl:attribute name="font-family">CartoGothic Std</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="admonition.title.properties">
      <xsl:attribute name="color">rgb(196,0,34)</xsl:attribute>
      <xsl:attribute name="font-family">CartoGothic Std</xsl:attribute>
  </xsl:attribute-set>

  <xsl:param name="local.l10n.xml" select="document('gentex_mods.xml')"/>

  <!-- Headers -->
  <xsl:param name="header.column.widths">1 1 1</xsl:param>
  <xsl:template name="header.content">
    <xsl:param name="pageclass" select="''"/>
    <xsl:param name="sequence" select="''"/>
    <xsl:param name="position" select="''"/>
    <xsl:param name="gentext-key" select="''"/>

    <fo:block>
      <xsl:choose>
        <xsl:when test="$sequence = 'blank'">
          <!-- nothing -->
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$position = 'left'">
                    <xsl:value-of select="$plaintitle"/>
                </xsl:when>
                <xsl:when test="$position = 'right'">
                    <xsl:value-of select="/*/d:info/d:releaseinfo"/>
                </xsl:when>
                <xsl:when test="$position = 'center'">
                    <xsl:value-of select="/*/d:info/d:pubdate"/>
                </xsl:when>
            </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
  </xsl:template>

  <!-- Footers -->
  <xsl:param name="footer.column.widths">1 1 1</xsl:param>
  <xsl:template name="footer.content">
    <xsl:param name="pageclass" select="''"/>
    <xsl:param name="sequence" select="''"/>
    <xsl:param name="position" select="''"/>
    <xsl:param name="gentext-key" select="''"/>

    <fo:block>
      <xsl:choose>
        <xsl:when test="$sequence = 'blank'">
          <!-- Nothing -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$position = 'center'">
              <fo:page-number/>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
  </xsl:template>

  <!-- Page Number Format -->
  <xsl:template name="page.number.format">
    <xsl:param name="element" select="local-name(.)"/>
    <xsl:param name="master-reference" select="''"/>

    <xsl:choose>
      <xsl:when test="$element = 'toc' and self::d:book">i</xsl:when>
      <xsl:when test="$element = 'preface'">i</xsl:when>
      <xsl:when test="$element = 'dedication'">i</xsl:when>
      <xsl:when test="$master-reference = 'cloud-titlepage'">i</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Chapter Numbering -->
  <xsl:param name="chapter.autolabel" select="0"/>

  <!-- Source Code Properties -->
  <xsl:param name="shade.verbatim" select="1"/>
  <xsl:param name="highlight.source" select="1"/>

  <xsl:attribute-set name="monospace.verbatim.properties">
      <xsl:attribute name="font-size">
          <xsl:choose>
              <xsl:when test="processing-instruction('db-font-size')"><xsl:value-of
              select="processing-instruction('db-font-size')"/></xsl:when>
              <xsl:otherwise>inherit</xsl:otherwise>
          </xsl:choose>
      </xsl:attribute>
  </xsl:attribute-set>

  <!-- Wrap long examples -->
  <xsl:attribute-set name="monospace.verbatim.properties">
      <xsl:attribute name="wrap-option">wrap</xsl:attribute>
      <xsl:attribute name="hyphenation-character">\</xsl:attribute>
  </xsl:attribute-set>

  <!-- Admonition Graphics -->
  <xsl:param name="admon.graphics" select="1"/>
  <!-- NEED IMAGE PATH -->
  <!-- <xsl:param name="admon.graphics.path" select="'urn:docbkx:stylesheet/../images/'"/> -->
  <xsl:param name="admon.graphics.extension" select="'.svg'"/>

  <!-- Callout Graphics -->
  <xsl:param name="callout.unicode"  select="0"/>
  <xsl:param name="callout.graphics" select="1"/>
  <xsl:param name="callout.graphics.extension" select="'.svg'"/>
  <!-- NEED IMAGE PATH -->
  <!-- <xsl:param name="callout.graphics.path" select="'urn:docbkx:stylesheet/../images/callouts/'"/> -->
  <xsl:param name="callout.graphics.number.limit" select="30"/>

  <!-- Glossary Setup -->
  <xsl:param name="glossary.as.blocks" select="1"/>

  <!-- Sets up the Cloud Title Page -->
  <xsl:template name="user.pagemasters">
    <fo:simple-page-master master-name="cloudpage-first"
                           page-width="8.5in"
                           page-height="11in"
                           margin-top="0.0in"
                           margin-bottom="0.0in"
                           margin-left="0.0in"
                           margin-right="0.0in"
                           >
      <xsl:if test="$axf.extensions != 0">
        <xsl:call-template name="axf-page-master-properties">
          <xsl:with-param name="page.master">cloudpage-first</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <fo:region-body margin-bottom="0.0in"
                      margin-top="0.0in"
                      column-gap="0pt"
                      column-count="1"/>
      <xsl:element name="fo:region-before">
          <xsl:attribute name="extent">11.0in</xsl:attribute>
          <xsl:attribute name="display-align">before</xsl:attribute>
          <xsl:attribute name="background-image">
              <xsl:text>url(</xsl:text>
              <xsl:value-of select="$cloud.api.background.image"/>
              <xsl:text>)</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
          <xsl:attribute name="background-position-horizontal">0%</xsl:attribute>
          <xsl:attribute name="background-position-vertical">0%</xsl:attribute>
      </xsl:element>
    </fo:simple-page-master>

    <!-- setup for title page(s) -->
    <fo:page-sequence-master master-name="cloud-titlepage">
      <fo:repeatable-page-master-alternatives>
        <fo:conditional-page-master-reference master-reference="blank"
                                              blank-or-not-blank="blank"/>
        <fo:conditional-page-master-reference master-reference="cloudpage-first"
                                              page-position="first"/>
        <fo:conditional-page-master-reference master-reference="titlepage-odd"
                                              odd-or-even="odd"/>
        <fo:conditional-page-master-reference 
                                              odd-or-even="even">
          <xsl:attribute name="master-reference">
            <xsl:choose>
              <xsl:when test="$double.sided != 0">titlepage-even</xsl:when>
              <xsl:otherwise>titlepage-odd</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </fo:conditional-page-master-reference>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>
  </xsl:template>

  <xsl:template name="select.user.pagemaster">
    <xsl:param name="element"/>
    <xsl:param name="pageclass"/>
    <xsl:param name="default-pagemaster"/>

    <xsl:choose>
      <xsl:when test="$default-pagemaster = 'titlepage'">
        <xsl:value-of select="'cloud-titlepage'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$default-pagemaster"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Handle Creative Common Legal notice stuff -->
  <xsl:template match="d:legalnotice" mode="titlepage.mode">
      <xsl:variable name="id">
          <xsl:call-template name="object.id"/>
      </xsl:variable>

      <fo:block id="{$id}">
          <xsl:choose>
              <xsl:when test="starts-with(string(@role),'cc-')">
                  <xsl:variable name="ccid">
                      <xsl:value-of select="substring-after(string(@role),'cc-')"/>
                  </xsl:variable>
                  <xsl:variable name="ccidURL">
                      <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                      <xsl:value-of select="$ccid"/>
                      <xsl:text>/3.0/legalcode</xsl:text>
                  </xsl:variable>
                  <xsl:variable name="ccidLink">
                      <xsl:text>url(</xsl:text>
                      <xsl:value-of select="$ccidURL"/>
                      <xsl:text>)</xsl:text>
                  </xsl:variable>
                  <fo:list-block xsl:use-attribute-sets="normal.para.spacing">
                      <fo:list-item>
                          <fo:list-item-label end-indent="label-end()">
                              <fo:block>
                                  <xsl:element name="fo:basic-link">
                                      <xsl:attribute name="external-destination">
                                          <xsl:value-of select="$ccidLink"/>
                                      </xsl:attribute>
                                      <xsl:element name="fo:external-graphic">
                                          <xsl:attribute name="src">
                                              <xsl:text>url(</xsl:text>
                                              <xsl:value-of select="$cloud.api.cc.image.dir"/>
                                              <xsl:text>/</xsl:text>
                                              <xsl:value-of select="$ccid"/>
                                              <xsl:text>.svg)</xsl:text>
                                          </xsl:attribute>
                                          <xsl:attribute name="width">auto</xsl:attribute>
                                          <xsl:attribute name="height">auto</xsl:attribute>
                                          <xsl:attribute name="content-width">75%</xsl:attribute>
                                          <xsl:attribute name="content-height">75%</xsl:attribute>
                                      </xsl:element>
                                  </xsl:element>
                              </fo:block>
                          </fo:list-item-label>
                          <fo:list-item-body start-indent="1.125in">
                              <fo:block xsl:use-attribute-sets="normal.para.spacing">
                                  <xsl:text>Except where otherwise noted, this document is licensed under </xsl:text>
                                  <fo:block/>
                                  <xsl:element name="fo:basic-link">
                                      <xsl:attribute name="external-destination">
                                          <xsl:value-of select="$ccidLink"/>
                                      </xsl:attribute>
                                      <fo:inline font-weight="bold">
                                          <xsl:text>Creative Commons Attribution </xsl:text>
                                          <xsl:choose>
                                              <xsl:when test="$ccid = 'by'" />
                                              <xsl:when test="$ccid = 'by-sa'">
                                                  <xsl:text>ShareAlike</xsl:text>
                                              </xsl:when>
                                              <xsl:when test="$ccid = 'by-nd'">
                                                  <xsl:text>NoDerivatives</xsl:text>
                                              </xsl:when>
                                              <xsl:when test="$ccid = 'by-nc'">
                                                  <xsl:text>NonCommercial</xsl:text>
                                              </xsl:when>
                                              <xsl:when test="$ccid = 'by-nc-sa'">
                                                  <xsl:text>NonCommercial ShareAlike</xsl:text>
                                              </xsl:when>
                                              <xsl:when test="$ccid = 'by-nc-nd'">
                                                  <xsl:text>NonCommercial NoDerivatives</xsl:text>
                                              </xsl:when>
                                              <xsl:otherwise>
                                                  <xsl:message terminate="yes">I don't understand licence <xsl:value-of select="$ccid"/></xsl:message>
                                              </xsl:otherwise>
                                          </xsl:choose>
                                          <xsl:text> 3.0 License</xsl:text>
                                      </fo:inline>
                                  </xsl:element>
                                  <xsl:text>.</xsl:text>
                                  <fo:block/>
                                  <xsl:element name="fo:basic-link">
                                      <xsl:attribute name="external-destination">
                                          <xsl:value-of select="$ccidLink"/>
                                      </xsl:attribute>
                                      <fo:inline>
                                          <xsl:value-of select="$ccidURL"/>
                                      </fo:inline>
                                  </xsl:element>
                              </fo:block>
                          </fo:list-item-body>
                      </fo:list-item>
                  </fo:list-block>
                  <xsl:apply-templates mode="titlepage.mode"/>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:if test="d:title"> <!-- FIXME: add param for using default title? -->
                      <xsl:call-template name="formal.object.heading"/>
                  </xsl:if>
                  <xsl:apply-templates mode="titlepage.mode"/>
              </xsl:otherwise>
          </xsl:choose>
      </fo:block>
  </xsl:template>

  <xsl:template match="d:holder" mode="titlepage.mode">
      <xsl:apply-templates/>
      <xsl:choose>
          <xsl:when test="position() &lt; last()">
              <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:when test="position() = last()">
              <xsl:choose>
                  <xsl:when test="starts-with(string(/*/d:info/d:legalnotice/@role),'cc-')">
                      <xsl:text> Some rights reserved.</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:text> All rights reserved.</xsl:text>
                  </xsl:otherwise>
              </xsl:choose>
          </xsl:when>
      </xsl:choose>
  </xsl:template>

  <xsl:template match="d:releaseinfo" mode="titlepage.mode">
      <xsl:apply-templates mode="titlepage.mode"/>
      <xsl:if test="/*/d:info/d:pubdate">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="normalize-space(string(/*/d:info/d:pubdate))"/>
          <xsl:text>)</xsl:text>
      </xsl:if>
  </xsl:template>
</xsl:stylesheet>
