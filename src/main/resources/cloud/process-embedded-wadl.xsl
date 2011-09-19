<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://docbook.org/ns/docbook" xmlns:wadl="http://wadl.dev.java.net/2009/02"       xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:d="http://docbook.org/ns/docbook" xmlns:rax="http://docs.rackspace.com/api"
	exclude-result-prefixes="wadl rax d" version="1.0">
	
	<!-- For readability while testing -->
	<!-- <xsl:output indent="yes"/>    -->

	<xsl:param name="project.build.directory">../../target</xsl:param>
    <xsl:param name="wadl.norequest.msg"><para>This operation does not require a request body.</para></xsl:param>
    <xsl:param name="wadl.noresponse.msg"><para>This operation does not return a response body.</para></xsl:param>
    <xsl:param name="wadl.noreqresp.msg"><para>This operation does not require a request body and does not return a response body.</para></xsl:param>
	<xsl:param name="project.directory" select="substring-before($project.build.directory,'/target')"/>
	<xsl:param name="source.directory"/>
	<xsl:param name="docbook.partial.path" select="concat(substring-after($source.directory,$project.directory),'/')"/>
	<xsl:param name="compute.wadl.path.from.docbook.path" select="'0'"/>

	<xsl:param name="trim.wadl.uri.count">0</xsl:param>

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

	<xsl:template match="d:*[@role = 'api-reference']" mode="preprocess">
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*"/>
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
					<tr>
						<th align="center">Verb</th>
						<th align="center">URI</th>
						<th align="center">Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select=".//wadl:resources" mode="cheat-sheet"/>
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

	<!-- <xsl:template match="wadl:resources[wadl:resource[not(./wadl:method)]]" mode="preprocess"> -->
	<!-- 	<section xml:id="{generate-id()}"> -->
	<!-- 		<title>FOOBAR</title> -->
	<!-- 		<xsl:call-template name="wadl-resources"/> -->
	<!-- 	</section> -->
	<!-- </xsl:template> -->

	<xsl:template match="wadl:resources" name="wadl-resources" mode="preprocess">
        <!-- Handle skipSummary PI -->
		<xsl:variable name="skipSummaryN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
                    <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'skipSummary'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
		</xsl:variable>
        <xsl:variable name="skipSummary" select="boolean(number($skipSummaryN))"/>
		<!-- Make a summary table then apply templates to wadl:resource/wadl:method (from wadl) -->
		<xsl:if test="not($skipSummary)">
			<informaltable rules="all">
				<col width="10%"/>
				<col width="40%"/>
				<col width="50%"/>
				<thead>
					<tr>
						<th align="center">Verb</th>
						<th align="center">URI</th>
						<th align="center">Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="wadl:resource" mode="method-rows"/>
				</tbody>
			</informaltable>
		</xsl:if>

		<xsl:apply-templates select=".//wadl:resource" mode="preprocess"/>
	</xsl:template>

	<xsl:template match="wadl:resource" mode="method-rows">
		<xsl:variable name="wadl.path">
			<xsl:call-template name="wadlPath">
				<xsl:with-param name="path" select="@href"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="href" select="wadl:method/@href"/>

		<xsl:choose>
			<xsl:when test="@href">
			  <xsl:apply-templates mode="method-rows">
			    <xsl:with-param name="wadl.path" select="$wadl.path"/>
			    <xsl:with-param name="resourceId" select="substring-after(current()/@href,'#')"/>
			  </xsl:apply-templates>

				<!-- <xsl:apply-templates -->
				<!-- 	select="document(concat('file:///', $wadl.path))//wadl:resource[@id = substring-after(current()/@href,'#')]/wadl:method" -->
				<!-- 	mode="method-rows"/>   --> <!--[@rax:id = $href]-->

			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="wadl:method" mode="method-rows"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="wadl:method[@href]" mode="method-rows">
	  <xsl:param name="wadl.path"/>
	  <xsl:param name="resourceId"/>
	  
	  <xsl:apply-templates
	      select="document(concat('file:///', $wadl.path))//wadl:resource[@id = $resourceId]/wadl:method[@rax:id = current()/@href]"
	      mode="method-rows"/>  
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
					select="document(concat('file:///', $wadl.path))//wadl:resource[@id = substring-after(current()/@href,'#')]/wadl:method[@rax:id = current()/wadl:method/@href]"
					mode="preprocess">
					<xsl:with-param name="sectionId" select="ancestor::d:section/@xml:id"/>
                    <xsl:with-param name="resourceLink" select="."/>
				</xsl:apply-templates>
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
		<xsl:param name="sectionId"/>
        <xsl:param name="resourceLink"/>
        <xsl:variable name="id" select="@rax:id"/>
        <!-- Handle skipText PIs -->
        <xsl:variable name="skipNoRequestTextN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
                    <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="$resourceLink/wadl:method[contains(@href,$id)]/ancestor-or-self::*/processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'skipNoRequestText'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="skipNoRequestText" select="boolean(number($skipNoRequestTextN))"/>
        <xsl:variable name="skipNoResponseTextN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
                    <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="$resourceLink/wadl:method[contains(@href,$id)]/ancestor-or-self::*/processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'skipNoResponeText'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="skipNoResponseText" select="boolean(number($skipNoResponseTextN))"/>
        <xsl:variable name="addMethodPageBreaksN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
                    <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="$resourceLink/wadl:method[contains(@href,$id)]/ancestor-or-self::*/processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'addMethodPageBreaks'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="addMethodPageBreaks" select="boolean(number($addMethodPageBreaksN))"/>
		<xsl:variable name="replacechars">/{}</xsl:variable>
		<xsl:variable name="method.title">
				<xsl:choose>
					<xsl:when test="wadl:doc/@title">
						<xsl:value-of select="wadl:doc/@title"/>
					</xsl:when>
					<xsl:when test="@id or @rax:id">
						<xsl:message>Warning: No title found for wadl:method</xsl:message>
						<xsl:value-of select="@id|@rax:id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>Warning: No title found for wadl:method</xsl:message>
						<xsl:value-of select="@name"/>
					</xsl:otherwise>
				</xsl:choose>
		</xsl:variable>
        <xsl:if test="$addMethodPageBreaks">
            <xsl:processing-instruction name="hard-pagebreak"/>
        </xsl:if>
		<section xml:id="{concat(@name,'_',@rax:id,'_',translate(parent::wadl:resource/@path, $replacechars, '___'),'_',$sectionId)}">
			<title><xsl:value-of select="$method.title"/></title>
			<informaltable rules="all">
				<col width="10%"/>
				<col width="40%"/>
				<col width="50%"/>
				<thead>
					<tr>
						<th align="center">Verb</th>
						<th align="center">URI</th>
						<th align="center">Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:call-template name="method-row"/>
				</tbody>
			</informaltable>

			<xsl:if test="wadl:response[starts-with(normalize-space(@status),'2')]">
                <simpara>
                    Normal Response Code(s):
					<xsl:apply-templates select="wadl:response" mode="preprocess-normal"/>
                </simpara>
			</xsl:if>
			<xsl:if test="wadl:response[not(starts-with(normalize-space(@status),'2'))]">
                <simpara>
                    Error Response Code(s):
                    <!--
                        Put those errors that don't have a set status
                        up front.  These are typically general errors.
                    -->
					<xsl:apply-templates select="wadl:response[not(@status)]" mode="preprocess-faults"/>
					<xsl:apply-templates select="wadl:response[@status]" mode="preprocess-faults"/>
                </simpara>
			</xsl:if>

            <!-- Method Docs -->
			<xsl:choose>
			  <xsl:when test="wadl:doc//xhtml:*[@class = 'shortdesc'] or wadl:doc//d:*[@role = 'shortdesc']">
			    <xsl:apply-templates select="wadl:doc" mode="process-xhtml"/>
			  </xsl:when>
			  <xsl:otherwise>
			    <!-- Suppress because everything will be in the table -->
			  </xsl:otherwise>
			</xsl:choose>

            <xsl:copy-of select="wadl:doc/db:*"   xmlns:db="http://docbook.org/ns/docbook" />

            <!-- About the request -->

			<xsl:if test="wadl:request/wadl:param|ancestor::wadl:resource/wadl:param">
                <xsl:call-template name="paramTable">
                    <xsl:with-param name="mode" select="'Request'"/>
                    <xsl:with-param name="method.title" select="$method.title"/>
                </xsl:call-template>
            </xsl:if>

			<xsl:copy-of select="wadl:request/wadl:representation/wadl:doc/db:*"   xmlns:db="http://docbook.org/ns/docbook" />
            <!-- we allow no request text and there is no request ... -->
            <xsl:if test="not($skipNoRequestText) and not(wadl:request)">
                <!-- ...and we have a valid response OR we are skipping response text -->
                <xsl:if test="wadl:response[starts-with(normalize-space(@status),'2')]/wadl:representation or $skipNoResponseText">
                    <xsl:copy-of select="$wadl.norequest.msg"/>
                </xsl:if>
            </xsl:if>

            <!-- About the response -->

			<xsl:if test="wadl:response/wadl:param">
                <xsl:call-template name="paramTable">
                    <xsl:with-param name="mode" select="'Response'"/>
                    <xsl:with-param name="method.title" select="$method.title"/>
                </xsl:call-template>
            </xsl:if>
			<xsl:copy-of select="wadl:response/wadl:representation/wadl:doc/db:*"   xmlns:db="http://docbook.org/ns/docbook" />
            <!-- we allow no response text and we dont have a 200 level response with a representation -->
            <xsl:if test="not($skipNoResponseText) and not(wadl:response[starts-with(normalize-space(@status),'2')]/wadl:representation)">
                <!-- if we are also missing request text and it's not
                     supressed then output the noreqresp message,
                     otherwise output the noresponse message -->
                <xsl:choose>
                    <xsl:when test="not($skipNoRequestText) and not(wadl:request)">
                        <xsl:copy-of select="$wadl.noreqresp.msg"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$wadl.noresponse.msg"/>
                    </xsl:otherwise>
                </xsl:choose>
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
					<xsl:choose>
						<xsl:when test="$trim.wadl.uri.count &gt; 0">
							<xsl:call-template name="trimUri">
								<xsl:with-param name="trimCount" select="$trim.wadl.uri.count"/>
								<xsl:with-param name="uri">
									<xsl:value-of select="parent::wadl:resource/@path"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="parent::wadl:resource/@path"/>
						</xsl:otherwise>
					</xsl:choose>
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
					<xsl:when test="wadl:doc//*[@class = 'shortdesc' or @role='shortdesc']">
						<xsl:apply-templates select="wadl:doc//*[@class = 'shortdesc' or @role = 'shortdesc'][1]" mode="process-shortdesc"/>
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

	<xsl:template match="xhtml:p[@class = 'shortdesc']|d:para[@role = 'shortdesc']|d:example[@role='wadl']" mode="process-xhtml"/>

	<xsl:template match="xhtml:p[not(@class = 'shortdesc')]"  mode="process-xhtml">
	  <para>
	    <xsl:apply-templates mode="process-xhtml"/>
	  </para>
	</xsl:template>

	<xsl:template match="d:*[not(@role = 'wadl') and not(@role = 'shortdesc')]|@*"  mode="process-xhtml">
		<xsl:copy>
		  <xsl:apply-templates select="@*|d:*|text()|comment()|processing-instruction()" mode="process-xhtml"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="xhtml:b|xhtml:strong"  mode="process-xhtml">
		<emphasis role="bold"><xsl:apply-templates  mode="process-xhtml"/></emphasis>
	</xsl:template>
	
	<xsl:template match="xhtml:a[@href]" mode="process-xhtml">
		<link xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{@href}"><xsl:apply-templates mode="process-xhtml"/></link>
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
	
	<!-- <xsl:template match="db:*" mode="process-xhtml" xmlns:db="http://docbook.org/ns/docbook"/> -->
	
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

	<xsl:template match="wadl:param" mode="preprocess">
		<xsl:variable name="type"><xsl:value-of select="substring-after(@type,':')"/></xsl:variable>
		<!-- TODO: Get more info from the xsd about these params-->
		<tr>
			<td>
				<code><xsl:value-of select="@name"/></code>
			</td>
			<td>
				<xsl:value-of select="@style"/>
			</td>
			<td>
				<xsl:apply-templates select="wadl:doc" mode="process-xhtml"/>
				<para>
					<xsl:value-of
						select="concat(translate(substring($type,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($type,2))"
					/>. <xsl:if test="wadl:option"> Possible values: <xsl:for-each
							select="wadl:option">
							<xsl:value-of select="@value"/><xsl:choose>
								<xsl:when test="position() = last()">. </xsl:when>
								<xsl:otherwise>, </xsl:otherwise>
							</xsl:choose>
						</xsl:for-each> Default: <xsl:value-of select="@default"
						/><xsl:text>. </xsl:text>
					</xsl:if>
                    <!--
                        Template parameters are always required, so
                        there's no poin in processing @required.
                    -->
                    <xsl:if test="@style != 'template'">
                        <xsl:choose>
                            <xsl:when test="@required = 'true'">Required. </xsl:when>
                            <xsl:otherwise>Optional. </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
				</para>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="wadl:response" mode="preprocess-normal">
        <xsl:variable name="normStatus" select="normalize-space(@status)"/>
		<xsl:if test="starts-with($normStatus,'2')">
            <xsl:call-template name="statusCodeList">
                <xsl:with-param name="codes" select="$normStatus"/>
            </xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="wadl:response" mode="preprocess-faults">
		<xsl:if
			test="(not(@status) or not(starts-with(normalize-space(@status),'2'))) and wadl:representation/@element">
            <xsl:variable name="codes">
                <xsl:choose>
                    <xsl:when test="@status">
                        <xsl:value-of select="normalize-space(@status)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'400 500 &#x2026;'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="substring-after(wadl:representation/@element,':')"/>
            <xsl:text> (</xsl:text>
            <xsl:call-template name="statusCodeList">
                <xsl:with-param name="codes" select="$codes"/>
                <xsl:with-param name="inError" select="true()"/>
            </xsl:call-template>
            <xsl:text>)</xsl:text>
            <xsl:choose>
                <xsl:when test="following-sibling::wadl:response">
                    <xsl:text>,&#x0a;            </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>&#x0a;   </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
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
			<xsl:when test="$compute.wadl.path.from.docbook.path = '0' and contains($path,'\')">
				<xsl:call-template name="wadlPath">
					<xsl:with-param name="path" select="substring-after($path,'\')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$compute.wadl.path.from.docbook.path = '0' and contains($path,'/')">
				<xsl:call-template name="wadlPath">
					<xsl:with-param name="path" select="substring-after($path,'/')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$compute.wadl.path.from.docbook.path = '0'">
				<xsl:value-of
				    select="concat($project.build.directory, '/generated-resources/xml/xslt/',$path)"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of
				    select="concat($project.build.directory, '/generated-resources/xml/xslt',$docbook.partial.path,$path)"
				/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="trimUri">
		<!-- Trims elements -->
		<xsl:param name="trimCount"/>
		<xsl:param name="uri"/>
		<xsl:param name="i">0</xsl:param>
		<xsl:choose>
			<xsl:when test="$i &lt; $trimCount and contains($uri,'/')">
				<xsl:call-template name="trimUri">
					<xsl:with-param name="i" select="$i + 1"/>
					<xsl:with-param name="trimCount">
						<xsl:value-of select="$trimCount"/>
					</xsl:with-param> 
					<xsl:with-param name="uri">
						<xsl:value-of select="substring-after($uri,'/')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('/',$uri)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    <xsl:template name="paramTable">
        <xsl:param name="mode"/>
    	<xsl:param name="method.title"/>
        <xsl:if test="$mode='Request' or $mode='Response'">
            <table rules="all">
                <caption><xsl:value-of select="concat($method.title,' ',$mode,' Parameters')"/></caption>
                <col width="25%"/>
                <col width="15%"/>
                <col width="60%"/>
                <thead>
                    <tr>
                        <th align="center">Name</th>
                        <th align="center">Style</th>
                        <th align="center">Description</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:choose>
                        <xsl:when test="$mode = 'Request'">
                            <xsl:apply-templates
                            select="wadl:request//wadl:param|ancestor::wadl:resource/wadl:param"
                            mode="preprocess">
                                <xsl:sort select="@style"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="$mode = 'Response'">
                            <xsl:apply-templates
                                select="wadl:response//wadl:param"
                                mode="preprocess"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr>
                                <td>WTF? <xsl:value-of select="$mode"/></td>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </tbody>
            </table>
        </xsl:if>
    </xsl:template>
    <xsl:template name="statusCodeList">
        <xsl:param name="codes" select="'400 500 &#x2026;'"/>
        <xsl:param name="separator" select="','"/>
        <xsl:param name="inError" select="false()"/>
        <xsl:variable name="code" select="substring-before($codes,' ')"/>
        <xsl:variable name="nextCodes" select="substring-after($codes,' ')"/>
        <xsl:choose>
            <xsl:when test="$code != ''">
                <xsl:call-template name="statusCode">
                    <xsl:with-param name="code" select="$code"/>
                    <xsl:with-param name="inError" select="$inError"/>
                </xsl:call-template>
                <xsl:text>, </xsl:text>
                <xsl:call-template name="statusCodeList">
                    <xsl:with-param name="codes" select="$nextCodes"/>
                    <xsl:with-param name="separator" select="$separator"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="statusCode">
                    <xsl:with-param name="code" select="$codes"/>
                    <xsl:with-param name="inError" select="$inError"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="statusCode">
        <xsl:param name="code" select="'200'"/>
        <xsl:param name="inError" select="false()"/>
        <xsl:choose>
            <xsl:when test="$inError">
                <errorcode>
                    <xsl:value-of select='$code'/>
                </errorcode>
            </xsl:when>
            <xsl:otherwise>
                <returnvalue>
                    <xsl:value-of select='$code'/>
                </returnvalue>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        Converts boolValue string 'false' and 'no' to 0
        Empty strings '' get default (which can be 0 or 1)
        All other strings are 1

       You can convert this to an xpath boolean value by saying:
       boolean(number($val)).

       Not sure if there's an easier way of doing this in XSL 1.0.
    -->
    <xsl:template name="makeBoolean">
        <xsl:param name="boolValue" select="'no'"/>
        <xsl:param name="default" select="0"/>
        <xsl:choose>
            <xsl:when test="string-length($boolValue) = 0">
                <xsl:value-of select="$default"/>
            </xsl:when>
            <xsl:when test="$boolValue = 'false' or $boolValue = 'no'"><xsl:value-of select="0"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="1"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	<!-- DWC: This template comes from the DocBook xsls (MIT-style license) -->
	<xsl:template name="pi-attribute">
		<xsl:param name="pis" select="processing-instruction('BOGUS_PI')"></xsl:param>
		<xsl:param name="attribute">filename</xsl:param>
		<xsl:param name="count">1</xsl:param>
		
		<xsl:choose>
			<xsl:when test="$count>count($pis)">
				<!-- not found -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="pi">
					<xsl:value-of select="$pis[$count]"></xsl:value-of>
				</xsl:variable>
				<xsl:variable name="pivalue">
					<xsl:value-of select="concat(' ', normalize-space($pi))"></xsl:value-of>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains($pivalue,concat(' ', $attribute, '='))">
						<xsl:variable name="rest" select="substring-after($pivalue,concat(' ', $attribute,'='))"></xsl:variable>
						<xsl:variable name="quote" select="substring($rest,1,1)"></xsl:variable>
						<xsl:value-of select="substring-before(substring($rest,2),$quote)"></xsl:value-of>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="pi-attribute">
							<xsl:with-param name="pis" select="$pis"></xsl:with-param>
							<xsl:with-param name="attribute" select="$attribute"></xsl:with-param>
							<xsl:with-param name="count" select="$count + 1"></xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
