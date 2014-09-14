<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY lowercase "'abcdefghijklmnopqrstuvwxyz'">
<!ENTITY uppercase "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'">
 ]>
<xsl:stylesheet exclude-result-prefixes="d"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:date="http://exslt.org/dates-and-times"
		xmlns:exslt="http://exslt.org/common"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.1">

  <xsl:import href="urn:docbkx:stylesheet-orig/profile-docbook.xsl" />
  <xsl:import href="urn:docbkx:stylesheet-orig/highlight.xsl" />
  <xsl:import href="titlepage.templates.xsl"/>
  <xsl:import href="fop1.xsl"/>
  <xsl:import href="../date.xsl"/>
  <xsl:import href="../this.xsl"/>
  <xsl:import href="verbatim.xsl"/>
  <xsl:include href="../inline.xsl"/>
  <!-- 
       DWC: Hack to keep olinks from being hot for now
       You should be able to remove this once the base xsls
       have been upgraded.
  -->
  <xsl:include href="xref.xsl"/>

  <xsl:variable name="profiled-nodes" select="exslt:node-set($profiled-content)"/>

  <xsl:param name="monospaceFont"/>

  <xsl:param name="bodyFont">
    <xsl:choose>
      <xsl:when test="starts-with(/*/@xml:lang, 'zh')">AR-PL-New-Sung</xsl:when>
      <xsl:when test="starts-with(/*/@xml:lang, 'ja')">TakaoGothic</xsl:when>
      <xsl:otherwise>CartoGothic Std</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="monospace.font.family">
    <xsl:choose>
      <xsl:when test="$monospaceFont != ''"><xsl:value-of select="$monospaceFont"/></xsl:when>
      <xsl:when test="starts-with(/*/@xml:lang, 'zh')">AR-PL-New-Sung</xsl:when>
      <xsl:when test="starts-with(/*/@xml:lang, 'ja')">TakaoGothic</xsl:when>
      <xsl:otherwise>monospace</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="project.build.directory"/>

  <!-- Front-Cover Background Image, should be set by the plugin -->
  <xsl:param name="cloud.api.background.image" select="'images/cover.svg'"/>
  <xsl:param name="cloud.api.cc.image.dir" select="'images/cc/'"/>

  <xsl:param name="branding"/>
  <xsl:param name="coverLogoPath"/>
  <xsl:param name="coverLogoLeft"/>
  <xsl:param name="coverLogoTop"/>
  <xsl:param name="coverUrl"/>
  <xsl:param name="secondaryCoverLogoPath"><xsl:choose>
      <xsl:when test="$branding = 'rackspace-private-cloud'"><xsl:value-of select="concat($cloud.api.cc.image.dir,'/../powered-by-openstack.png')"/></xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose></xsl:param>
  <xsl:param name="omitCover">0</xsl:param>
  <xsl:param name="draft.mode">no</xsl:param>

<xsl:param name="generate.toc">
/appendix toc,title
article/appendix  nop
/article  toc,title
book      toc,title,figure,table,example,equation
/chapter  toc,title
part      noop
/preface  toc,title
reference toc,title
/sect1    toc
/sect2    toc
/sect3    toc
/sect4    toc
/sect5    toc
/section  toc
set       toc,title
</xsl:param>

  <xsl:param name="alignment">start</xsl:param>
  <xsl:param name="security">external</xsl:param>
  <xsl:param name="draft.status" select="''"/>
  <xsl:param name="root.attr.status"><xsl:if test="$draft.status = 'on' or (/*[@status = 'draft'] and $draft.status = '')">draft;</xsl:if></xsl:param>
  <xsl:param name="profile.security">
    <xsl:choose>
      <xsl:when test="$security = 'external'"><xsl:value-of select="$root.attr.status"/>external</xsl:when>
      <xsl:when test="$security = 'internal'"><xsl:value-of select="$root.attr.status"/>internal</xsl:when>
      <xsl:when test="$security = 'reviewer'"><xsl:value-of select="$root.attr.status"/>reviewer;internal;external</xsl:when>
      <xsl:when test="$security = 'writeronly'"><xsl:value-of select="$root.attr.status"/>reviewer;internal;external;writeronly</xsl:when>
      <xsl:when test="$security = 'external'"><xsl:value-of select="$root.attr.status"/>external</xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes"> 
	  ERROR: The value "<xsl:value-of select="$security"/>" is not valid for the security paramter. 
	         Valid values are: external, internal, reviewer, and writeronly. 
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="show.comments">
    <xsl:choose>
      <xsl:when test="$security = 'reviewer' or $security = 'writeronly'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="insert.xref.page.number">yes</xsl:param>

  <xsl:param name="status.bar.text">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="/*/processing-instruction('rax')"/>
      <xsl:with-param name="attribute" select="'status.bar.text'"/>
    </xsl:call-template>
  </xsl:param>

  <xsl:param name="rackspace.status.text">
    <xsl:if test="contains($root.attr.status, 'draft;')">DRAFT<xsl:text>&#160;-&#160;</xsl:text></xsl:if><xsl:choose>
  <xsl:when test="$security = 'internal'">INTERNAL<xsl:text> -&#160;</xsl:text></xsl:when>
  <xsl:when test="$security = 'reviewer'">REVIEW<xsl:text> -&#160;</xsl:text></xsl:when>
  <xsl:when test="$security = 'writeronly'">WRITERONLY<xsl:text> -&#160;</xsl:text></xsl:when>
  <xsl:when test="$security = 'external'"/>
