<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://docbook.org/ns/docbook" 
    xmlns:wadl="http://wadl.dev.java.net/2009/02"       
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:d="http://docbook.org/ns/docbook" 
    xmlns:rax="http://docs.rackspace.com/api" 
    exclude-result-prefixes="wadl rax d xhtml" version="2.0">

    <xsl:import href="classpath:///cloud/date.xsl"/>
    
    <xsl:template match="/">
		<xsl:apply-templates mode="preprocess"/>
	</xsl:template>
    
    
    	<!-- For readability while testing -->
	<!-- <xsl:output indent="yes"/>    -->
	
	<xsl:param name="project.build.directory">../../target</xsl:param>
    <xsl:param name="wadl.norequest.msg"><para>This operation does not require a request body.</para></xsl:param>
    <xsl:param name="wadl.noresponse.msg"><para>This operation does not return a response body.</para></xsl:param>
    <xsl:param name="wadl.noreqresp.msg"><para>This operation does not require a request body and does not return a response body.</para></xsl:param>
	<xsl:param name="project.directory" select="substring-before($project.build.directory,'/target')"/>
	<xsl:param name="source.directory"/>
	<xsl:param name="docbook.partial.path" select="concat(substring-after($source.directory,$project.directory),'/')"/>
	<xsl:param name="security">external</xsl:param>

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

	<xsl:template match="processing-instruction('rax')[normalize-space(.) = 'fail']">
	  <xsl:message terminate="yes">
	    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	    &lt;?rax fail?> found in the document.
	    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	  </xsl:message>
	</xsl:template>
	
	<xsl:template match="wadl:resources[@href]" mode="preprocess" priority="10">
		<xsl:variable name="wadl.path">
			<xsl:call-template name="wadlPath">
				<xsl:with-param name="path" select="@href"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="generated-reference-section">
			<xsl:apply-templates select="document($wadl.path)//rax:resources" mode="generate-reference-section">
				<xsl:with-param name="original.wadl.path" select="document($wadl.path)/wadl:application/@rax:original-wadl"/>				
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:apply-templates select="$generated-reference-section/*" mode="preprocess"/>
	</xsl:template>

	<xsl:template match="rax:resources" mode="generate-reference-section">
	    <xsl:param name="original.wadl.path"/>
		<xsl:choose>
			<xsl:when test=".//processing-instruction('rax') = 'start-sections'">
				<xsl:apply-templates select="rax:resource" mode="generate-reference-section">
					<xsl:with-param name="original.wadl.path" select="$original.wadl.path"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<wadl:resources rax:original-wadl="{$original.wadl.path}">
					<wadl:resource path="{//wadl:resource[@id = current()/@rax:id]/@path}">
						<xsl:copy-of select="//wadl:resource[@id = current()/@rax:id]/wadl:method"/>
					</wadl:resource>
					<xsl:apply-templates select="rax:resource" mode="copy-resources"/>
				</wadl:resources>
				<xsl:apply-templates  mode="generate-reference-section"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="rax:resource" mode="copy-resources">
		
		<wadl:resource path="{//wadl:resource[@id = current()/@rax:id]/@path}">
			<xsl:copy-of select="//wadl:resource[@id = current()/@rax:id]/*"/>
		</wadl:resource>
		<xsl:apply-templates select="rax:resource" mode="copy-resources"/>
	</xsl:template>

	<xsl:template match="rax:resource" mode="generate-reference-section">
		<xsl:apply-templates mode="generate-reference-section"/>
	</xsl:template>

	<xsl:template match="rax:resource[parent::rax:*[./processing-instruction('rax') = 'start-sections']]" mode="generate-reference-section">
		<xsl:param name="original.wadl.path" />
		<xsl:variable name="rax-id" select="@rax:id"/>
		<section xml:id="{translate(//wadl:resource[@id = $rax-id]/@path,'/{}','___')}" rax:original-wadl="{$original.wadl.path}">
			<title>
				<xsl:choose>
					<xsl:when test="//wadl:resource[@id = current()/@rax:id]/wadl:doc/@title">
						<xsl:value-of select="//wadl:resource[@id = current()/@rax:id]/wadl:doc/@title"/>
					</xsl:when>
					<xsl:when test="//wadl:resource[@id = current()/@rax:id]">
						<xsl:value-of select="//wadl:resource[@id = current()/@rax:id]/@path"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="no">
							ERROR: Could not determine what title to use for <xsl:copy-of select="."/>
						</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<xsl:apply-templates select="//wadl:resource[@id = current()/@rax:id]/wadl:doc/xhtml:*|//wadl:resource[@id = current()/@rax:id]/wadl:doc/d:*" mode="process-xhtml"/>
			<wadl:resources>
				<wadl:resource path="{//wadl:resource[@id = current()/@rax:id]/@path}">
					<xsl:copy-of select="//wadl:resource[@id = current()/@rax:id]/wadl:method"/>
				</wadl:resource>
				<xsl:apply-templates select="rax:resource" mode="copy-resources"/>
			</wadl:resources>
			<xsl:apply-templates  mode="generate-reference-section"/>			
		</section>
	</xsl:template>

	<xsl:template match="d:*[@role = 'api-reference']" mode="preprocess">
		
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*"/>
			
			<xsl:apply-templates select="d:*[not(local-name() = 'section')]|processing-instruction()" mode="preprocess"/>
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
						<th align="center">Method</th>
						<th align="center">URI</th>
						<th align="center">Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select=".//wadl:resources" mode="cheat-sheet"/>
				</tbody>
			</informaltable>

			<xsl:apply-templates select="wadl:resources[@href]|d:section" mode="preprocess"/>
		</xsl:element>
	</xsl:template>


	<!-- ======================================== -->
	<!-- Here we resolve an wadl stuff we find    -->
	<!-- ======================================== -->


	<xsl:template match="wadl:resources[not(@href)]" mode="cheat-sheet">
		<tr>
			<th colspan="3" align="center">
				<xsl:value-of select="parent::d:section/d:title"/>
			</th>
		</tr>
		<xsl:apply-templates select="wadl:resource" mode="method-rows"/>

	</xsl:template>
	
	<xsl:template match="wadl:resources[@href]" mode="cheat-sheet">
		<xsl:variable name="wadl.path">
			<xsl:call-template name="wadlPath">
				<xsl:with-param name="path" select="@href"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="generated-reference-section">
			<xsl:apply-templates select="document($wadl.path)//rax:resources" mode="generate-reference-section"/>
		</xsl:variable>
		<xsl:apply-templates select="$generated-reference-section//wadl:resources" mode="cheat-sheet"/>
	</xsl:template>

	<!-- <xsl:template match="wadl:resources[wadl:resource[not(./wadl:method)]]" mode="preprocess"> -->
	<!-- 	<section xml:id="{generate-id()}"> -->
	<!-- 		<title>FOOBAR</title> -->
	<!-- 		<xsl:call-template name="wadl-resources"/> -->
	<!-- 	</section> -->
	<!-- </xsl:template> -->

	<xsl:template match="wadl:resources" name="wadl-resources" mode="preprocess">
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
                </xsl:with-param>
            	<xsl:with-param name="default" select="'0'"/>
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
			<xsl:when test="@href and not(./wadl:method)">
				<xsl:apply-templates
					select="document($wadl.path)//wadl:resource[@id = substring-after(current()/@href,'#')]/wadl:method"
					mode="method-rows">
					<xsl:with-param name="wadl.path" select="$wadl.path"/>
			    	<xsl:with-param name="resourceId" select="substring-after(current()/@href,'#')"/>
				</xsl:apply-templates>   <!--[@rax:id = $href]-->
			</xsl:when>
			<xsl:when test="@href">
			  <xsl:apply-templates mode="method-rows">
			    <xsl:with-param name="wadl.path" select="$wadl.path"/>
			    <xsl:with-param name="resourceId" select="substring-after(current()/@href,'#')"/>
			  </xsl:apply-templates>

				<!-- <xsl:apply-templates -->
				<!-- 	select="document($wadl.path)//wadl:resource[@id = substring-after(current()/@href,'#')]/wadl:method" -->
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
	  <xsl:param name="local-content"/>
	    
	  <xsl:apply-templates
	      select="document($wadl.path)//wadl:resource[@id = $resourceId]/wadl:method[@rax:id = current()/@href]"
	      mode="method-rows">
	    <xsl:with-param name="local-content">
	      <!-- Pass down content added in the DocBook doc -->
	      <xsl:copy-of select="./*"/>
	    </xsl:with-param>
	  </xsl:apply-templates>  
	</xsl:template>

	<xsl:template match="wadl:resource" mode="preprocess">
		<xsl:variable name="wadl.path">
			<xsl:call-template name="wadlPath">
				<xsl:with-param name="path" select="@href"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="original.wadl.path" select="document($wadl.path)/wadl:application/@rax:original-wadl|ancestor::*/@rax:original-wadl"/>
		<xsl:variable name="resource-path"       select="document($wadl.path)//wadl:resource[@id = substring-after(current()/@href,'#')]/@path"/>
		<xsl:variable name="template-parameters">
		  <root>
		    <xsl:copy-of select="document($wadl.path)//wadl:resource[@id = substring-after(current()/@href,'#')]/wadl:param"/>
		  </root>
		</xsl:variable>
		<xsl:choose>
		  <!-- When the wadl;resource contains no wadl:method references, then fetch all of the 
		       wadl:method elements from the wadl. -->
			<xsl:when test="@href and not(./wadl:method)">
				<xsl:apply-templates
					select="document($wadl.path)//wadl:resource[@id = substring-after(current()/@href,'#')]/wadl:method"
					mode="preprocess">
					<xsl:with-param name="sectionId" select="ancestor::d:section/@xml:id"/>
                    <xsl:with-param name="resourceLink" select="."/>
					<xsl:with-param name="original.wadl.path" select="$original.wadl.path"/> 
					<xsl:with-param name="resource-path" select="$resource-path"/>
				</xsl:apply-templates>				
			</xsl:when>
			<!-- When the wadl:resource has an href AND child wadl:method elements
			     then get each of those wadl:method elements from the target wadl -->
			<!-- If there is a wadl:doc element in the wadl:method in DocBook, then copy it down into the imported method. -->
			<xsl:when test="@href">
				<xsl:variable name="combined-method">
					<xsl:apply-templates select="wadl:method" mode="combine-method">
						<xsl:with-param name="wadl.path" select="$wadl.path"/>
						<xsl:with-param name="href" select="@href"/>
					</xsl:apply-templates>
				</xsl:variable>
