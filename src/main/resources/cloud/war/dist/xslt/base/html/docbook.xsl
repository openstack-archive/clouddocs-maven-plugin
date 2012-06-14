<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
		xmlns:db="http://docbook.org/ns/docbook"
		exclude-result-prefixes="h f m fn db t ghost"
                version="2.0">

  <xsl:include href="classpath:/cloud/war/dist/xslt/base/VERSION.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/param.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/control.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/l10n.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/spspace.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/gentext.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/normalize.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/functions.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/common.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/label-content.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/title-content.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/inlines.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/olink.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/preprocess.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/common/titlepages.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/titlepage-templates.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/titlepage-mode.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/autotoc.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/toc.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/division.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/component.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/refentry.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/synopsis.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/section.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/biblio.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/pi.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/info.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/glossary.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/table.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/lists.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/task.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/callouts.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/formal.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/blocks.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/msgset.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/graphics.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/footnotes.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/admonitions.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/verbatim.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/qandaset.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/inlines.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/xref.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/xlink.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/math.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/html.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/index.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/autoidx.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/chunker.xsl"/>

<!-- ============================================================ -->

<xsl:output method="xhtml" encoding="utf-8" indent="no" />
<xsl:output name="xml" method="xml" encoding="utf-8" indent="no"/>
<xsl:output name="final" method="xhtml" encoding="utf-8" indent="no"/>

<xsl:param name="stylesheet.result.type" select="'xhtml'"/>

<xsl:template match="/">
  <xsl:variable name="root" as="element()"
		select="f:docbook-root-element(f:preprocess(/),$rootid)"/>

  <xsl:if test="$verbosity &gt; 3">
    <xsl:message>Styling...</xsl:message>
  </xsl:if>

  <html>
    <xsl:call-template name="t:head">
      <xsl:with-param name="node" select="$root"/>
    </xsl:call-template>
    <body>
      <xsl:call-template name="t:body-attributes"/>
      <xsl:if test="$root/@status">
        <xsl:attribute name="class" select="$root/@status"/>
      </xsl:if>

      <xsl:apply-templates select="$root"/>
    </body>
  </html>

  <xsl:for-each select=".//db:mediaobject[db:textobject[not(db:phrase)]]">
    <xsl:call-template name="t:write-longdesc"/>
  </xsl:for-each>
</xsl:template>

<xsl:template match="*">
  <div class="unknowntag">
    <xsl:sequence select="f:html-attributes(.)"/>
    <font color="red">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:for-each select="@*">
	<xsl:text> </xsl:text>
	<xsl:value-of select="name(.)"/>
	<xsl:text>="</xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>"</xsl:text>
      </xsl:for-each>
      <xsl:text>&gt;</xsl:text>
    </font>
    <xsl:apply-templates/>
    <font color="red">
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:text>&gt;</xsl:text>
    </font>
  </div>
</xsl:template>

<!-- ============================================================ -->

</xsl:stylesheet>