</xsl:choose><xsl:if test="not(normalize-space($status.bar.text) = '')"><xsl:value-of select="normalize-space($status.bar.text)"/><xsl:text> -&#160;</xsl:text></xsl:if> 
  </xsl:param>

  <xsl:attribute-set name="example.properties">
    <xsl:attribute name="keep-together.within-column">auto</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="sidebar.properties">
    <xsl:attribute name="keep-together.within-column">auto</xsl:attribute>
  </xsl:attribute-set>

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

  <xsl:variable name="titleabbrev">
      <xsl:choose>
          <xsl:when test="/*/d:titleabbrev">
              <xsl:copy-of select="/*/d:titleabbrev"/>
          </xsl:when>
          <xsl:when test="/*/d:info/d:titleabbrev">
              <xsl:copy-of select="/*/d:info/d:titleabbrev"/>
          </xsl:when>
          <xsl:otherwise>
              <xsl:text/>
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
  <xsl:param name="title.fontset" select="$bodyFont"/>
  <!--
      Don't use dingbats for things like the copyright symbol.  Assume
      our font already has it.
  -->
  <xsl:param name="dingbat.font.family" select="''"/>
  <xsl:param name="make.year.ranges" select="1"/>
  <!-- Don't show links -->
  <xsl:param name="ulink.show" select="0"/>

  <!-- Numbering of sections and chapters -->
  <xsl:param name="chapter.autolabel" select="1"/>
  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="section.label.includes.component.label">
    <xsl:choose>
      <xsl:when test="$section.autolabel != '0'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Define hard pagebreak -->
  <xsl:template match="processing-instruction('hard-pagebreak')">
    <fo:block break-after='page'/>
  </xsl:template>

  <!-- Root Text Properties  -->
  <xsl:attribute-set name="root.properties">
    <xsl:attribute name="font-family"><xsl:value-of select="$bodyFont"/></xsl:attribute>
    <xsl:attribute name="font-size">10.5pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- Title Properties (Sections/Components) -->
  <xsl:attribute-set name="component.title.properties">
    <xsl:attribute name="font-family"><xsl:value-of select="$bodyFont"/></xsl:attribute>
    <xsl:attribute name="color">rgb(196,0,34)</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="section.title.properties">
    <xsl:attribute name="color">rgb(196,0,34)</xsl:attribute>
    <xsl:attribute name="font-family"><xsl:value-of select="$bodyFont"/></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="header.content.properties">
      <xsl:attribute name="font-family"><xsl:value-of select="$bodyFont"/></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="footer.content.properties">
      <xsl:attribute name="font-family"><xsl:value-of select="$bodyFont"/></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="formal.title.properties">
      <xsl:attribute name="color">rgb(176,0,14)</xsl:attribute>
      <xsl:attribute name="font-family"><xsl:value-of select="$bodyFont"/></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="admonition.title.properties">
      <xsl:attribute name="color">rgb(196,0,34)</xsl:attribute>
      <xsl:attribute name="font-family"><xsl:value-of select="$bodyFont"/></xsl:attribute>
  </xsl:attribute-set>


<!-- Black and white links -->
<xsl:param name="bw" select="0"/>