<!--				<xsl:if test="$combined-method//wadl:method[@rax:id = 'authenticate']">
					<xsl:message terminate="yes">
						<xsl:copy-of select="$combined-method"/>
					</xsl:message>
				</xsl:if>-->
				<xsl:apply-templates select="$combined-method//wadl:method" mode="preprocess">
					<xsl:with-param name="resource-path" select="$resource-path"/>
					<xsl:with-param name="original.wadl.path" select="$original.wadl.path"/> 
					<xsl:with-param name="template-parameters" select="$template-parameters"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="wadl:method" mode="preprocess">
                    <xsl:with-param name="resourceLink" select="."/>
					<xsl:with-param name="resource-path" select="$resource-path"/>
					<xsl:with-param name="sectionId" select="ancestor::d:section/@xml:id"/>
					<xsl:with-param name="original.wadl.path" select="$original.wadl.path"/> 
					<xsl:with-param name="template-parameters" select="$template-parameters"/>
                </xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
	
	<xsl:template match="wadl:method" mode="combine-method">
		<xsl:param name="wadl.path"/>
		<xsl:param name="href"/>
		<wadl:method>
			<xsl:copy-of select="document($wadl.path)//wadl:resource[@id = substring-after($href,'#')]/wadl:method[@rax:id = current()/@href]/@*"/>
			<xsl:apply-templates 
				select="document($wadl.path)//wadl:resource[@id = substring-after($href,'#')]/wadl:method[@rax:id = current()/@href]/node()" 
				mode="combine-method">
				<xsl:with-param name="wadl-doc">
					<xsl:copy-of select="wadl:doc/node()"/>
				</xsl:with-param>
			</xsl:apply-templates>
		</wadl:method>
	</xsl:template>
	
	<xsl:template match="wadl:doc" mode="combine-method">
		<xsl:param name="wadl-doc"/>
		<wadl:doc>
			<xsl:apply-templates select="@*" mode="combine-method"/>
			<xsl:copy-of select="$wadl-doc"/>
			<xsl:apply-templates select="node()" mode="combine-method"/>
		</wadl:doc>
	</xsl:template>
	
	<xsl:template match="node() | @*" mode="combine-method">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" mode="combine-method"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="wadl:method" mode="method-rows">
	  <xsl:param name="local-content"/>
		<xsl:call-template name="method-row">
		  <xsl:with-param name="local-content" select="$local-content"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="wadl:method" mode="preprocess">
		<xsl:param name="resource-path"/>
		<xsl:param name="sectionId"/>
        <xsl:param name="resourceLink"/>
		<xsl:param name="original.wadl.path"/>
		<xsl:param name="template-parameters">
		  <root/>
		</xsl:param>


        <xsl:variable name="id" select="@rax:id"/>
        <!-- Handle skipText PIs -->
        <xsl:variable name="skipNoRequestTextN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
				<xsl:if test="$resourceLink or processing-instruction('rax-wadl')">
                    <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="$resourceLink/wadl:method[contains(@href,$id)]/ancestor-or-self::*/processing-instruction('rax-wadl')|processing-instruction('rax-wadl')"/>
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
                					<xsl:if test="$resourceLink or processing-instruction('rax-wadl')">
                    <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="$resourceLink/wadl:method[contains(@href,$id)]/ancestor-or-self::*/processing-instruction('rax-wadl')|processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'skipNoResponeText'"/>
                    </xsl:call-template>
                						</xsl:if>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="skipNoResponseText" select="boolean(number($skipNoResponseTextN))"/>
        <xsl:variable name="addMethodPageBreaksN">
            <xsl:call-template name="makeBoolean">
                <xsl:with-param name="boolValue">
                <xsl:if test="$resourceLink or processing-instruction('rax-wadl')">
                    <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="$resourceLink/wadl:method[contains(@href,$id)]/ancestor-or-self::*/processing-instruction('rax-wadl')|processing-instruction('rax-wadl')"/>
                        <xsl:with-param name="attribute" select="'addMethodPageBreaks'"/>
                    </xsl:call-template>
                </xsl:if>
                </xsl:with-param>
            	<xsl:with-param name="default" select="'1'"/>
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
		<section xml:id="{concat(@name,'_',@rax:id,'_',translate($resource-path, $replacechars, '___'),'_',$sectionId)}">
			<title><xsl:value-of select="$method.title"/></title>
			<xsl:if test="$security = 'writeronly'">
			  <para security="writeronly">Source wadl: <link xlink:href="{$original.wadl.path}"><xsl:value-of select="$original.wadl.path"/></link>  (method id: <xsl:value-of select="@rax:id"/>)</para>
			</xsl:if>
			<informaltable rules="all">
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
					  <xsl:with-param name="context">reference-page</xsl:with-param>
					  <xsl:with-param name="resource-path" select="$resource-path"/>
					</xsl:call-template>
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
				<xsl:when test="wadl:doc//xhtml:*[@class = 'shortdesc'] or wadl:doc//db:*[@role = 'shortdesc']" xmlns:db="http://docbook.org/ns/docbook">
			    <xsl:apply-templates select="wadl:doc" mode="process-xhtml"/>
			  </xsl:when>
			  <xsl:otherwise>
			    <!-- Suppress because everything will be in the table -->
			  </xsl:otherwise>
			</xsl:choose>
        <!--    <xsl:copy-of select="wadl:doc/db:*[not(@role='shortdesc')] | wadl:doc/processing-instruction()"   xmlns:db="http://docbook.org/ns/docbook" />-->

            <!-- About the request -->
	    <xsl:if test="wadl:request/wadl:param[@style != 'plain']|$template-parameters//wadl:param">
                <xsl:call-template name="paramTable">
                    <xsl:with-param name="mode" select="'Request'"/>
                    <xsl:with-param name="method.title" select="$method.title"/>
		    <xsl:with-param name="template-parameters" select="$template-parameters"/>
                </xsl:call-template>
            </xsl:if>

			<xsl:copy-of select="wadl:request/wadl:representation/wadl:doc/db:* | wadl:request/wadl:representation/wadl:doc/processing-instruction()"   xmlns:db="http://docbook.org/ns/docbook" />
            <xsl:if test="wadl:request/wadl:representation/wadl:doc//xhtml:*">
                <xsl:apply-templates select="wadl:request/wadl:representation/wadl:doc/xhtml:*" mode="process-xhtml"/>
            </xsl:if>
            <!-- we allow no request text and there is no request... -->
	    <!-- Note that wadl:request[@mediaType = 'application/xml' and not(@element)] is there to catch the situation where -->
	    <!-- a request exists only to insert a header sample with no body -->
            <xsl:if test="not($skipNoRequestText) and (not(wadl:request) or wadl:request[wadl:representation[@mediaType = 'application/xml' and not(@element)]])">
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
			<xsl:copy-of select="wadl:response/wadl:representation/wadl:doc/db:* | wadl:response/wadl:representation/wadl:doc/processing-instruction()"   xmlns:db="http://docbook.org/ns/docbook" />
            <xsl:if test="wadl:response/wadl:representation/wadl:doc/xhtml:*">
                <xsl:apply-templates select="wadl:response/wadl:representation/wadl:doc/xhtml:*" mode="process-xhtml"/>
            </xsl:if>
            <!-- we allow no response text and we don't have a 200 level response with a representation -->
            <xsl:if test="not($skipNoResponseText) and not(wadl:response[starts-with(normalize-space(@status),'2')]/wadl:representation)">
                <!-- if we are also missing request text and it's not
                     suppressed then output the noreqresp message,
                     otherwise output the noresponse message -->
                <xsl:choose>
                    <xsl:when test="not($skipNoRequestText) and (not(wadl:request) or wadl:request[wadl:representation[@mediaType = 'application/xml' and not(@element)]])">
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
	    <xsl:param name="local-content"/>
	  <xsl:param name="resource-path"/>
	  <xsl:param name="resource-path-computed">
	  	<xsl:choose>
	  		<xsl:when test="parent::wadl:resource/@path">
	  			<xsl:value-of select="parent::wadl:resource/@path"/>
	  		</xsl:when>
	  		<xsl:otherwise>
	  			<xsl:value-of select="$resource-path"/>
	  		</xsl:otherwise>
	  	</xsl:choose>
	  </xsl:param>
	  <xsl:param name="context"/>
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
						<xsl:when test="number($trim.wadl.uri.count) &gt; 0">
							<xsl:call-template name="trimUri">
								<xsl:with-param name="trimCount" select="$trim.wadl.uri.count"/>
								<xsl:with-param name="uri" select="$resource-path-computed"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$resource-path-computed"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="$context = 'reference-page'">
					<xsl:for-each select="wadl:request/wadl:param[@style = 'query']">
						<xsl:text>&#x200b;</xsl:text><xsl:if test="position() = 1"
							>?</xsl:if><xsl:value-of select="@name"/>=<replaceable><xsl:value-of
								select="substring-after(@type,':')"/></replaceable><xsl:if
							test="not(position() = last())">&amp;</xsl:if>
					</xsl:for-each>
					</xsl:if>
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
	  <xsl:variable name="type">
	    <xsl:value-of select="substring-after(@type,':')"/>
	  </xsl:variable>
        <xsl:variable name="param">
            <xsl:choose>
                <xsl:when test="@style='header'"> header </xsl:when>
                <xsl:otherwise> parameter </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
		<xsl:if test="@style != 'plain'">
		<!-- TODO: Get more info from the xsd about these params-->
		<tr>
			<td align="left">
				<code role="hyphenate-true"><xsl:value-of select="@name"/></code>
			</td>
			<td align="left">
				<xsl:value-of
					select="concat(translate(substring(@style,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring(@style,2))"
				/>
			</td>
            <td align="left">
	    <xsl:call-template name="hyphenate.camelcase">
	      <xsl:with-param name="content">
                <xsl:value-of
                    select="concat(translate(substring($type,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($type,2))"
					/>
	      </xsl:with-param>
	    </xsl:call-template>
            </td>
			<td>
				<xsl:apply-templates select="wadl:doc" mode="process-xhtml"/>
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
                    <!--
                        Template parameters are always required, so
                        there's no poin in processing @required.
                    -->
                    <xsl:if test="@style != 'template'">
                        <xsl:choose>
                            <xsl:when test="@required = 'true'">The <code role="hyphenate-true"><xsl:value-of select="@name"/></code>
                            <xsl:value-of select="$param"/> should always be supplied. </xsl:when>
                            <xsl:otherwise>The <code role="hyphenate-true"><xsl:value-of select="@name"/></code> <xsl:value-of select="$param"/> is optional. </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </para>
            </td>
		</tr>
		</xsl:if>
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
			test="(not(@status) or not(starts-with(normalize-space(@status),'2')))">
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
                <xsl:when test="wadl:representation/@element">
                    <xsl:value-of select="substring-after(wadl:representation/@element,':')"/>
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

	<xsl:template name="wadlPath">
		<xsl:param name="path"/>
		<xsl:choose>
			<xsl:when test="contains($path,'#')">
				<xsl:call-template name="wadlPath">
					<xsl:with-param name="path" select="substring-before($path,'#')"/>
				</xsl:call-template>
			</xsl:when>
