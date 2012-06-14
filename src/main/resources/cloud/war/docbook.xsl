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

  <xsl:import href="classpath:/cloud/war/dist/xslt/base/html/docbook.xsl"/>
  <xsl:include href="classpath:/cloud/war/dist/xslt/base/html/chunktemp.xsl"/>
  <xsl:param name="use.id.as.filename" select="'1'"/>
  <!-- <xsl:param name="html.ext" select="'.jspx'"/> -->
  <xsl:param name="linenumbering" as="element()*">
    <ln xmlns="http://docbook.org/ns/docbook" path="literallayout" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <!-- <ln xmlns="http://docbook.org/ns/docbook"  -->
    <!-- 	path="programlisting"  -->
    <!-- 	everyNth="2"  -->
    <!-- 	width="3"  -->
    <!-- 	separator=" "  -->
    <!-- 	padchar=" "  -->
    <!-- 	minlines="3"/> -->
    <ln xmlns="http://docbook.org/ns/docbook" path="programlistingco" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="screen" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="synopsis" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="address" everyNth="0"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="epigraph/literallayout" everyNth="0"/>
  </xsl:param>

  <xsl:param name="l10n.locale.dir">classpath:/cloud/war/dist/xslt/base/common/locales/</xsl:param>

  <xsl:param name="base.dir" select="'target/docbkx/xhtml/example/'"/>

<xsl:template name="t:system-head-content">
  <xsl:param name="node" select="."/>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <!-- system.head.content is like user.head.content, except that
       it is called before head.content. This is important because it
       means, for example, that <style> elements output by system-head-content
       have a lower CSS precedence than the users stylesheet. -->

  <!-- See http://remysharp.com/2009/01/07/html5-enabling-script/ -->
  <!--
  <xsl:comment>[if lt IE 9]>
&lt;script src="http://html5shim.googlecode.com/svn/trunk/html5.js">&lt;/script>
&lt;![endif]</xsl:comment>
  -->
</xsl:template>

<xsl:template name="t:javascript">
  <xsl:param name="node" select="."/>

  <xsl:if test="//db:annotation">
    <script type="text/javascript" src="{concat($resource.root, 'js/AnchorPosition.js')}">&#160;</script>
    <script type="text/javascript" src="{concat($resource.root, 'js/PopupWindow.js')}">&#160;</script>
    <script type="text/javascript" src="{concat($resource.root, 'js/annotation.js')}">&#160;</script>
  </xsl:if>

  <script type="text/javascript" src="{concat($resource.root, 'js/dbmodnizr.js')}">&#160;</script>
</xsl:template>

<xsl:param name="autolabel.elements">
  <db:refsection/>
</xsl:param>

</xsl:stylesheet>