<xsl:attribute-set name="xref.properties">
  <xsl:attribute name="color">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*/@security = 'internal'">red</xsl:when>
      <xsl:when test="$bw = 0">blue</xsl:when>
      <xsl:otherwise>black</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
  <xsl:attribute name="font-style">normal</xsl:attribute>
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
                    <xsl:choose>
                        <xsl:when test="$titleabbrev != ''">
                            <xsl:value-of select="$titleabbrev"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$plaintitle"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$position = 'right'">
                    <xsl:choose>
                        <xsl:when test="/*/d:info/d:releaseinfo">
                            <xsl:value-of select="/*/d:info/d:releaseinfo"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="longDate">
                                <xsl:with-param name="in"  select="/*/d:info/d:pubdate"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$position = 'center'">
                    <xsl:if test="/*/d:info/d:releaseinfo">
                        <xsl:call-template name="longDate">
                            <xsl:with-param name="in" select="/*/d:info/d:pubdate"/>
                        </xsl:call-template>
                    </xsl:if>
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

  <xsl:template name="book.titlepage.before.verso">
    <xsl:if test="$omitCover = '0'">
      <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format" break-after="page"/>
    </xsl:if>
  </xsl:template>

  <!-- Page Number Format -->
  <xsl:template name="page.number.format">
    <xsl:param name="element" select="local-name(.)"/>
    <xsl:param name="master-reference" select="''"/>

    <xsl:choose>
      <xsl:when test="$element = 'toc' and self::d:book">i</xsl:when>
      <xsl:when test="$element = 'preface'">i</xsl:when>
      <xsl:when test="$element = 'dedication'">1</xsl:when>
      <xsl:when test="$element = 'acknowledgements'">i</xsl:when>
      <xsl:when test="$element = 'colophon'">1</xsl:when>
      <xsl:when test="$master-reference = 'cloud-titlepage'">i</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Source Code Properties -->
  <xsl:param name="shade.verbatim" select="1"/>

  <!-- Uncomment this to get a border without shading: -->
  <!-- <xsl:attribute-set name="shade.verbatim.style"> -->
  <!--   <xsl:attribute name="background-color">#FFFFFF</xsl:attribute> -->
  <!--   <xsl:attribute name="border-width">0.5pt</xsl:attribute> -->
  <!--   <xsl:attribute name="border-style">solid</xsl:attribute> -->
  <!--   <xsl:attribute name="border-color">#575757</xsl:attribute> -->
  <!--   <xsl:attribute name="padding">3pt</xsl:attribute> -->
  <!-- </xsl:attribute-set> -->

  <xsl:param name="highlight.source" select="1"/>

  <xsl:attribute-set name="monospace.verbatim.properties">
      <xsl:attribute name="font-size">
          <xsl:choose>
              <xsl:when test="processing-instruction('db-font-size')"><xsl:value-of
              select="processing-instruction('db-font-size')"/></xsl:when>
              <xsl:otherwise>85%</xsl:otherwise>
          </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="wrap-option">wrap</xsl:attribute>
      <xsl:attribute name="hyphenation-character">\</xsl:attribute>
  </xsl:attribute-set>

  <xsl:param name="hyphenate.verbatim.characters">\/?&amp;=,.</xsl:param>

  <xsl:param name="hyphenate.verbatim" select="1"/>

  <!-- DWC: See comment in this template for more info -->
