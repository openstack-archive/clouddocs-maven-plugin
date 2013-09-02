<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:wadl="http://wadl.dev.java.net/2009/02"
	xmlns:rax="http://docs.rackspace.com/api"
	xmlns="http://docbook.org/ns/docbook" 
	exclude-result-prefixes="wadl rax" version="2.0">

	<doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
		<desc> 
			This xslt handles the "point-to-wadl" method of
			including content from a wadl into a document by copying
			the wadl into the DocBook document. It also handles the
			"start-sections" processing instruction which causes the
			wadl to be broken up into sections starting with the
			siblings of the PI. 
			
			The goal is to end up processing a DocBook document 
			that contains pure wadl with not pointers outside 
			the file.
		</desc>
	</doc>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:if test="self::wadl:method">
				<xsl:attribute name="rax:original-wadl" select="ancestor::wadl:application/@rax:original-wadl"/>
			</xsl:if>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="wadl:resources[@href]">

		<xsl:apply-templates select="document(@href)//rax:resources"/>
	</xsl:template>

	<xsl:template match="rax:resources">
		<xsl:choose>
			<xsl:when test=".//processing-instruction('rax') = 'start-sections'">
				<xsl:apply-templates select="rax:resource"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="wadl:resources"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="rax:resource">
		<xsl:choose>
			<xsl:when
				test="parent::*[./processing-instruction('rax') = 'start-sections']">
				<xsl:apply-templates mode="start-sections"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="rax:resource" mode="start-sections">
		<xsl:variable name="rax-id" select="@rax:id"/>
		<section
			xml:id="{translate(//wadl:resource[@id = $rax-id]/@path,'/{}:','___')}">
			<title>
				<xsl:choose>
					<xsl:when test="//wadl:resource[@id = current()/@rax:id]/wadl:doc/@title">
						<xsl:value-of select="//wadl:resource[@id = current()/@rax:id]/wadl:doc/@title"/>
					</xsl:when>
					<xsl:when test="//wadl:resource[@id = current()/@rax:id]">
						<xsl:value-of select="//wadl:resource[@id = current()/@rax:id]/@path"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="no"> ERROR: Could not determine what title to use for
								<xsl:copy-of select="."/>
						</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<xsl:apply-templates
				select="//wadl:resource[@id = current()/@rax:id]/wadl:doc/*"/>
			<wadl:resources>
				<xsl:apply-templates select="//wadl:resource[@id = current()/@rax:id]"/>
				<xsl:apply-templates select="rax:resource" mode="continue-section"/>
			</wadl:resources>
		</section>
	</xsl:template>

	<xsl:template match="rax:resource" mode="continue-section">
		<xsl:apply-templates
			select="//wadl:resource[@id = current()/@rax:id]"/>
		<xsl:apply-templates select="rax:resource" mode="continue-section"/>
	</xsl:template>

</xsl:stylesheet>
