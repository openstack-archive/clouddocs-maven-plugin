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

  <xsl:import href="dist/xslt/base/html/docbook.xsl"/>
  <xsl:include href="dist/xslt/base/html/chunktemp.xsl"/>
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

  <xsl:template match="/" priority="10">
    <xsl:choose>
      <xsl:when test="$rootid = ''">
        <xsl:apply-templates select="$chunks" mode="m:chunk"/>
      </xsl:when>
      <xsl:when test="$chunks[@xml:id = $rootid]">
        <xsl:apply-templates select="$chunks[@xml:id = $rootid]" mode="m:chunk"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>There is no chunk with the ID: </xsl:text>
          <xsl:value-of select="$rootid"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <db:book/>
    
    <xsl:result-document 
        href="target/docbkx/xhtml/example/bookinfo.xml" 
        method="xml" indent="yes" encoding="UTF-8">
<!--      <products xmlns="">
        <product>
          <id>1</id>
          <types>
            <type>
              <id>1</id>
              <displayname>Legal notice</displayname>
              <url>/example/example-foo.html</url>
              <sequence>2</sequence> 
            </type>
            <type>
              <id>2</id>
              <displayname>Overview</displayname>
              <url>/example/Overview.html</url>
              <sequence>2</sequence>
            </type>
            <type>
              <id>2</id>
              <displayname>Intended Audience</displayname>
              <url>/example/section_eow_tmw_ad.html</url>
              <sequence>2</sequence>
            </type>
          </types>     
        </product>
      </products>  -->    
      
      <products xmlns="">
        <product>
          <!-- HACK...FIXME -->
          <id><xsl:apply-templates select="//db:productname" mode="bookinfo"/></id>
           <types>
      <xsl:choose>
        <xsl:when test="$rootid = ''">
          <xsl:apply-templates select="$chunks" mode="bookinfo"/>
        </xsl:when>
        <xsl:when test="$chunks[@xml:id = $rootid]">
          <xsl:apply-templates select="$chunks[@xml:id = $rootid]" mode="bookinfo"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            <xsl:text>There is no chunk with the ID: </xsl:text>
            <xsl:value-of select="$rootid"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
           </types>
        </product>
      </products>
    </xsl:result-document>
    
    <xsl:result-document 
      href="target/docbkx/xhtml/example/WEB-INF/web.xml" 
      method="xml" indent="yes" encoding="UTF-8">
      <web-app version="2.4" xmlns="http://java.sun.com/xml/ns/j2ee"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="
        http://java.sun.com/xml/ns/j2ee  http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">
       <xsl:comment>Noop</xsl:comment>
      </web-app>
    </xsl:result-document>
    
  </xsl:template>
  
  <xsl:template match="db:book|db:chapter|db:preface|db:section|db:appendix|db:glossary|db:part|db:index" mode="bookinfo">
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="processing-instruction('rax')">
          <xsl:value-of select="f:pi(processing-instruction('rax'),'type')"/>
        </xsl:when>
        <xsl:when test="ancestor::*[processing-instruction('rax')]">
          <xsl:value-of select="f:pi(ancestor::*[processing-instruction('rax')]/processing-instruction('rax')[1],'type')"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="idNumber">
      <xsl:choose>
        <xsl:when test="$type = 'concepts'">1</xsl:when>
        <xsl:when test="$type = 'apiref'">2</xsl:when>
        <xsl:when test="$type = 'advanced'">3</xsl:when>
        <xsl:otherwise>4</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="priority"><xsl:value-of select="f:pi(processing-instruction('rax'),'priority')"/></xsl:variable>
    
    <xsl:variable name="priorityCalculated">
      <xsl:choose>
        <xsl:when test="normalize-space($priority) != ''">
          <xsl:value-of select="normalize-space($priority)"/>
        </xsl:when>
        <xsl:otherwise>100000</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <type xmlns="">
      <id><xsl:value-of select="$idNumber"/></id>
      <displayname><xsl:value-of select=".//db:title[1]"/></displayname>
      <url>/example/<xsl:value-of select="f:chunk-filename(.)"/></url>
      <sequence><xsl:value-of select="$priorityCalculated"/></sequence> 
    </type>
    <xsl:apply-templates select="db:book|db:chapter|db:preface|db:section|db:appendix|db:glossary|db:part|db:index" mode="bookinfo"/>
  </xsl:template>

  <xsl:template match="db:productname" mode="bookinfo">
    <xsl:choose>
      <xsl:when test="preceding::db:productname"/>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Servers')">1</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Databases')">2</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Monitoring')">3</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Block Storage')">4</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Files')">5</xsl:when>
    </xsl:choose>  
  </xsl:template>
  
  <xsl:template match="text()" mode="bookinfo"/>

</xsl:stylesheet>