<xsl:template name="hyphenate.verbatim">
  <xsl:param name="content"/>
  <xsl:variable name="head" select="substring($content, 1, 1)"/>
  <xsl:variable name="tail" select="substring($content, 2)"/>
  <xsl:choose>
    <!-- 
	 DWC: Don't put soft-hyphens after a space due to this fop bug:
	 https://issues.apache.org/bugzilla/show_bug.cgi?id=49837 It's
	 fixed, but apparently the version of fop we're using doesn't
	 include it yet :-(
    -->
    <!-- Place soft-hyphen after space or non-breakable space. -->
    <!-- <xsl:when test="$head = ' ' or $head = '&#160;'"> -->
    <!--   <xsl:text>&#160;</xsl:text> -->
    <!--   <xsl:text>&#x00AD;</xsl:text> -->
    <!-- </xsl:when> -->
    <xsl:when test="$hyphenate.verbatim.characters != '' and
                    translate($head, $hyphenate.verbatim.characters, '') = '' and not($tail = '')">
      <xsl:value-of select="$head"/>
      <xsl:text>&#8203;</xsl:text>		<!-- shy: &#x00AD; zwsp: &#8203;-->
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$head"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="$tail">
    <xsl:call-template name="hyphenate.verbatim">
      <xsl:with-param name="content" select="$tail"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


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
  <xsl:param name="autoPdfGlossaryInfix"/>
  <xsl:param name="glossary.collection" select="concat($project.build.directory,$autoPdfGlossaryInfix,'/mvn/com.rackspace.cloud.api/glossary/glossary.xml')"/>


  <xsl:param name="current.docid" select="/*/@xml:id"/>
  <xsl:param name="target.database.document" select="concat($project.build.directory, '/../olink.db')"/>
  <xsl:param name="olink.doctitle">yes</xsl:param> 
  <xsl:param name="activate.external.olinks" select="0"/>

  <!-- Sets up the Cloud Title Page -->
  <xsl:template name="user.pagemasters">
    <fo:simple-page-master master-name="cloudpage-first"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
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
	  <xsl:if test="$omitCover = '0'">
	    <xsl:attribute name="background-image">
	      <xsl:text>url(</xsl:text>
              <xsl:value-of select="$cloud.api.background.image"/>
              <xsl:text>)</xsl:text>
	    </xsl:attribute>
	  </xsl:if>
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
        <fo:conditional-page-master-reference page-position="first">
	  <xsl:attribute name="master-reference">
	    <xsl:choose>
	      <xsl:when test="$omitCover = '0'">cloudpage-first</xsl:when>
	      <xsl:otherwise>titlepage-first</xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	</fo:conditional-page-master-reference>
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
      <xsl:when test="($element = 'book' or $element = 'set') and 
		       $default-pagemaster = 'titlepage'">
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
                  <xsl:call-template name="CCLegalNotice" />
              </xsl:when>
              <xsl:when test="@role = 'rs-api'">
                  <xsl:call-template name="RSAPILegalNotice"/>
              </xsl:when>
              <xsl:when test="@role = 'apache2'">
                  <xsl:call-template name="Apache2LegalNotice"/>
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

  <xsl:template name="Apache2LegalNotice">
      <xsl:variable name="a2Link" select="'http://www.apache.org/licenses/LICENSE-2.0'"/>
      <xsl:if test="@role = 'apache2'">
          <fo:block xsl:use-attribute-sets="normal.para.spacing">
              Licensed under the Apache License, Version 2.0 (the "License");
              you may not use this file except in compliance with the License.
              You may obtain a copy of the License at
          </fo:block>
          <fo:block xsl:use-attribute-sets="normal.para.spacing">
              <xsl:element name="fo:basic-link">
                  <xsl:attribute name="external-destination">
                      <xsl:value-of select="$a2Link"/>
                  </xsl:attribute>
                  <fo:inline>
                      <xsl:value-of select="$a2Link"/>
                  </fo:inline>
              </xsl:element>
          </fo:block>
          <fo:block xsl:use-attribute-sets="normal.para.spacing">
              Unless required by applicable law or agreed to in writing, software
              distributed under the License is distributed on an "AS IS" BASIS,
              WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
              See the License for the specific language governing permissions and
              limitations under the License.
          </fo:block>
      </xsl:if>
  </xsl:template>

  <xsl:template name="RSAPILegalNotice">
      <xsl:if test="@role = 'rs-api'">
          <fo:block xsl:use-attribute-sets="normal.para.spacing">
              <xsl:value-of select="/*/d:info/d:abstract"/>
              The document is for informational purposes only and is
              provided “AS IS.”
          </fo:block>
          <fo:block xsl:use-attribute-sets="normal.para.spacing">
              RACKSPACE MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY
              KIND, EXPRESS OR IMPLIED, AS TO THE ACCURACY OR
              COMPLETENESS OF THE CONTENTS OF THIS DOCUMENT AND
              RESERVES THE RIGHT TO MAKE CHANGES TO SPECIFICATIONS AND
              PRODUCT/SERVICES DESCRIPTION AT ANY TIME WITHOUT NOTICE.
              RACKSPACE SERVICES OFFERINGS ARE SUBJECT TO CHANGE
              WITHOUT NOTICE.  USERS MUST TAKE FULL RESPONSIBILITY FOR
              APPLICATION OF ANY SERVICES MENTIONED HEREIN.  EXCEPT AS
              SET FORTH IN RACKSPACE GENERAL TERMS AND CONDITIONS
              AND/OR CLOUD TERMS OF SERVICE, RACKSPACE ASSUMES NO
              LIABILITY WHATSOEVER, AND DISCLAIMS ANY EXPRESS OR
              IMPLIED WARRANTY, RELATING TO ITS SERVICES INCLUDING,
              BUT NOT LIMITED TO, THE IMPLIED WARRANTY OF
              MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND
              NONINFRINGEMENT.
          </fo:block>
          <fo:block xsl:use-attribute-sets="normal.para.spacing">
              Except as expressly provided in any written license
              agreement from Rackspace, the furnishing of this
              document does not give you any license to patents,
              trademarks, copyrights, or other intellectual property.
          </fo:block>
          <fo:block xsl:use-attribute-sets="normal.para.spacing">
              Rackspace®, Rackspace logo and Fanatical Support® are
              registered service marks of Rackspace US,
              Inc. All other product names and trademarks
              used in this document are for identification purposes
              only and are property of their respective owners.
          </fo:block>
          <xsl:apply-templates mode="titlepage.mode"/>
      </xsl:if>
  </xsl:template>

  <xsl:template name="CCLegalNotice">
      <xsl:if test="starts-with(string(@role),'cc-')">
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
      </xsl:if>
  </xsl:template>

  <xsl:template match="d:holder" mode="titlepage.mode">
      <xsl:variable name="useCCLicense">
          <xsl:for-each select="/*//d:legalnotice">
              <xsl:if test="starts-with(string(@role),'cc-')">
                  <xsl:text>yes</xsl:text>
              </xsl:if>
          </xsl:for-each>
      </xsl:variable>
      <xsl:apply-templates/>
      <xsl:choose>
          <xsl:when test="position() &lt; last()">
              <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:when test="position() = last()">
              <xsl:choose>
                  <xsl:when test="$useCCLicense = 'yes'">
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
          <xsl:value-of select="/*/d:info/d:pubdate"/>
          <xsl:text>)</xsl:text>
      </xsl:if>
  </xsl:template>

  <xsl:template match="d:pubdate" mode="titlepage.mode">
      <xsl:if test="not(/*/d:info/d:releaseinfo)">
          <xsl:apply-templates mode="titlepage.mode"/>
      </xsl:if>
  </xsl:template>

  <!--
      The abstract is suppressed if the rs-api legal notice is used, as
      it's incorporated into the document in this case.
  -->
  <xsl:template match="d:abstract" mode="titlepage.mode">
      <xsl:variable name="useRSLicense">
          <xsl:for-each select="/*//d:legalnotice">
              <xsl:if test="@role = 'rs-api'">
                  <xsl:text>yes</xsl:text>
              </xsl:if>
          </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
          <xsl:when test="$useRSLicense = 'yes'" />
          <xsl:otherwise>
              <fo:block xsl:use-attribute-sets="abstract.properties">
                  <fo:block xsl:use-attribute-sets="abstract.title.properties">
                      <xsl:choose>
                          <xsl:when test="d:title|d:info/d:title">
                              <xsl:apply-templates select="d:title|d:info/d:title"/>
                          </xsl:when>
                          <xsl:otherwise>
                              <xsl:call-template name="gentext">
                                  <xsl:with-param name="key" select="'Abstract'"/>
                              </xsl:call-template>
                          </xsl:otherwise>
                      </xsl:choose>
                  </fo:block>
                  <xsl:apply-templates select="*[not(self::d:title)]" mode="titlepage.mode"/>
              </fo:block>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <!-- DWC: This writes out something like DRAFT - CONFIDENTIAL in the margin  -->
  <xsl:template name="document.status.bar">
    <fo:block-container reference-orientation="90" absolute-position="fixed"  top="-1in" overflow="visible" height="2in" width="30in" z-index="1">
      <fo:block padding-before=".45in" font-size="1.5em" color="gray" font-weight="bold">
    	<fo:leader leader-pattern="use-content" leader-length="30in" letter-spacing=".1em"><xsl:text> </xsl:text><xsl:value-of select="$rackspace.status.text"/><xsl:text> </xsl:text></fo:leader>
      </fo:block>
    </fo:block-container>
  </xsl:template>

  <!-- DWC: This template comes from pagesetup.xsl -->
  <!-- I've added <xsl:call-template name="document.status.bar"/> -->
  <!-- in several places to get the running text in the margin -->
