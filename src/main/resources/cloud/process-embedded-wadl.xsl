<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://docbook.org/ns/docbook" 
    xmlns:wadl="http://wadl.dev.java.net/2009/02" 
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:rax="http://docs.rackspace.com/api" 
    exclude-result-prefixes="wadl rax d"
    version="1.0">

    <xsl:variable name="root" select="/"/>
    
    <xsl:template match="@*|node()" mode="preprocess">
      <xsl:copy>
	<xsl:apply-templates select="@*|node()" mode="preprocess"/>
      </xsl:copy>
    </xsl:template>

	<!-- ======================================== -->
	<!-- Here we resolve an wadl stuff we find    -->
	<!-- ======================================== -->
	<xsl:template match="wadl:resources" mode="preprocess">
		<d:informaltable rules="all">
			<d:tbody>
				<d:tr>
					<d:td>
						<d:emphasis role="bold">Verb</d:emphasis>
					</d:td>
					<xsl:apply-templates mode="preprocess-verb"/>
				</d:tr>
				<d:tr>
					<d:td>
						<d:emphasis role="bold">URI</d:emphasis>
					</d:td>
					<xsl:apply-templates mode="preprocess-uri"/>
				</d:tr>
				<d:tr>
					<d:td>
						<d:emphasis role="bold">Description</d:emphasis>
					</d:td>
					<xsl:apply-templates mode="preprocess-description"/>
				</d:tr>
				<d:tr>
					<d:td>
						<d:emphasis role="bold">Parameters</d:emphasis>
					</d:td>
					<xsl:apply-templates mode="preprocess-params"/>
				</d:tr>
				<d:tr>
					<d:td>
						<d:emphasis role="bold">Faults</d:emphasis>
					</d:td>
					<xsl:apply-templates mode="preprocess-faults"/>
				</d:tr>
			</d:tbody>
		</d:informaltable>
	</xsl:template>

	<xsl:template match="wadl:resource[@href]" mode="preprocess-verb">
		<d:td>
			<xsl:value-of select="document(substring-before(@href,'#'),$root)//wadl:method[@rax:id = current()/wadl:method[1]/@href]/@name"/>
		</d:td>
	</xsl:template>

	<xsl:template match="wadl:resource[not(@href)]" mode="preprocess-verb">
		<d:td>
			<xsl:value-of select="wadl:method/@name"/>
		</d:td>
	</xsl:template>

	<xsl:template match="wadl:resource[@href]" mode="preprocess-uri">
		<d:td>
			<xsl:value-of select="document(substring-before(@href,'#'),$root)//wadl:resource[@id = substring-after(current()/@href,'#')]/@path"/>
			
			<!-- TODO: Deal with query params -->
		</d:td>
	</xsl:template>

	<xsl:template match="wadl:resource[not(@href)]" mode="preprocess-uri">
		<d:td>
			<code>
			<xsl:value-of select="@path"/>
			<xsl:for-each select="wadl:method[1]/wadl:request/wadl:param[@style = 'query']">
				<xsl:text>&#x200b;</xsl:text><xsl:if test="position() = 1">?</xsl:if><xsl:value-of select="@name"/>=<replaceable><xsl:value-of select="substring-after(@type,':')"/></replaceable><xsl:if test="not(position() = last())">&amp;</xsl:if>
			</xsl:for-each>
			</code>
		</d:td>
	</xsl:template>

	<xsl:template match="wadl:resource[@href]" mode="preprocess-description">
		<d:td>
			<xsl:value-of select="document(substring-before(@href,'#'),$root)//wadl:method[@rax:id = current()/wadl:method[1]/@href]/wadl:doc"/>
		</d:td>
	</xsl:template>

	<xsl:template match="wadl:resource[not(@href)]" mode="preprocess-description">
		<d:td>
			<xsl:value-of select="wadl:method/wadl:doc"/>
		</d:td>
	</xsl:template>

	<xsl:template match="wadl:resource[@href]" mode="preprocess-params">
		<d:td>
			<xsl:if test="document(substring-before(@href,'#'),$root)//wadl:method[@rax:id = current()/wadl:method[1]/@href]//wadl:param">
				<itemizedlist spacing="compact">
					<xsl:apply-templates select="document(substring-before(@href,'#'),$root)//wadl:method[@rax:id = current()/wadl:method[1]/@href]//wadl:param|document(substring-before(@href,'#'),$root)//wadl:param[@style = 'template' 
						and ( .//wadl:resource[@id = substring-after(current()/@href,'#')] 
						or parent::wadl:resource[@id = substring-after(current()/@href,'#')] )
						]" mode="preprocess-params"/>
						<!--- That xpath feels inelegant, but it's the best I could think of -->
				</itemizedlist>
			</xsl:if>
		</d:td>
	</xsl:template>

	<xsl:template match="wadl:resource[not(@href)]" mode="preprocess-params">
		<d:td>
			<xsl:if test="wadl:method[1]//wadl:param">
				<itemizedlist  spacing="compact">
					<xsl:apply-templates select="wadl:method[1]/wadl:request/wadl:param|ancestor-or-self::*/wadl:param" mode="preprocess-params"/>
				</itemizedlist>
			</xsl:if>
		</d:td>
	</xsl:template>

	<xsl:template match="wadl:param" mode="preprocess-params">
		<listitem>
			<para>
				<xsl:value-of select="@name"/>: <xsl:value-of select="wadl:doc"/>
				<xsl:value-of select="substring-after(@type,':')"/>. 
			</para>
				<xsl:if test="wadl:option">
					<para>Possible values: <xsl:for-each select="wadl:option">
							<xsl:value-of select="@value"/><xsl:choose>
								<xsl:when test="position() = last()">. </xsl:when>
								<xsl:otherwise>, </xsl:otherwise>
							</xsl:choose>
						</xsl:for-each></para>
					<para>Default: <xsl:value-of select="@default"/><xsl:text>. </xsl:text>
					</para>
				</xsl:if>
		</listitem>
	</xsl:template>

	<xsl:template match="wadl:resource[not(@href)]" mode="preprocess-faults">
	  <xsl:if test="wadl:method[1][not(@href)]/wadl:response[not(starts-with(normalize-space(@status),'2')) and wadl:representation/@element]">
		<td>
			<itemizedlist spacing="compact">
				<xsl:apply-templates select="wadl:method[1]" mode="preprocess-faults"/>
			</itemizedlist>
		</td>
	  </xsl:if>
	</xsl:template>

	<xsl:template match="wadl:resource[@href]" mode="preprocess-faults">
	  <xsl:if test="document(substring-before(@href,'#'),$root)//wadl:method[@rax:id = current()/wadl:method[1]/@href]/wadl:response[not(starts-with(normalize-space(@status),'2')) and wadl:representation/@element]">
		<td>
			<itemizedlist spacing="compact">
				<xsl:apply-templates select="document(substring-before(@href,'#'),$root)//wadl:method[@rax:id = current()/wadl:method[1]/@href]" mode="preprocess-faults"/>
			</itemizedlist>
		</td>
	  </xsl:if>
	</xsl:template>

	<xsl:template match="wadl:method" mode="preprocess-faults">
		<xsl:apply-templates select="wadl:response" mode="preprocess-faults"/>
	</xsl:template>

	<xsl:template match="wadl:response" mode="preprocess-faults">
		<xsl:if test="not(starts-with(normalize-space(@status),'2')) and wadl:representation/@element">
			<listitem>
				<para>
					<xsl:value-of select="substring-after(wadl:representation/@element,':')"/> (<xsl:value-of select="@status"/>)<!-- TODO: handle lists -->
				</para>
			</listitem>
		</xsl:if>
	</xsl:template>

	<!-- ======================================== -->
</xsl:stylesheet>