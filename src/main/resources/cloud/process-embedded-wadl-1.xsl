<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:wadl="http://wadl.dev.java.net/2009/02"
	xmlns:rax="http://docs.rackspace.com/api" 
	xmlns:d="http://docbook.org/ns/docbook" 
	xmlns="http://docbook.org/ns/docbook" 
	exclude-result-prefixes="wadl rax d" version="2.0">

	 <xsl:import href="classpath:///cloud/date.xsl"/>
	<!--<xsl:import href="date.xsl"/>-->

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
		<xsl:param name="xmlid"/>
		<xsl:copy>
			<xsl:if test="self::wadl:method[ancestor::wadl:application]">
				<xsl:attribute name="rax:original-wadl" select="ancestor::wadl:application/@rax:original-wadl"/>
			</xsl:if>
			<xsl:apply-templates select="@*|node()">
				<xsl:with-param name="xmlid" select="$xmlid"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="wadl:resources[@href]">
		<xsl:apply-templates select="document(@href)//rax:resources">
			<xsl:with-param name="xmlid" select="@xml:id"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="rax:resources">
		<xsl:param name="xmlid"/>
		<xsl:choose>
			<xsl:when test=".//processing-instruction('rax') = 'start-sections'">
				<xsl:apply-templates select="rax:resource">
					<xsl:with-param name="xmlid" select="$xmlid"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="//wadl:resources">
					<xsl:with-param name="xmlid" select="$xmlid"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="rax:resource[not(parent::*[./processing-instruction('rax') = 'start-sections'])]">
		<xsl:param name="xmlid"/>
		<xsl:apply-templates>
			<xsl:with-param name="xmlid" select="$xmlid"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="rax:resource[parent::*[./processing-instruction('rax') = 'start-sections']]">
		<xsl:param name="xmlid"/>
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
				select="//wadl:resource[@id = current()/@rax:id]/wadl:doc/*">
				<xsl:with-param name="xmlid" select="@xmlid"/>
			</xsl:apply-templates>
			<wadl:resources>
				<xsl:if test="normalize-space($xmlid) != ''">
					<xsl:attribute name="xml:id" select="$xmlid"/>
				</xsl:if>
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
	
	<!-- Unrelated stuff: Doesn't really belong here -->
	
	<xsl:template match="processing-instruction('rax')[normalize-space(.) = 'fail']">
		<xsl:message terminate="yes">
			!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			&lt;?rax fail?> found in the document.
			!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		</xsl:message>
	</xsl:template>
	
	<xsl:template match="processing-instruction('rax')[normalize-space(.) = 'revhistory']" >
		<xsl:if test="//d:revhistory[1]/d:revision">
			<informaltable rules="all">
				<col width="20%"/>
				<col width="80%"/>
				<thead>
					<tr>
						<td align="center">Revision Date</td>
						<td align="center">Summary of Changes</td>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="//d:revhistory[1]/d:revision" mode="revhistory"/>        	
				</tbody>
			</informaltable>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="d:revision" mode="revhistory">
		<tr>
			<td valign="top">
				<para>
					<xsl:call-template name="longDate">
						<xsl:with-param name="in"  select="d:date"/>
					</xsl:call-template>
				</para>
			</td>
			<td>
				<xsl:copy-of select="d:revdescription/*"/>
			</td>
		</tr>
	</xsl:template>
	
	

</xsl:stylesheet>