<xsl:template match="*" mode="running.head.mode">
  <xsl:param name="master-reference" select="'unknown'"/>
  <xsl:param name="gentext-key" select="local-name(.)"/>

  <!-- remove -draft from reference -->
  <xsl:variable name="pageclass">
    <xsl:choose>
      <xsl:when test="contains($master-reference, '-draft')">
        <xsl:value-of select="substring-before($master-reference, '-draft')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$master-reference"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:static-content flow-name="xsl-region-before-first">
    <xsl:call-template name="document.status.bar"/>

    <fo:block xsl:use-attribute-sets="header.content.properties">
      <xsl:call-template name="header.table">
        <xsl:with-param name="pageclass" select="$pageclass"/>
        <xsl:with-param name="sequence" select="'first'"/>
        <xsl:with-param name="gentext-key" select="$gentext-key"/>
      </xsl:call-template>
    </fo:block>
  </fo:static-content>

  <fo:static-content flow-name="xsl-region-before-odd">
    <xsl:call-template name="document.status.bar"/>

    <fo:block xsl:use-attribute-sets="header.content.properties">
      <xsl:call-template name="header.table">
        <xsl:with-param name="pageclass" select="$pageclass"/>
        <xsl:with-param name="sequence" select="'odd'"/>
        <xsl:with-param name="gentext-key" select="$gentext-key"/>
      </xsl:call-template>
    </fo:block>
  </fo:static-content>

  <fo:static-content flow-name="xsl-region-before-even">
			  <xsl:call-template name="document.status.bar"/>

    <fo:block xsl:use-attribute-sets="header.content.properties">
      <xsl:call-template name="header.table">
        <xsl:with-param name="pageclass" select="$pageclass"/>
        <xsl:with-param name="sequence" select="'even'"/>
        <xsl:with-param name="gentext-key" select="$gentext-key"/>
      </xsl:call-template>
    </fo:block>
  </fo:static-content>

  <fo:static-content flow-name="xsl-region-before-blank">
			  <xsl:call-template name="document.status.bar"/>

    <fo:block xsl:use-attribute-sets="header.content.properties">
      <xsl:call-template name="header.table">
        <xsl:with-param name="pageclass" select="$pageclass"/>
        <xsl:with-param name="sequence" select="'blank'"/>
        <xsl:with-param name="gentext-key" select="$gentext-key"/>
      </xsl:call-template>
    </fo:block>
  </fo:static-content>

  <xsl:call-template name="footnote-separator"/>

  <xsl:if test="$fop.extensions = 0 and $fop1.extensions = 0">
    <xsl:call-template name="blank.page.content"/>
  </xsl:if>
</xsl:template>

