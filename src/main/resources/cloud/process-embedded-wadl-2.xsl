<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://docbook.org/ns/docbook" 
	xmlns:wadl="http://wadl.dev.java.net/2009/02"       
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:d="http://docbook.org/ns/docbook" 
	xmlns:rax="http://docs.rackspace.com/api" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="wadl rax d xhtml" 
	version="2.0">
		

	<!-- <xsl:output indent="yes"/> -->
	
	<doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
		<desc>
			This xslt copies in content from the wadl when it is 
			referred to by resource or by method.
			
			The goal is to end up processing a DocBook document 
			that contains pure wadl with not pointers outside 
			the file.
		</desc>
	</doc>
	
	<xsl:template match="@*|node()" >
		<xsl:param name="doc"/>
		<xsl:copy>
<!--			<xsl:if test="self::wadl:method">
				<xsl:attribute name="rax:original-wadl" select="ancestor::wadl:application/@rax:original-wadl"/>
			</xsl:if>-->
			<xsl:apply-templates select="@*|node()" >
				<xsl:with-param name="doc" select="$doc"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="wadl:doc[parent::wadl:method[ancestor::wadl:application]]">
		<xsl:param name="doc"/>
		<xsl:variable name="content">
			<xsl:if test="$doc">
				<xsl:apply-templates select="$doc" />	
			</xsl:if>
			<xsl:apply-templates select="node()" />	
		</xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:choose>
				<xsl:when test="not($content//d:para) and not($content//d:formalpara) ">
					<para><xsl:copy-of select="$content"/></para>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$content"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="wadl:doc[ancestor::wadl:doc]">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="wadl:method[@href]">
		<xsl:variable name="wadl-content" select="document(substring-before(parent::wadl:resource/@href, '#'))"/>
		<xsl:variable name="doc" select="wadl:doc/*"/>
		<xsl:variable name="parent-id" select="substring-after(parent::wadl:resource/@href,'#')"/>
		<xsl:variable name="thisMethodId">
			<xsl:choose>
				<xsl:when test="contains(@href,'#')"><xsl:value-of select="substring-after(@href,'#')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="@href"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="$wadl-content/wadl:application/wadl:resources/wadl:resource[@id = $parent-id]/wadl:method[@rax:id = $thisMethodId]/@*"/>
			<xsl:apply-templates select="$wadl-content/wadl:application/wadl:resources/wadl:resource[@id = $parent-id]/wadl:method[@rax:id = $thisMethodId]/node()">
				<xsl:with-param name="doc" select="$doc"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="wadl:resource[@href and not(./wadl:method)]">
		<xsl:variable name="doc" select="wadl:doc/*"/>
		<xsl:variable name="wadl-content" select="document(substring-before(@href, '#'))"/>
		<xsl:apply-templates select="$wadl-content/wadl:application/wadl:resources/wadl:resource[@id = substring-after(current()/@href,'#')]">
			<xsl:with-param name="doc" select="$doc"/>			
		</xsl:apply-templates>	
		<xsl:apply-templates select="wadl:resource"/>
	</xsl:template>

	<xsl:template match="wadl:resource[@href and ./wadl:method]">
		<xsl:variable name="doc" select="wadl:doc/*"/>
		<xsl:variable name="resourceId" select="substring-after(@href,'#')"/>
		<xsl:variable name="wadl-content" select="document(substring-before(@href, '#'))"/>		
		
		<xsl:copy>
			<xsl:apply-templates select="$wadl-content/wadl:application/wadl:resources/wadl:resource[@id = $resourceId]/@*"/>
			<xsl:apply-templates select="$wadl-content/wadl:application/wadl:resources/wadl:resource[@id = $resourceId]/node()[not(self::wadl:method)]">
				<xsl:with-param name="doc" select="$doc"/>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="wadl:method|wadl:resource"/>
        </xsl:copy>
		
	</xsl:template>
	
	<!-- xhtml2docbook -->
	
	<xsl:template match="xhtml:p">
		<para>
			<xsl:apply-templates select="@*|node()"/>
		</para>
	</xsl:template>
	
	<xsl:template match="@class[parent::xhtml:*]">
		<xsl:attribute name="role" select="."/>
	</xsl:template>
	
	<xsl:template match="xhtml:b|xhtml:strong"  >
		<emphasis role="bold"><xsl:apply-templates/></emphasis>
	</xsl:template>
	
	<xsl:template match="xhtml:a[@href]" >
		<link xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{@href}"><xsl:apply-templates /></link>
	</xsl:template>
	
	<xsl:template match="xhtml:i|xhtml:em"  >
		<emphasis><xsl:apply-templates/></emphasis>
	</xsl:template>
	
	<xsl:template match="xhtml:code|xhtml:tt">
		<code><xsl:apply-templates/></code>
	</xsl:template>
	
	<xsl:template match="xhtml:span|xhtml:div">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="xhtml:ul" >
		<itemizedlist>
			<xsl:apply-templates  />			
		</itemizedlist>
	</xsl:template>
	
	<xsl:template match="xhtml:ol" >
		<orderedlist>
			<xsl:apply-templates  />			
		</orderedlist>
	</xsl:template>
	
	<!-- TODO: Try to make this less brittle. What if they have a li/ul or li/table? -->
	<xsl:template match="xhtml:li[not(xhtml:p)]" >
		<listitem>
			<para>
				<xsl:apply-templates/>	
			</para>
		</listitem>
	</xsl:template>
	
	<xsl:template match="xhtml:li[xhtml:p]" >
		<listitem>
			<xsl:apply-templates/>	
		</listitem>
	</xsl:template>
	
	<xsl:template match="xhtml:table">
		<informaltable>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates  mode="xhtml2docbookns"/>
		</informaltable>
	</xsl:template>
	
	<xsl:template match="*" mode="xhtml2docbookns">
		<xsl:element name="{local-name(.)}" namespace="http://docbook.org/ns/docbook">
			<xsl:apply-templates mode="xhtml2docbookns"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="xhtml:pre" >
		<programlisting>
			<xsl:apply-templates />
		</programlisting>
	</xsl:template>

	<xsl:template match="d:SXXP0005">
	  <!-- This stupid template is here to avoid SXXP0005 errors from Saxon -->
	  <xsl:apply-templates/>
	</xsl:template>

</xsl:stylesheet>
