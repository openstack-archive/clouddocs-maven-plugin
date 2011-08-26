<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://docbook.org/ns/docbook" xmlns:wadl="http://wadl.dev.java.net/2009/02"       xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:d="http://docbook.org/ns/docbook" xmlns:rax="http://docs.rackspace.com/api"
	exclude-result-prefixes="wadl rax d" version="1.0">
	
	<!-- For readability while testing -->
	<!-- <xsl:output indent="yes"/>    -->

	<xsl:param name="project.build.directory">../../target</xsl:param>

	<xsl:variable name="root" select="/"/>

<!-- Uncomment this template for testing in Oxygen -->
<!--	<xsl:template match="/">
		<xsl:apply-templates mode="preprocess"/>
	</xsl:template>-->

	<xsl:template match="@*|node()" mode="preprocess">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="preprocess"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="d:chapter[@role = 'api-reference']" mode="preprocess">
		<xsl:element name="{name(.)}">
			<xsl:apply-templates select="d:*[not(local-name() = 'section')]" mode="preprocess"/>
			<!-- 
			 Here we build a summary template for whole reference. 
  			 Combine the tables for a section into one big table
		    -->
			<informaltable rules="all">
				<col width="10%"/>
				<col width="40%"/>
				<col width="50%"/>
				<thead>
					<tr align="center">
						<th>Verb</th>
						<th>URI</th>
						<th>Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="//wadl:resources" mode="cheat-sheet"/>
				</tbody>
			</informaltable>

			<xsl:apply-templates select="d:section" mode="preprocess"/>
		</xsl:element>
	</xsl:template>

	<!-- ======================================== -->
	<!-- Here we resolve an wadl stuff we find    -->
	<!-- ======================================== -->


	<xsl:template match="wadl:resources" mode="cheat-sheet">
		<tr>
			<th colspan="3" align="center">
				<xsl:value-of select="parent::d:section/d:title"/>
			</th>
		</tr>
		<xsl:apply-templates select="wadl:resource" mode="method-rows"/>

	</xsl:template>

	<xsl:template match="wadl:resources" mode="preprocess">
		<!-- Make a summary table then apply templates to wadl:resource/wadl:method (from wadl) -->
		<informaltable rules="all">
			<col width="10%"/>
			<col width="40%"/>
			<col width="50%"/>
			<thead>
				<tr align="center">
					<th>Verb</th>
					<th>URI</th>
					<th>Description</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="wadl:resource" mode="method-rows"/>
			</tbody>
		</informaltable>

		<xsl:apply-templates select=".//wadl:resource" mode="preprocess"/>
	</xsl:template>

	<xsl:template match="wadl:resource" mode="method-rows">
		<xsl:variable name="wadl.path">
			<xsl:call-template name="wadlPath">
				<xsl:with-param name="path" select="@href"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="@href">
				<xsl:apply-templates
					select="document($wadl.path,$root)//wadl:resource[@id = substring-after(current()/@href,'#')]/wadl:method[@rax:id = current()/wadl:method/@href]"
					mode="method-rows"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="wadl:method" mode="method-rows"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="wadl:resource" mode="preprocess">
		<xsl:variable name="wadl.path">
			<xsl:call-template name="wadlPath">
				<xsl:with-param name="path" select="@href"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="@href">
				<xsl:apply-templates
					select="document($wadl.path,$root)//wadl:resource[@id = substring-after(current()/@href,'#')]/wadl:method[@rax:id = current()/wadl:method/@href]"
					mode="preprocess"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="wadl:method" mode="preprocess"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="wadl:method" mode="method-rows">
		<xsl:call-template name="method-row"/>
	</xsl:template>

	<xsl:template match="wadl:method" mode="preprocess">
		<xsl:variable name="replacechars">/{}</xsl:variable>
		<section xml:id="{concat(@name,'_',translate(parent::wadl:resource/@path, $replacechars, '___'))}">
			<title>
				<xsl:choose>
					<xsl:when test="wadl:doc/@title">
						<xsl:value-of select="wadl:doc/@title"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>Warning: No title found for wadl:method</xsl:message>
						<xsl:value-of select="parent::wadl:resource/@path"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<informaltable rules="all">
				<col width="10%"/>
				<col width="40%"/>
				<col width="50%"/>
				<thead>
					<tr align="center">
						<th>Verb</th>
						<th>URI</th>
						<th>Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:call-template name="method-row"/>
				</tbody>
			</informaltable>

			<xsl:apply-templates select="wadl:doc" mode="process-xhtml"/>

			<itemizedlist spacing="compact">
				<title>Request parameters</title>
				<xsl:apply-templates
					select="wadl:request/wadl:param|ancestor::wadl:resource/wadl:param"
					mode="preprocess">
					<xsl:sort select="@style"/>
				</xsl:apply-templates>
			</itemizedlist>

			<itemizedlist spacing="compact">
				<title>Response parameters</title>
				<xsl:apply-templates
					select="wadl:method[1]/wadl:request/wadl:param|ancestor-or-self::*/wadl:param"
					mode="preprocess"/>
			</itemizedlist>

			<xsl:if test="wadl:response[starts-with(normalize-space(@status),'2')]">
				<itemizedlist spacing="compact">
					<title>Normal Response Code(s)</title>
					<xsl:apply-templates select="wadl:response" mode="preprocess-normal"/>
				</itemizedlist>
			</xsl:if>
			<xsl:if test="wadl:response[not(starts-with(normalize-space(@status),'2'))]">

				<itemizedlist spacing="compact">
					<title>Error Response Code(s)</title>
					<xsl:apply-templates select="wadl:response" mode="preprocess-faults"/>
				</itemizedlist>
			</xsl:if>
		</section>
	</xsl:template>

	<xsl:template name="method-row">
		<tr>
			<td>
				<command>
					<xsl:value-of select="@name"/>
				</command>
			</td>
			<td>
				<code>
					<!-- 
						TODO: Deal with non-flattened path in embedded wadl? 
						TODO: Chop off v2.0 or whatever...
					-->
					<xsl:value-of select="parent::wadl:resource/@path"/>
					<xsl:for-each select="wadl:request/wadl:param[@style = 'query']">
						<xsl:text>&#x200b;</xsl:text><xsl:if test="position() = 1"
							>?</xsl:if><xsl:value-of select="@name"/>=<replaceable><xsl:value-of
								select="substring-after(@type,':')"/></replaceable><xsl:if
							test="not(position() = last())">&amp;</xsl:if>
					</xsl:for-each>
				</code>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="wadl:doc//*[@class = 'shortdesc']">
						<xsl:apply-templates select="wadl:doc//*[@class = 'shortdesc'][1]" mode="process-shortdesc"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="wadl:doc" mode="process-xhtml"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="wadl:doc" mode="process-xhtml">
		<xsl:apply-templates mode="process-xhtml"/>
	</xsl:template>

	<xsl:template match="*"  mode="process-shortdesc">
		<xsl:apply-templates mode="process-xhtml"/>
	</xsl:template>

	<xsl:template match="xhtml:p[@class = 'shortdesc']" mode="process-xhtml"/>

	<xsl:template match="xhtml:p[not(self::xhtml:p/@class = 'shortdesc')]"  mode="process-xhtml">
		<para>
			<xsl:apply-templates mode="process-xhtml"/>
		</para>
	</xsl:template>
	
	<xsl:template match="xhtml:b|xhtml:strong"  mode="process-xhtml">
		<emphasis role="bold"><xsl:apply-templates  mode="process-xhtml"/></emphasis>
	</xsl:template>
	
	<xsl:template match="xhtml:i|xhtml:em"  mode="process-xhtml">
		<emphasis><xsl:apply-templates  mode="process-xhtml"/></emphasis>
	</xsl:template>
	
		<xsl:template match="xhtml:code|xhtml:tt"  mode="process-xhtml">
		<code><xsl:apply-templates  mode="process-xhtml"/></code>
	</xsl:template>

	<xsl:template match="xhtml:span|xhtml:div"  mode="process-xhtml">
		<xsl:apply-templates  mode="process-xhtml"/>
	</xsl:template>
	
	<xsl:template match="xhtml:ul" mode="process-xhtml">
		<itemizedlist>
			<xsl:apply-templates  mode="process-xhtml"/>			
		</itemizedlist>
	</xsl:template>

	<xsl:template match="xhtml:ol" mode="process-xhtml">
		<orderedlist>
			<xsl:apply-templates  mode="process-xhtml"/>			
		</orderedlist>
	</xsl:template>
	
	<!-- TODO: Try to make this less brittle. What if they have a li/ul or li/table? -->
	<xsl:template match="xhtml:li[not(xhtml:p)]" mode="process-xhtml">
		<listitem>
			<para>
			  <xsl:apply-templates  mode="process-xhtml"/>	
			</para>
		</listitem>
	</xsl:template>

	<xsl:template match="xhtml:li[xhtml:p]" mode="process-xhtml">
		<listitem>
		   <xsl:apply-templates  mode="process-xhtml"/>	
		</listitem>
	</xsl:template>
	
	<xsl:template match="xhtml:table" mode="process-xhtml">
		<informaltable>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates  mode="xhtml2docbookns"/>
		</informaltable>
	</xsl:template>
	
	<xsl:template match="xhtml:pre" mode="process-xhtml">
		<programlisting>
			<xsl:apply-templates mode="process-xhtml"/>
		</programlisting>
	</xsl:template>
	
	<xsl:template match="*" mode="xhtml2docbookns">
		<xsl:element name="{local-name(.)}" namespace="http://docbook.org/ns/docbook">
			<xsl:apply-templates mode="xhtml2docbookns"/>
		</xsl:element>
	</xsl:template>
	
	<!-- TODO: handle more xhtml: div -->

	<xsl:template match="wadl:param" mode="preprocess">
		<!-- TODO: Get more info from the xsd about these params-->
		<listitem>
			<para>
				<xsl:value-of select="@name"/> (<xsl:value-of select="@style"/>): <xsl:value-of
					select="wadl:doc"/>
				<xsl:value-of select="substring-after(@type,':')"/>. </para>
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

	<xsl:template match="wadl:response" mode="preprocess-normal">
		<xsl:if test="starts-with(normalize-space(@status),'2')">
			<listitem>
				<para>
					<xsl:value-of select="substring-after(wadl:representation/@element,':')"/>
						(<xsl:value-of select="@status"/>)
				</para>
			</listitem>
		</xsl:if>
	</xsl:template>

	<xsl:template match="wadl:response" mode="preprocess-faults">
		<xsl:if
			test="not(starts-with(normalize-space(@status),'2')) and wadl:representation/@element">
			<listitem>
				<para>
					<xsl:value-of select="substring-after(wadl:representation/@element,':')"/>
						(<xsl:value-of select="@status"/>)
				</para>
			</listitem>
		</xsl:if>
	</xsl:template>

	<!-- ======================================== -->

	<xsl:template name="wadlPath">
		<xsl:param name="path"/>
		<xsl:choose>
			<xsl:when test="contains($path,'#')">
				<xsl:call-template name="wadlPath">
					<xsl:with-param name="path" select="substring-before($path,'#')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($path,'\')">
				<xsl:call-template name="wadlPath">
					<xsl:with-param name="path" select="substring-after($path,'\')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($path,'/')">
				<xsl:call-template name="wadlPath">
					<xsl:with-param name="path" select="substring-after($path,'/')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of
					select="concat($project.build.directory, '/generated-resources/xml/xslt/',$path)"
				/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>