<!-- DWC: From pagesetup.xsl; modified to remove headers from part titlepages -->
<xsl:template name="header.table">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <!-- default is a single table style for all headers -->
  <!-- Customize it for different page classes or sequence location -->

  <xsl:choose>
      <xsl:when test="$pageclass = 'index'">
          <xsl:attribute name="margin-{$direction.align.start}">0pt</xsl:attribute>
      </xsl:when>
  </xsl:choose>

  <xsl:variable name="column1">
    <xsl:choose>
      <xsl:when test="$double.sided = 0">1</xsl:when>
      <xsl:when test="$sequence = 'first' or $sequence = 'odd'">1</xsl:when>
      <xsl:otherwise>3</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="column3">
    <xsl:choose>
      <xsl:when test="$double.sided = 0">3</xsl:when>
      <xsl:when test="$sequence = 'first' or $sequence = 'odd'">3</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="candidate">
    <fo:table xsl:use-attribute-sets="header.table.properties">
      <xsl:call-template name="head.sep.rule">
        <xsl:with-param name="pageclass" select="$pageclass"/>
        <xsl:with-param name="sequence" select="$sequence"/>
        <xsl:with-param name="gentext-key" select="$gentext-key"/>
      </xsl:call-template>

      <fo:table-column column-number="1">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">header</xsl:with-param>
            <xsl:with-param name="position" select="$column1"/>
            <xsl:with-param name="pageclass" select="$pageclass"/>
            <xsl:with-param name="sequence" select="$sequence"/>
            <xsl:with-param name="gentext-key" select="$gentext-key"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>
      <fo:table-column column-number="2">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">header</xsl:with-param>
            <xsl:with-param name="position" select="2"/>
            <xsl:with-param name="pageclass" select="$pageclass"/>
            <xsl:with-param name="sequence" select="$sequence"/>
            <xsl:with-param name="gentext-key" select="$gentext-key"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>
      <fo:table-column column-number="3">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">header</xsl:with-param>
            <xsl:with-param name="position" select="$column3"/>
            <xsl:with-param name="pageclass" select="$pageclass"/>
            <xsl:with-param name="sequence" select="$sequence"/>
            <xsl:with-param name="gentext-key" select="$gentext-key"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>

      <fo:table-body>
        <fo:table-row>
          <xsl:attribute name="block-progression-dimension.minimum">
            <xsl:value-of select="$header.table.height"/>
          </xsl:attribute>
          <fo:table-cell text-align="start"
                         display-align="before">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="header.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.start"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell text-align="center"
                         display-align="before">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="header.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="'center'"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell text-align="right"
                         display-align="before">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="header.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.end"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </xsl:variable>

  <!-- Really output a header? -->
  <xsl:choose>
    <xsl:when test="$pageclass = 'titlepage' and ($gentext-key = 'book' or $gentext-key = 'part') and $sequence='first'">
      <!-- no, book titlepages have no headers at all -->
    </xsl:when>
    <xsl:when test="$sequence = 'blank' and $headers.on.blank.pages = 0">
      <!-- no output -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$candidate"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="processing-instruction('sbr')">
  <xsl:text>&#x200B;</xsl:text>
</xsl:template>

<xsl:template match="*[processing-instruction('rax-fo') = 'keep-with-previous']">
  <fo:block keep-together.within-column="always"
	    keep-with-previous.within-column="always">
    <xsl:apply-imports/>
  </fo:block>
</xsl:template>

<xsl:template match="*[processing-instruction('rax-fo') = 'keep-with-next']">
  <fo:block keep-together.within-column="always"
	    keep-with-next.within-column="always">
    <xsl:apply-imports/>
  </fo:block>
</xsl:template>

<xsl:template match="*[processing-instruction('rax-fo') = 'keep-together']">
  <fo:block keep-together.within-column="always">
    <xsl:apply-imports/>
  </fo:block>
</xsl:template>

<xsl:attribute-set name="table.table.properties">
  <xsl:attribute name="font-size">8pt</xsl:attribute>
  <xsl:attribute name="table-layout">fixed</xsl:attribute>
</xsl:attribute-set>