<!--			<xsl:when test="$compute.wadl.path.from.docbook.path = '0' and contains($path,'\')">
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
			</xsl:when>-->
			<xsl:otherwise>
				<xsl:value-of select="$path"/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	
	<xsl:template name="trimUri">
		<!-- Trims elements -->
		<xsl:param name="trimCount"/>
		<xsl:param name="uri"/>
		<xsl:param name="i">0</xsl:param>
		<xsl:choose>
			<xsl:when test="number($i) &lt; number($trimCount) and contains($uri,'/')">
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
	<xsl:param name="template-parameters">
	  <root/>
	</xsl:param>

        <xsl:if test="$mode='Request' or $mode='Response'">
            <table rules="all">
                <xsl:processing-instruction name="dbfo">keep-together="always"</xsl:processing-instruction> 
            	<!-- HACK!!! Technical Debt!!! This should be a <caption> but the DB xsls aren't handling them right, so I'm making it a title here. Need to fix in the base xsls-->
                <title><xsl:value-of select="concat($method.title,' ',$mode,' Parameters')"/></title>
                <col width="30%"/>
                <col width="10%"/>
                <col width="10%"/>
                <col width="40%"/>
                <thead>
                    <tr>
                        <th align="center">Name</th>
                        <th align="center">Style</th>
                        <th align="center">Type</th>
                        <th align="center">Description</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:choose>
                        <xsl:when test="$mode = 'Request'">
                            <xsl:apply-templates
                            select="wadl:request//wadl:param|$template-parameters//wadl:param"
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
                        	<xsl:message>This should never happen.</xsl:message>
                            <tr>
                                <td><xsl:value-of select="$mode"/></td>
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
	
	<xsl:template match="processing-instruction('rax')[normalize-space(.) = 'revhistory']" mode="preprocess">
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
   
   <!-- HACK ALERT! This probably should get its own step in the xpl -->
	<!-- Here we're modifying the structure of some books to make them 
		 work in the new platform better -->
	<xsl:template match="processing-instruction('raxm-following-sibling-chapters')" mode="preprocess">
		<xsl:apply-templates select="parent::d:chapter/following-sibling::d:chapter" mode="chapter2section"/>
	</xsl:template>
	<xsl:template match="d:chapter[preceding-sibling::*/processing-instruction('raxm-following-sibling-chapters')]" mode="preprocess"/>
    <xsl:template match="d:chapter" mode="chapter2section">
    	<section>
    		<xsl:apply-templates select="@*|node()" mode="preprocess"/>
    	</section>
    </xsl:template>
	
</xsl:stylesheet>
