<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://docbook.org/ns/docbook" 
	xmlns:wadl="http://wadl.dev.java.net/2009/02"       
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:d="http://docbook.org/ns/docbook" 
	xmlns:rax="http://docs.rackspace.com/api" 
	xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0"
	exclude-result-prefixes="wadl rax d xhtml xsdxt" 
	version="2.0">
	
	<!--<xsl:output indent="yes"/>-->
	
	<xsl:param name="wadl.norequest.msg"><para>This operation does not accept a request body.</para></xsl:param>
	<xsl:param name="wadl.noresponse.msg"><para>This operation does not return a response body.</para></xsl:param>
	<xsl:param name="wadl.noreqresp.msg"><para>This operation does not accept a request body and does not return a response body.</para></xsl:param>
	<xsl:param name="security">external</xsl:param>
	<xsl:param name="trim.wadl.uri.count">0</xsl:param>
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="d:*[@role = 'api-reference']" >

		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*"/>
			
			<xsl:apply-templates select="d:*[not(self::d:section)]|processing-instruction()" />
			<!-- 
			 Here we build a summary template for whole reference. 
  			 Combine the tables for a section into one big table
			-->
			<informaltable rules="all" width="100%">			
				<col width="10%"/>
				<col width="40%"/>
				<col width="50%"/>
				<thead>
					<tr>
						<th align="center">Method</th>
						<th align="center">URI</th>
						<th align="center">Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="wadl:resources" mode="cheat-sheet"/>
					<xsl:apply-templates select="d:section" mode="cheat-sheet"/>					
				</tbody>
			</informaltable>

			<xsl:apply-templates select="d:section"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="wadl:resources" mode="cheat-sheet">
		<xsl:apply-templates select="wadl:resource" mode="method-rows"/>
	</xsl:template>
	
	<xsl:template match="d:section" mode="cheat-sheet">
		<tr>
			<th colspan="3" align="center">
				<xsl:value-of select="d:title|d:info/d:title"/>
			</th>
		</tr>
		<xsl:apply-templates select="wadl:resources" mode="cheat-sheet"/>
	</xsl:template>
	
	<xsl:template match="wadl:resource" mode="method-rows">
		<xsl:apply-templates select="wadl:method" mode="method-rows"/>
	</xsl:template>
	
	<xsl:template match="wadl:method" name="method-row" mode="method-rows">
		<!-- calculate section id -->
		<xsl:param name="mode">href</xsl:param>
		<xsl:variable name="sectionId" select="ancestor::d:section[1]/@xml:id"/>
		<xsl:variable name="replacechars">/{}:</xsl:variable>
		<xsl:variable name="raxid" select="if (@rax:id) then @rax:id else @id"/>
		<xsl:variable name="app_raxid" select="if(ancestor::wadl:resources/@xml:id) then concat(ancestor::wadl:resources/@xml:id, '_') else ''"/>
		<xsl:variable name="sectionIdComputed"
			select="concat(@name,'_',$app_raxid,$raxid,'_',translate(parent::wadl:resource/@path, $replacechars, '___'),'_',$sectionId)"/>
		
		<xsl:variable name="default.param.type">string</xsl:variable>
		<tr>
			<td>
				<command>
					<xsl:value-of select="@name"/>
				</command>
			</td>
			<td>
				<!-- 
						TODO: Deal with non-flattened path in embedded wadl? 
			    -->
				<xsl:variable name="path">
					<xsl:choose>
						<xsl:when test="xs:integer($trim.wadl.uri.count) &gt; 0">
							<xsl:call-template name="trimUri">
								<xsl:with-param name="trimCount" select="$trim.wadl.uri.count"/>
								<xsl:with-param name="uri" select="parent::wadl:resource/@path"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="if(not(starts-with(parent::wadl:resource/@path,'/'))) then concat('/', parent::wadl:resource/@path) else parent::wadl:resource/@path"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<code>
					<xsl:if test="$mode = 'href'">
						<xsl:attribute name="xlink:href"
							select="concat('#',$sectionIdComputed)"/>
					</xsl:if>
					<xsl:value-of select="$path"/>
					<xsl:for-each
						select="wadl:request//wadl:param[@style = 'query']|parent::wadl:resource/wadl:param[@style = 'query']">
						<xsl:text>&#x200b;</xsl:text>
						<xsl:if test="position() = 1">{?</xsl:if>
						<xsl:value-of select="@name"/>
						<xsl:if test="@repeating = 'true'">*</xsl:if>
						<xsl:choose>
							<xsl:when test="not(position() = last())"
								>,</xsl:when>
							<xsl:otherwise>}</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</code>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="wadl:doc//*[@role='shortdesc']">
						<para><xsl:apply-templates select="(wadl:doc//*[@role = 'shortdesc'])[1]" mode="process-shortdesc"/></para>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="wadl:doc" mode="process-no-shortdesc"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="process-shortdesc">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="wadl:doc" mode="process-no-shortdesc">
		<xsl:apply-templates select="*[1]"/>
	</xsl:template>
	
	<xsl:template match="xsdxt:samples">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="xsdxt:sample">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="xsdxt:code">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- ======================================================= -->
	
	
	<xsl:template match="wadl:resources" name="wadl-resources" >
		<xsl:param name="original.wadl.path" />

        <!-- Handle skipSummary PI -->
		<xsl:variable name="skipSummaryN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
				<xsl:if test="processing-instruction('rax-wadl')">
                    <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'skipSummary'"/>
                    </xsl:call-template>
					</xsl:if>
                	<xsl:if test="parent::*[@role = 'api-reference']">true</xsl:if>
                </xsl:with-param>
            	<xsl:with-param name="default" select="'0'"/>
            </xsl:call-template>
		</xsl:variable>
        <xsl:variable name="skipSummary" select="boolean(number($skipSummaryN))"/>
		<!-- Make a summary table then apply templates to wadl:resource/wadl:method (from wadl) -->
		<xsl:if test="not($skipSummary)">
			<informaltable rules="all" width="100%">			
				<col width="10%"/>
				<col width="40%"/>
				<col width="50%"/>
				<thead>
					<tr>
						<th align="center">Method</th>
						<th align="center">URI</th>
						<th align="center">Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="wadl:resource" mode="method-rows"/>				
				</tbody>
			</informaltable>
		</xsl:if>

		<xsl:apply-templates select=".//wadl:resource" />		
	</xsl:template>

	<xsl:template match="wadl:resource">     
		<xsl:apply-templates select="wadl:method"/>
	</xsl:template>
	
	<xsl:template match="wadl:method">
		<!-- calculate section id -->
		<xsl:variable name="sectionId" select="ancestor::d:section[1]/@xml:id"/>
		<xsl:variable name="replacechars">/{}:</xsl:variable>
		<xsl:variable name="raxid" select="if (@rax:id) then @rax:id else @id"/>
		<xsl:variable name="app_raxid" select="if(ancestor::wadl:resources/@xml:id) then concat(ancestor::wadl:resources/@xml:id, '_') else ''"/>
		<xsl:variable name="sectionIdComputed"
			select="concat(@name,'_',$app_raxid,$raxid,'_',translate(parent::wadl:resource/@path, $replacechars, '___'),'_',$sectionId)"/>
		
        <!-- Handle skipText PIs -->
        <xsl:variable name="skipNoRequestTextN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
				<xsl:if test="ancestor-or-self::*/processing-instruction('rax-wadl')|processing-instruction('rax-wadl')">
                    <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="ancestor-or-self::*/processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'skipNoRequestText'"/>
                    </xsl:call-template>
					</xsl:if>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="skipNoRequestText" select="boolean(number($skipNoRequestTextN))"/>
        <xsl:variable name="skipNoResponseTextN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
                  <xsl:if test="ancestor-or-self::*/processing-instruction('rax-wadl')">
                    <xsl:call-template name="pi-attribute">
                    	<xsl:with-param name="pis" select="ancestor-or-self::*/processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'skipNoResponseText'"/>
                    </xsl:call-template>
                   </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="skipNoResponseText" select="boolean(number($skipNoResponseTextN))"/>
        <xsl:variable name="addMethodPageBreaksN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
                	<xsl:if test="ancestor-or-self::*/processing-instruction('rax-wadl')">
                    <xsl:call-template name="pi-attribute">
                    	<xsl:with-param name="pis" select="ancestor-or-self::*/processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'addMethodPageBreaks'"/>
                    </xsl:call-template>
                </xsl:if>
                </xsl:with-param>
            	<xsl:with-param name="default" select="'1'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="addMethodPageBreaks" select="boolean(number($addMethodPageBreaksN))"/>
		<xsl:variable name="method.title">
				<xsl:choose>
					<xsl:when test="wadl:doc/@title">
						<xsl:value-of select="(wadl:doc/@title)[1]"/>
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
		<section xml:id="{$sectionIdComputed}">
			<xsl:processing-instruction name="dbhtml">stop-chunking</xsl:processing-instruction>
			<title><xsl:value-of select="$method.title"/></title>
			<xsl:if test="$sectionIdComputed != concat(@name,'_',$app_raxid,$raxid,'_',translate(parent::wadl:resource/@path, $replacechars, '___'),'_')">
				<anchor xml:id="{concat(@name,'_',$app_raxid,$raxid,'_',translate(parent::wadl:resource/@path, $replacechars, '___'),'_')}" xreflabel="{$method.title}"/>
			</xsl:if>
			<xsl:if test="$security = 'writeronly'">
				<para security="writeronly">Source wadl: <link xlink:href="{@rax:original-wadl}"><xsl:value-of select="@rax:original-wadl"/></link>  (method id: <xsl:value-of select="@rax:id"/>)</para>
			</xsl:if>
			
			<informaltable rules="all" width="100%">		
				<col width="10%"/>
				<col width="40%"/>
				<col width="50%"/>
				<thead>
					<tr>
						<th align="center">Method</th>
						<th align="center">URI</th>
						<th align="center">Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:call-template name="method-row">
						<xsl:with-param name="mode" select="'none'"/>
					</xsl:call-template>				
				</tbody>
			</informaltable>
			
			<!-- Method Docs -->
			<xsl:choose>
				<xsl:when test="wadl:doc//db:*[@role = 'shortdesc']" xmlns:db="http://docbook.org/ns/docbook">
					<xsl:apply-templates select="wadl:doc/*[not(@role='shortdesc')]"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- Suppress because everything will be in the table -->
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="wadl:response[not(starts-with(normalize-space(@status),'2') or starts-with(normalize-space(@status),'3'))]/wadl:doc">
					<para>
					This table shows the possible
					response codes for this operation:</para>
					<informaltable rules="all" width="100%">
						<!--	<caption>Response Codes</caption>-->
							<col width="10%" />
							<col width="30%" />
							<col width="60%" />
							<thead>
								<tr>
									<th align="center">Response Code</th>
									<th align="center">Name</th>
									<th align="center">Description</th>
								</tr>
							</thead>
							<tbody>
								<xsl:apply-templates select="wadl:response[@status and (starts-with(@status,'2') or starts-with(@status,'3'))]" mode="responseTable">
									<xsl:sort select="@status"/>
								</xsl:apply-templates>
								<xsl:apply-templates select="wadl:response[@status and not(starts-with(@status,'2') or starts-with(@status,'3'))]" mode="responseTable">
									<xsl:sort select="@status"/>
								</xsl:apply-templates>
								<xsl:apply-templates select="wadl:response[not(@status)]" mode="responseTable"/>
								
							</tbody>
						</informaltable>

				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="wadl:response[starts-with(normalize-space(@status),'2') or starts-with(normalize-space(@status),'3')]">
						<simpara>
							<emphasis role="bold">Normal response codes: </emphasis>
							<xsl:apply-templates select="wadl:response" mode="preprocess-normal"/>
						</simpara>
					</xsl:if>
					<xsl:if test="wadl:response[not(starts-with(normalize-space(@status),'2') or starts-with(normalize-space(@status),'3'))]">
						<simpara>
							<emphasis role="bold">Error response codes: </emphasis>
							<!--
								Put those errors that don't have a set status
								up front.  These are typically general errors.
							-->
							<xsl:apply-templates select="wadl:response[not(@status)]" mode="preprocess-faults"/>
							<xsl:apply-templates select="wadl:response[@status]" mode="preprocess-faults"/>
						</simpara>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			
        <!--    <xsl:copy-of select="wadl:doc/db:*[not(@role='shortdesc')] | wadl:doc/processing-instruction()"   xmlns:db="http://docbook.org/ns/docbook" />-->
			<xsl:variable name="requestSection">
			<section xml:id="{$sectionIdComputed}-Request">
				<title>Request</title>
            <!-- About the request -->
			<xsl:if test="wadl:request//wadl:param[@style = 'header'] or parent::wadl:resource/wadl:param[@style = 'header']">
				<xsl:call-template name="paramTable">
					<xsl:with-param name="mode" select="'request'"/>
					<xsl:with-param name="method.title" select="$method.title"/>
					<xsl:with-param name="style" select="'header'"/>
				</xsl:call-template>
			</xsl:if>
			
			<xsl:if test="ancestor::wadl:resource/wadl:param[@style = 'template']">
				<xsl:call-template name="paramTable">
					<xsl:with-param name="mode" select="'request'"/>
					<xsl:with-param name="method.title" select="$method.title"/>
					<xsl:with-param name="style" select="'template'"/>
				</xsl:call-template>
			</xsl:if>
			
	        <xsl:if test="wadl:request//wadl:param[@style = 'query']">
                <xsl:call-template name="paramTable">
                    <xsl:with-param name="mode" select="'request'"/>
                    <xsl:with-param name="method.title" select="$method.title"/>
                	<xsl:with-param name="style" select="'query'"/>
                </xsl:call-template>
            </xsl:if>

			<!-- TODO: Refactor to generate one example for each representation.-->
			<xsl:apply-templates select=".//wadl:representation[parent::wadl:request]">
				<xsl:with-param name="method.title" select="$method.title"/>
			</xsl:apply-templates>

				<!-- Here we try to figure out is we should add a "No request body required" message -->
				<!-- 1. We rule out that there's a PI telling us to skip the message. -->
				<!-- 2. If we find a request with a media type of application/xml that doesn't have an element attr or -->
				<!-- 3. If we find a request with a media type of application/json that doesn't contains a { -->
				<!-- The contortions are needed because the writers sometimes put in code samples with just headers. -->
				<xsl:if test="not($skipNoRequestText) and (not(wadl:request) or wadl:request[wadl:representation[ends-with(@mediaType, 'xml') and not(@element)]] or wadl:request[wadl:representation[@mediaType = 'application/json' and not((for $code in .//xsdxt:code return if(contains($code,'{') or contains($code,'[')) then 1 else 0) = 1)]])">
                    <xsl:copy-of select="$wadl.norequest.msg"/>
                </xsl:if>
			</section>
			</xsl:variable>
			<xsl:variable name="responseSection">
			<section xml:id="{$sectionIdComputed}-Response">
				<title>Response</title>
            <!-- About the response -->

			<xsl:if test="wadl:response/wadl:param[@style = 'header']">
                <xsl:call-template name="paramTable">
                	<xsl:with-param name="mode" select="'response'"/>
                    <xsl:with-param name="method.title" select="$method.title"/>
                	<xsl:with-param name="style" select="'header'"/>
                </xsl:call-template>
            </xsl:if>

			<!-- TODO: Refactor to generate one example for each representation.-->
				<xsl:apply-templates select=".//wadl:representation[parent::wadl:response[starts-with(normalize-space(@status),'2')]]">
				<xsl:with-param name="method.title" select="$method.title"/>
			</xsl:apply-templates> 

				<!-- Here we try to figure out is we should add a "No response body required" message -->
				<!-- 1. We rule out that there's a PI telling us to skip the message. -->
				<!-- 2. If we find a 2xx response with a media type of application/xml that doesn't have an element attr or -->
				<!-- 3. If we find a 2xx response with a media type of application/json that doesn't contains a { -->
				<!-- The contortions are needed because the writers sometimes put in code samples with just headers. -->
				<xsl:if test="not($skipNoResponseText) and (wadl:response[starts-with(normalize-space(@status),'2') and ./wadl:representation[ends-with(@mediaType, 'application/xml') and not(@element)]] or wadl:response[starts-with(normalize-space(@status),'2') and wadl:representation[@mediaType = 'application/json' and not((for $code in .//xsdxt:code return if(contains($code,'{') or contains($code,'[')) then 1 else 0) = 1)]])">
					<xsl:copy-of select="$wadl.noresponse.msg"/>
				</xsl:if>
			</section>
			</xsl:variable>
			<xsl:if test="$requestSection//d:section/*[not(self::d:title)]">
				<xsl:copy-of select="$requestSection"/>
			</xsl:if>
			<xsl:if test="$responseSection//d:section/*[not(self::d:title)]">
				<xsl:copy-of select="$responseSection"/>
			</xsl:if>	
		</section>
	</xsl:template>
	
	<xsl:template match="wadl:response" mode="responseTable">
		<tr>
			<td align="left"><xsl:value-of select="if(@status) then @status else '400 500 &#x2026;'"/></td>
			<td align="left"><xsl:value-of select="wadl:doc/@title"></xsl:value-of></td>
			<td><xsl:apply-templates select="wadl:doc/node()"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="wadl:representation">
		<xsl:param name="method.title"/>
		<xsl:variable name="plainParams">
			<xsl:choose>
				<xsl:when test="wadl:param[@style = 'plain'] and contains(@mediaType,'json')">
					<xsl:call-template name="paramList">
						<xsl:with-param name="mode" select="if(ancestor::wadl:response) then 'response' else 'request'"/>
						<xsl:with-param name="method.title" select="$method.title"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="wadl:param[@style = 'plain']">
					<xsl:call-template name="paramTable">
						<xsl:with-param name="mode" select="if(ancestor::wadl:response) then 'response' else 'request'"/>
						<xsl:with-param name="method.title" select="$method.title"/>
						<xsl:with-param name="style" select="'plain'"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:apply-templates select="wadl:doc" mode="representation">
			<xsl:with-param name="plainParams" select="$plainParams"/>
		</xsl:apply-templates>

	</xsl:template>

 	<xsl:template match="wadl:doc" mode="representation">
 		<xsl:param name="plainParams"/>
 		<!--
            In order to create a DocBook example from a sample of code there are,
            three variables we must determine: the media type of the example,
            a human readable title, and the content of the example itself.
            
            We try to determine as much as we can from context.
        -->
 		<xsl:variable
 			name="type"
 			as="xs:string"
 			select="if (.//xsdxt:code/@type) 
 			then .//xsdxt:code[1]/@type (: Legacy stuff? :)
 			else if (ancestor::wadl:representation/@mediaType)
 			then ancestor::wadl:representation/@mediaType
 			else 'application/xml'"/> <!-- xml is the default -->
 		<xsl:variable
 			name="title"
 			as="xs:string"
 			select="if (.//xsdxt:code/@title) then .//xsdxt:code[1]/@title
 			else if (.//xsdxt:sample/@title) then .//xsdxt:sample[1]/@title
 			else if (@title) then @title
 			else ''"/> <!-- a default title will be computed below in this case -->
 		<xsl:variable name="title-calculated">
 			<xsl:choose>
 				<xsl:when test="string-length($title) != 0"><xsl:value-of select="$title"/></xsl:when>
 				<xsl:otherwise>
 					<xsl:if test="ancestor::wadl:method/wadl:doc/@title">
 						<xsl:value-of select="ancestor::wadl:method/wadl:doc/@title"/>
 					</xsl:if>
 					<xsl:choose>
 						<xsl:when test="$type = 'application/xml'">: XML </xsl:when>
 						<xsl:when test="$type = 'application/json'">: JSON </xsl:when>
 						<xsl:when test="$type = 'application/atom+xml'">: ATOM </xsl:when>
 						<xsl:otherwise>: <xsl:value-of select="$type"/></xsl:otherwise>
 					</xsl:choose>
 					<xsl:choose>
 						<xsl:when test="ancestor::wadl:response">
 							<xsl:value-of select="'response'"/>
 						</xsl:when>
 						<xsl:when test="ancestor::wadl:request">
 							<xsl:value-of select="'request'"/>
 						</xsl:when>
 					</xsl:choose>
 				</xsl:otherwise>
 			</xsl:choose>
 		</xsl:variable>
 		
 		<xsl:copy-of select="$plainParams"/>
 		<xsl:choose>
 			<xsl:when test=".//xsdxt:samples">
 				<xsl:apply-templates select=".//xsdxt:samples/xsdxt:sample" mode="sample"/>
 			</xsl:when>
 			<xsl:when test=".//xsdxt:sample">
 				<xsl:apply-templates mode="sample"/>
 			</xsl:when>
 			<xsl:when test=".//xsdxt:code">
 				<example>
 					<title><xsl:value-of select="$title-calculated"/></title>
 					<xsl:apply-templates mode="sample"/>
 				</example>
 			</xsl:when>
 			<xsl:otherwise>
 				<xsl:apply-templates mode="sample"/>
 			</xsl:otherwise>
 		</xsl:choose>
 	</xsl:template>
	
	<xsl:template match="xsdxt:sample" mode="sample">
		<!--
            In order to create a DocBook example from a sample of code there are,
            three variables we must determine: the media type of the example,
            a human readable title, and the content of the example itself.
            
            We try to determine as much as we can from context.
        -->
		<xsl:variable
			name="type"
			as="xs:string"
			select="if (ancestor::wadl:representation/@mediaType)
			then ancestor::wadl:representation/@mediaType
			else 'application/xml'"/> <!-- xml is the default -->
		<xsl:variable
			name="title"
			as="xs:string"
			select="if (@title) then @title
			else if (.//xsdxt:code/@title) then .//xsdxt:code[1]/@title
			else ''"/> <!-- a default title will be computed below in this case -->
		<xsl:variable name="title-calculated">
			<xsl:choose>
				<xsl:when test="string-length($title) != 0"><xsl:value-of select="$title"/></xsl:when>
				<xsl:otherwise>
					<xsl:if test="ancestor::wadl:method/wadl:doc/@title">
						<xsl:value-of select="ancestor::wadl:method/wadl:doc/@title"/>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="$type = 'application/xml'">: XML </xsl:when>
						<xsl:when test="$type = 'application/json'">: JSON </xsl:when>
						<xsl:when test="$type = 'application/atom+xml'">: ATOM </xsl:when>
						<xsl:otherwise>: <xsl:value-of select="$type"/></xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="ancestor::wadl:response">
							<xsl:value-of select="'response'"/>
						</xsl:when>
						<xsl:when test="ancestor::wadl:request">
							<xsl:value-of select="'request'"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<example>
			<title><xsl:value-of select="$title-calculated"/></title>
			<xsl:apply-templates mode="sample"/>
		</example>
	</xsl:template>
	
	<xsl:template match="xsdxt:code" mode="sample">
		<!-- Remove this element. The code was already pulled in by the wadl normalizer -->
		<xsl:apply-templates mode="sample"/>
	</xsl:template>
	
	<xsl:template match="node() | @*" mode="sample">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" mode="sample"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="wadl:param">
		<xsl:param name="style"/>
		<xsl:variable name="default.param.type" select="if (@style != 'plain') then 'String' else ''"/>
	  <xsl:variable name="type">
	  	<xsl:value-of select="if (@type and contains(@type, ':')) then substring-after(@type,':') else if(@type) then @type else $default.param.type"/>
	  </xsl:variable>
        <xsl:variable name="param">
            <xsl:choose>
                <xsl:when test="@style='header'"> header </xsl:when>
                <xsl:otherwise> parameter </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

		<!-- TODO: Get more info from the xsd about these params-->
		<xsl:variable name="jsonPathDepth" select="(string-length(@path) - string-length(translate(@path,'.',''))) - 1"/>
		<tr>
			<td align="left">
				<xsl:choose>
					<xsl:when test="$style = 'plain' and contains(parent::wadl:representation/@mediaType, 'json') and ends-with(@path,'[*]')">
						<para><xsl:if test="$style = 'plain' and $jsonPathDepth &gt; 0"><xsl:for-each select="1 to $jsonPathDepth">&#160;&#187;&#160;</xsl:for-each></xsl:if><emphasis><code role="hyphenate-true"><xsl:value-of select="@name"/></code></emphasis></para>										
					</xsl:when>
					<xsl:when test="$style = 'plain' and contains(parent::wadl:representation/@mediaType, 'json')">
						<para><xsl:if test="$style = 'plain' and $jsonPathDepth &gt; 0"><xsl:for-each select="1 to $jsonPathDepth">&#160;&#187;&#160;</xsl:for-each></xsl:if><code role="hyphenate-true"><xsl:value-of select="@name"/></code></para>										
					</xsl:when>
					<xsl:otherwise>
						<para><code role="hyphenate-true"><xsl:value-of select="concat(if (@style = 'template') then '{' else '', @name, if (@style = 'template') then '}' else '')"/></code></para>										
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td align="left">
			  <para>
				<xsl:call-template name="hyphenate.camelcase">
					<xsl:with-param name="content">
						<xsl:value-of select="concat(translate(substring($type,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($type,2))"/>
					</xsl:with-param>
				</xsl:call-template>
			  </para>
				<!--
				    Template parameters are always required, so
				    there's no point in processing @required.
				-->
                  		<xsl:choose>
                        	  <xsl:when test="@style = 'template'"/>
				  <xsl:when test="@required = 'true'"><para><emphasis>(Required)</emphasis></para></xsl:when>
				  <xsl:otherwise><para><emphasis>(Optional)</emphasis></para></xsl:otherwise>
				</xsl:choose>
			</td>			
			<td>
				<xsl:choose>
					<xsl:when test="not(wadl:doc/d:para) and not(wadl:doc/d:formalpara) and not(wadl:doc/d:itemizedlist)"><para><xsl:apply-templates select="wadl:doc/node()"/></para></xsl:when>
					<xsl:otherwise><xsl:apply-templates select="wadl:doc/*"/></xsl:otherwise>
				</xsl:choose>
				<xsl:if test="wadl:option or @style != 'template'">
				<para>
                    <xsl:if test="wadl:option"> Possible values: <xsl:for-each
							select="wadl:option">
							<xsl:value-of select="@value"/><xsl:choose>
								<xsl:when test="position() = last()">. </xsl:when>
								<xsl:otherwise>, </xsl:otherwise>
							</xsl:choose>
						</xsl:for-each> Default: <xsl:value-of select="@default"
						/><xsl:text>. </xsl:text>
					</xsl:if>
                </para>
				</xsl:if>
				<xsl:if test="@style = 'plain' and @path and contains(parent::wadl:representation/@mediaType, 'json')"><para>JSONPath: <code><xsl:value-of select="@path"/></code></para></xsl:if>
            </td>
		</tr>
		
	</xsl:template>

	<xsl:template match="wadl:response" mode="preprocess-normal">
        <xsl:variable name="normStatus" select="normalize-space(@status)"/>
		<xsl:if test="starts-with($normStatus,'2') or starts-with($normStatus,'3')">
            <xsl:call-template name="statusCodeList">
                <xsl:with-param name="codes" select="$normStatus"/>
            </xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="wadl:response" mode="preprocess-faults">
		<xsl:if
			test="(not(@status) or not(starts-with(normalize-space(@status),'2') or starts-with(normalize-space(@status),'3')))">
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
            <xsl:choose>
                <xsl:when test="@rax:phrase">
                    <xsl:value-of select="@rax:phrase"/>
                    <xsl:text> (</xsl:text>
                    <xsl:call-template name="statusCodeList">
                        <xsl:with-param name="codes" select="$codes"/>
                        <xsl:with-param name="inError" select="true()"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:when test="wadl:representation/@element">
                    <xsl:value-of select="substring-after((wadl:representation/@element)[1],':')"/>
                    <xsl:text> (</xsl:text>
                    <xsl:call-template name="statusCodeList">
                        <xsl:with-param name="codes" select="$codes"/>
                        <xsl:with-param name="inError" select="true()"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="statusCodeList">
                        <xsl:with-param name="codes" select="$codes"/>
                        <xsl:with-param name="inError" select="true()"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
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
    	<xsl:param name="style"/>
    	<xsl:param name="styleLowercase">
    		<xsl:choose>
    			<xsl:when test="$style = 'template'">URI</xsl:when>
    			<xsl:when test="$style != 'plain'">
    				<xsl:value-of select="lower-case($style)"/>
    			</xsl:when>
    			<xsl:otherwise>body</xsl:otherwise>
    		</xsl:choose>
    	</xsl:param>
    	<xsl:variable name="tableType" select="(: if($style = 'plain') then 'informaltable' else :)'informaltable'"/>
        <xsl:if test="$mode='request' or $mode='response'">
        	<para>This table shows the <xsl:value-of select="$styleLowercase"/> parameters for the <xsl:value-of select="lower-case($method.title)"/> <xsl:value-of select="concat(' ', $mode)"/>:</para>
        	<xsl:element name="{$tableType}">
            	<xsl:attribute name="rules">all</xsl:attribute>
            	<xsl:attribute name="width">100%</xsl:attribute>	
                <xsl:if test="$tableType = 'table'"><caption><xsl:value-of select="concat($method.title,' ',$mode, ' ', $styleLowercase, ' parameters')"/></caption></xsl:if>
                <col width="30%"/>
                <col width="10%"/>
                <col width="60%"/>
                <thead>
                    <tr>
                        <th align="center">Name</th>
	                    <th align="center">Type</th>
                        <th align="center">Description</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:choose>
                    	<xsl:when test="$style = 'plain'">
                    		<xsl:apply-templates select="wadl:param[@style = 'plain']">
                    			<xsl:with-param name="style">plain</xsl:with-param>
                    		</xsl:apply-templates>
                    	</xsl:when>
                        <xsl:when test="$mode = 'request'">
                            <xsl:apply-templates select="wadl:request//wadl:param[@style = $style]|parent::wadl:resource/wadl:param[@style = $style]"/>
                        </xsl:when>
                        <xsl:when test="$mode = 'response'">
                            <xsl:apply-templates select="wadl:response//wadl:param[@style = $style]"/>
                        </xsl:when>
                        <xsl:otherwise>
                        	<xsl:message>This should never happen.</xsl:message>
                            <tr>
                                <td><xsl:value-of select="$mode"/></td>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </tbody>
            </xsl:element>
        </xsl:if>
    </xsl:template>

	<!-- The following templates, paramList and group-params turn a set of 
		 plain parameters into nested itemizedlists based on the JSONPath values
		 in @path. -->
    <xsl:template name="paramList">
    	<xsl:param name="mode"/>
    	<xsl:param name="method.title"/>
<xsl:param name="method.tableintro"/>
    	<xsl:variable name="plainParams" select="wadl:param[@style = 'plain' and ./wadl:doc and @path]"/>
    	<xsl:if test="$plainParams">
        <para>This list shows the body parameters for the <xsl:value-of select="concat($method.tableintro, ' ', $mode)"/>:</para>
        	<itemizedlist role="paramList">
	    		<xsl:call-template name="group-params">
	    			<xsl:with-param name="plainParams" select="$plainParams"/>
	    			<xsl:with-param name="top" select="true()"/>
	    		</xsl:call-template>
	    	</itemizedlist> 
    	</xsl:if>
    </xsl:template>
	
	<xsl:template name="group-params">
		<xsl:param name="plainParams"/>
		<xsl:param name="top" select="false()"/>
		<xsl:param name="token-number" select="1" as="xs:integer"/>
		<xsl:for-each-group select="$plainParams" group-by="tokenize(substring-after(@path,'$.'),'\.')[$token-number]">
			<xsl:variable name="path" select="concat('$.',replace(string-join(for $item in tokenize(substring-after(current-group()[1]/@path,'$.'),'\.')[position() &lt; ($token-number + 1)] return concat($item,'.'),''),'(.*)\.$','$1'))" />
			<xsl:variable name="current-param" select="current-group()[@path = $path]"/>
			<xsl:variable name="optionality"><xsl:value-of select="if ($current-param/@required = 'true') then 'Required. ' else if ($current-param/@required = 'false') then 'Optional. ' else ''"/></xsl:variable>
			<xsl:choose>
				<xsl:when test="current-grouping-key() = '[*]' and not($top)">
					<xsl:variable name="children">
						<xsl:call-template name="group-params">
							<xsl:with-param name="token-number" select="$token-number + 1"/>
							<xsl:with-param name="plainParams" select="current-group()"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="$children/*">

							<xsl:copy-of select="$children"/>
						
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<listitem role="body-params">
						<para role="paramList"><emphasis role="bold"><xsl:value-of select="current-grouping-key()"/></emphasis>: <xsl:value-of select="if($current-param/@type) then concat(upper-case(substring(@type,1,1)),substring(@type,2),'. ') else if(current-grouping-key() = '[*]') then 'Array. ' else ''"/> <xsl:if test="not($optionality = '')"><xsl:value-of select="$optionality"/></xsl:if> </para>
						<xsl:choose>
							<xsl:when test="$current-param/wadl:doc/d:para or $current-param/wadl:doc/d:itemizedlist or $current-param/wadl:doc/d:orderedlist or $current-param/wadl:doc/d:formalpara or $current-param/wadl:doc/d:simpara">
								<xsl:apply-templates select="$current-param/wadl:doc/*" mode="copy"/>
							</xsl:when>
							<xsl:otherwise>
								<para><xsl:apply-templates select="$current-param/wadl:doc/node()" mode="copy"/></para>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:variable name="children">
							<xsl:call-template name="group-params">
								<xsl:with-param name="token-number" select="$token-number + 1"/>
								<xsl:with-param name="plainParams" select="current-group()"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:if test="$children/*">
							<itemizedlist>
								<xsl:copy-of select="$children"/>
							</itemizedlist>
						</xsl:if>
					</listitem>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</xsl:template>
	
	
	<xsl:template match="node() | @*" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" mode="copy"/>
		</xsl:copy>
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
	
<xsl:template name="hyphenate.camelcase">
  <xsl:param name="content"/>
  <xsl:variable name="head" select="substring($content, 1, 1)"/>
  <xsl:variable name="tail" select="substring($content, 2)"/>
  <xsl:choose>
    <xsl:when test="translate($head, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', '') = '' and not($tail = '')">
      <xsl:text>&#x200B;</xsl:text><xsl:value-of select="$head"/>      
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$head"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="$tail">
    <xsl:call-template name="hyphenate.camelcase">
      <xsl:with-param name="content" select="$tail"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

	<xsl:template match="d:SXXP0005">
	  <!-- This stupid template is here to avoid SXXP0005 errors from Saxon -->
	  <xsl:apply-templates/>
	</xsl:template>
	
</xsl:stylesheet>