<!-- The following templates change the color of text flagged as reviewer, internal, or writeronly -->
  <xsl:template match="text()[ contains(concat(';',ancestor::*/@security,';'),';internal;') ] | xref[ contains(concat(';',ancestor::*/@security,';'),';internal;') ]">
	<fo:wrapper xmlns:fo="http://www.w3.org/1999/XSL/Format" color="blue"><xsl:apply-imports/></fo:wrapper>
  </xsl:template>
  <xsl:template match="text()[ contains(concat(';',ancestor::*/@security,';'),';writeronly;') ] | xref[ contains(concat(';',ancestor::*/@security,';'),';writeronly;') ]" priority="10">
	<fo:wrapper xmlns:fo="http://www.w3.org/1999/XSL/Format" color="red"><xsl:apply-imports/></fo:wrapper>
  </xsl:template>
  <xsl:template match="text()[ contains(concat(';',ancestor::*/@security,';'),';reviewer;') ] | xref[ contains(concat(';',ancestor::*/@security,';'),';reviewer;') ]" priority="10">
	<fo:inline xmlns:fo="http://www.w3.org/1999/XSL/Format" background-color="yellow"><xsl:apply-imports/></fo:inline>
  </xsl:template>
  <xsl:template match="text()[ ancestor::*/@role = 'highlight' ] | xref[ ancestor::*/@role = 'highlight' ]" priority="10">
	<fo:inline xmlns:fo="http://www.w3.org/1999/XSL/Format" background-color="yellow"><xsl:apply-imports/></fo:inline>
  </xsl:template>

    <xsl:template match="d:parameter">
      <xsl:param name="content">
	<xsl:call-template name="simple.xlink">
	  <xsl:with-param name="content">
	    <xsl:apply-templates/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:param>
      
      <fo:inline font-style="italic" xsl:use-attribute-sets="monospace.properties">
	<xsl:call-template name="anchor"/>
	<xsl:if test="@dir">
	  <xsl:attribute name="direction">
	    <xsl:choose>
	      <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
	      <xsl:otherwise>rtl</xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="@role = 'template'">{<xsl:copy-of select="$content"/>}</xsl:when>
	  <xsl:otherwise><xsl:copy-of select="$content"/></xsl:otherwise>
	</xsl:choose>
      </fo:inline>
    </xsl:template>

    <xsl:template match="*[@role = 'hyphenate-true']">
        <fo:inline hyphenate="true"><xsl:apply-imports/></fo:inline>
    </xsl:template>

    <xsl:template name="badMatch">
        <fo:inline color="red">this?</fo:inline>
    </xsl:template>

    <xsl:param name="builtForOpenStack">
      <xsl:choose>
	<xsl:when test="$branding = 'rackspace-private-cloud'">1</xsl:when>
	<xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:template name="book.titlepage.recto">
      <xsl:variable name="url">
	  <xsl:choose>
	    <xsl:when test="$coverUrl != ''"><xsl:value-of select="$coverUrl"/></xsl:when>
	    <xsl:when test="$branding = 'rackspace'">docs.rackspace.com/api</xsl:when>
	    <xsl:when test="$branding = 'rackspace-private-cloud'">rackspace.com/cloud/private</xsl:when>
	    <xsl:when test="$branding = 'openstack'">docs.openstack.org</xsl:when>
	    <xsl:when test="$branding = 'repose'">www.openrepose.org</xsl:when>
	  </xsl:choose>
      </xsl:variable>

      <xsl:if test="$builtForOpenStack != 0 or $secondaryCoverLogoPath != 0">
	<fo:block-container absolute-position="fixed" left="1in" top="8in">
	  <fo:block>
	    <fo:external-graphic>
	      <xsl:attribute name="src">
		<xsl:choose>
		  <xsl:when test="$secondaryCoverLogoPath != 0">url(<xsl:value-of select="$secondaryCoverLogoPath"/>)</xsl:when>
		  <xsl:otherwise><xsl:value-of select="concat('url(',$cloud.api.cc.image.dir,'/../built-for-openstack.svg)')"/></xsl:otherwise>
		</xsl:choose>
	      </xsl:attribute>
	    </fo:external-graphic>
	  </fo:block>
	</fo:block-container>
      </xsl:if>
      <xsl:if test="$omitCover = '0'">
      <fo:block-container absolute-position="fixed" 
			  left="5.6in" top="9.28in" 
			  width="2.25in"
			  >				       <!--border="0.5pt solid red"-->
	<xsl:attribute name="left">
	  <xsl:choose>
	    <xsl:when test="$coverLogoLeft != ''"><xsl:value-of select="$coverLogoLeft"/></xsl:when>
	    <xsl:when test="$branding = 'rackspace'">5.6in</xsl:when>
	    <xsl:when test="$branding = 'rackspace-private-cloud'">3in</xsl:when>
	    <xsl:when test="$branding = 'openstack'">5.2in</xsl:when>
	    <xsl:when test="$branding = 'repose'">3.9in</xsl:when>
	    <xsl:otherwise>5.6in</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<xsl:attribute name="top">
	  <xsl:choose>
	    <xsl:when test="$coverLogoTop != ''"><xsl:value-of select="$coverLogoTop"/></xsl:when>
	    <xsl:when test="$branding = 'rackspace'">9.28in</xsl:when>
	    <xsl:when test="$branding = 'rackspace-private-cloud'">9.25in</xsl:when>
	    <xsl:when test="$branding = 'openstack'">9.0in</xsl:when>
	    <xsl:when test="$branding = 'repose'">4.9in</xsl:when>
	    <xsl:otherwise>9.0in</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<fo:block>
	  <fo:external-graphic>
	    <xsl:attribute name="src">
	      <xsl:choose>
		<xsl:when test="$branding = 'rackspace-private-cloud'">
		  <xsl:value-of select="concat('url(',$cloud.api.cc.image.dir,'/../rpc-coverlogo.png)')"/>
		</xsl:when>
		<xsl:when test="$coverLogoPath != ''">url(<xsl:value-of select="$coverLogoPath"/>)</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="concat('url(',$cloud.api.cc.image.dir,'/../',$branding,'-logo.svg)')"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	  </fo:external-graphic>
	</fo:block>
	<fo:block text-align="center" font-size="9pt" font-family="sans-serif">
	  <fo:basic-link external-destination="url(http://{$url})"><xsl:value-of select="$url"/></fo:basic-link>
	</fo:block>
      </fo:block-container>
      </xsl:if>
    </xsl:template>

<xsl:template match="d:chapter|d:appendix" mode="insert.title.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="title"/>

  <xsl:choose>
    <xsl:when test="$purpose = 'xref'">
      <!-- <fo:inline font-style="italic"> -->
        <xsl:copy-of select="$title"/>
      <!-- </fo:inline> -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$title"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="footer.table">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <!-- default is a single table style for all footers -->
  <!-- Customize it for different page classes or sequence location -->

  <xsl:choose>
      <xsl:when test="$pageclass = 'index'">
          <xsl:attribute name="margin-{$direction.align.start}">0pt</xsl:attribute>
      </xsl:when>
  </xsl:choose>

  <xsl:variable name="column1">
    <xsl:choose>
      <xsl:when test="$double.sided = 0">1</xsl:when>
      <xsl:when test="$sequence = 'first' or $sequence = 'odd'">1</xsl:when>
      <xsl:otherwise>3</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="column3">
    <xsl:choose>
      <xsl:when test="$double.sided = 0">3</xsl:when>
      <xsl:when test="$sequence = 'first' or $sequence = 'odd'">3</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="candidate">
    <fo:table xsl:use-attribute-sets="footer.table.properties">
      <xsl:call-template name="foot.sep.rule">
        <xsl:with-param name="pageclass" select="$pageclass"/>
        <xsl:with-param name="sequence" select="$sequence"/>
        <xsl:with-param name="gentext-key" select="$gentext-key"/>
      </xsl:call-template>
      <fo:table-column column-number="1">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">footer</xsl:with-param>
            <xsl:with-param name="position" select="$column1"/>
            <xsl:with-param name="pageclass" select="$pageclass"/>
            <xsl:with-param name="sequence" select="$sequence"/>
            <xsl:with-param name="gentext-key" select="$gentext-key"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>
      <fo:table-column column-number="2">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">footer</xsl:with-param>
            <xsl:with-param name="position" select="2"/>
            <xsl:with-param name="pageclass" select="$pageclass"/>
            <xsl:with-param name="sequence" select="$sequence"/>
            <xsl:with-param name="gentext-key" select="$gentext-key"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>
      <fo:table-column column-number="3">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">footer</xsl:with-param>
            <xsl:with-param name="position" select="$column3"/>
            <xsl:with-param name="pageclass" select="$pageclass"/>
            <xsl:with-param name="sequence" select="$sequence"/>
            <xsl:with-param name="gentext-key" select="$gentext-key"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>

      <fo:table-body>
        <fo:table-row>
          <xsl:attribute name="block-progression-dimension.minimum">
            <xsl:value-of select="$footer.table.height"/>
          </xsl:attribute>
          <fo:table-cell text-align="start"
                         display-align="after">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.start"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell text-align="center"
                         display-align="after">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="'center'"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell text-align="end"
                         display-align="after">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.end"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </xsl:variable>

  <!-- Really output a footer? -->
  <xsl:choose>
    <xsl:when test="$pageclass='titlepage' and ($gentext-key = 'book' or $gentext-key = 'part') 
                    and $sequence='first'">
      <!-- no, book titlepages have no footers at all -->
    </xsl:when>
    <xsl:when test="$sequence = 'blank' and $footers.on.blank.pages = 0">
      <!-- no output -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$candidate"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:copyright" mode="book.titlepage.verso.auto.mode">
  <xsl:choose>
    <xsl:when test="$branding = 'rackspace'"><xsl:call-template name="dingbat">
      <xsl:with-param name="dingbat">copyright</xsl:with-param>
      </xsl:call-template><xsl:call-template name="datetime.format">
      <xsl:with-param name="date" select="date:date-time()"/>
      <xsl:with-param name="format" select="'Y'"/>
      </xsl:call-template> Rackspace US, Inc.</xsl:when>
    <xsl:otherwise>
  <xsl:call-template name="gentext">
    <xsl:with-param name="key" select="'Copyright'"/>
  </xsl:call-template>
  <xsl:call-template name="gentext.space"/>
  <xsl:call-template name="dingbat">
    <xsl:with-param name="dingbat">copyright</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="gentext.space"/>
  <xsl:call-template name="copyright.years">
    <xsl:with-param name="years" select="d:year"/>
    <xsl:with-param name="print.ranges" select="$make.year.ranges"/>
    <xsl:with-param name="single.year.ranges"
                    select="$make.single.year.ranges"/>
  </xsl:call-template>
  <xsl:call-template name="gentext.space"/>
  <xsl:apply-templates select="d:holder" mode="titlepage.mode"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- from fo/lists.xsl: Modified to make terms bold for openstack -->
<xsl:template match="d:varlistentry/d:term">
  <fo:inline>
    <xsl:if test="$branding = 'openstack'">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
    </xsl:if>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </fo:inline>
  <xsl:choose>
    <xsl:when test="not(following-sibling::d:term)"/> <!-- do nothing -->
    <xsl:otherwise>
      <!-- * if we have multiple terms in the same varlistentry, generate -->
      <!-- * a separator (", " by default) and/or an additional line -->
      <!-- * break after each one except the last -->
      <fo:inline><xsl:value-of select="$variablelist.term.separator"/></fo:inline>
      <xsl:if test="not($variablelist.term.break.after = '0')">
        <fo:block/>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
