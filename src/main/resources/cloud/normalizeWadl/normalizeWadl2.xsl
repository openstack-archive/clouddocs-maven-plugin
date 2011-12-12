<?xml version="1.0" encoding="UTF-8"?>
<!--
Resolves hrefs on method and resource_type elements. 
-->
<!--
   Copyright 2011 Rackspace US, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02" xmlns="http://wadl.dev.java.net/2009/02" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:rax="http://docs.rackspace.com/api" exclude-result-prefixes="xs wadl" version="2.0">

  <xsl:param name="wadl2docbook">0</xsl:param>

	<!-- Delcaring this to avoid errors in Oxygen while editing. This actually comes from normalizeWadl1.xsl -->
	<xsl:param name="xsds"/>
	
	<xsl:variable name="normalizeWadl2">
		<xsl:choose>
			<xsl:when test="$strip-ids != 0">
				<!-- Now we prune the generated id that is appended to all ids where we can do it safely -->
				<xsl:apply-templates select="$processed" mode="strip-ids"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$processed"/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:variable>

	<xsl:param name="strip-ids">0</xsl:param>

	<!-- Need this to re-establish context within for-each -->
	<xsl:variable name="root" select="/"/>

	<xsl:output indent="yes"/>

	<xsl:key name="ids" match="wadl:*[@id]" use="@id"/>

	<xsl:variable name="processed">
		<xsl:apply-templates mode="normalizeWadl2"/>
	</xsl:variable>
<!--
	<xsl:template match="/">
		<xsl:copy-of select="$normalizeWadl2"/>
	</xsl:template>-->
    <xsl:template match="wadl:application" mode="normalizeWadl2">
      <xsl:choose>
	<xsl:when test="$wadl2docbook != 0">
	<application>
	  <xsl:apply-templates select="@*" mode="normalizeWadl2"/>
	  <xsl:comment>
	    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	    ! This is a representation of the resources tree           !
	    ! for use in generating a reference directly from the wadl.!
	    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	  </xsl:comment>
	  <xsl:apply-templates select="//wadl:resources" mode="store-tree"/>	 
	  <xsl:apply-templates select="node()" mode="normalizeWadl2"/>
	</application>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:copy>
	    <xsl:apply-templates select="node() | @*" mode="normalizeWadl2"/>
	  </xsl:copy>		
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template match="wadl:resources" mode="store-tree">
      <rax:resources>
		<xsl:apply-templates select="wadl:resource|processing-instruction('rax')" mode="store-tree"/>
      </rax:resources>
    </xsl:template>

    <xsl:template match="wadl:resource[./wadl:method]" mode="store-tree">
      <rax:resource>
      	<xsl:attribute name="rax:id">
      		<xsl:choose>
      			<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
      			<xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
      		</xsl:choose>
      	</xsl:attribute>
		<xsl:apply-templates select="wadl:resource|processing-instruction('rax')" mode="store-tree"/>
      </rax:resource>
    </xsl:template>
	
	<xsl:template match="processing-instruction('rax')" mode="store-tree">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="node() | @*" mode="strip-ids">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" mode="strip-ids"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[@rax:id]" mode="strip-ids">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="strip-ids"/>
			<xsl:choose>
				<xsl:when test="//*[
			not(parent::wadl:application) and 
			not(generate-id(.) = generate-id(current()) ) and 
			@rax:id = current()/@rax:id]">
					<xsl:message>[INFO] Modifying repeated id: <xsl:value-of select="@rax:id"/> to <xsl:value-of select="@id"/></xsl:message>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="id">
						<xsl:value-of select="@rax:id"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates mode="strip-ids"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="wadl:method[parent::wadl:application]|wadl:param[parent::wadl:application]|wadl:representation[parent::wadl:application]" mode="strip-ids"/>

	<xsl:template match="@rax:id" mode="strip-ids"/>

	<xsl:template match="node() | @*" mode="normalizeWadl2">
        <xsl:param name="baseID" select="''"/>
        <xsl:choose>
            <!--
                Rename a resource id in a resource_type, by appending
                the id of the implementing resource.
            -->
            <xsl:when test="local-name(.) = 'id' and local-name(..) = 'resource' and $baseID and $baseID != ''">
                <xsl:attribute name="id" select="concat($baseID,'_',.)"/>
            </xsl:when>
            <xsl:otherwise>
		<xsl:copy>
                    <xsl:apply-templates select="node() | @*" mode="normalizeWadl2">
                        <xsl:with-param name="baseID" select="$baseID"/>
                    </xsl:apply-templates>
		</xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

	<xsl:template match="wadl:method[@href]|wadl:param[@href]|wadl:representation[@href]" mode="normalizeWadl2">
		<xsl:choose>
			<xsl:when test="starts-with(@href,'#')">
				<xsl:apply-templates select="key('ids',substring-after(@href,'#'))" mode="copy-nw2">
					<xsl:with-param name="generated-id" select="generate-id(.)"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="doc">
					<xsl:choose>
						<xsl:when test="starts-with(normalize-space(@href),'http://') or starts-with(normalize-space(@href),'file://')">
						  <xsl:value-of select="substring-before(normalize-space(@href),'#')"/>
						</xsl:when>
						<xsl:otherwise>
						  <!-- It must be a relative path -->
						  <xsl:value-of select="resolve-uri(substring-before(normalize-space(@href),'#'),base-uri(.))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:comment><xsl:value-of select="local-name(.)"/> included from external wadl: <xsl:value-of select="$doc"/></xsl:comment>
				<xsl:variable name="included-wadl">
					<xsl:apply-templates select="document($doc)/*" mode="normalizeWadl2"/>
				</xsl:variable>
				<xsl:apply-templates select="$included-wadl//wadl:*[@id = substring-after(current()/@href,'#')]" mode="copy-nw2">
					<xsl:with-param name="generated-id" select="generate-id(.)"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="wadl:method|wadl:representation" mode="copy-nw2">
		<xsl:param name="generated-id"/>
		<xsl:copy>
			<xsl:copy-of select="@*[not(local-name() = 'id')]"/>
			<xsl:attribute name="rax:id" select="@id"/>
			<!-- <xsl:attribute name="id"> -->
			<!-- 	<xsl:value-of select="concat(@id, '-', $generated-id)"/> -->
			<!-- </xsl:attribute> -->
			<xsl:apply-templates select="*|comment()|processing-instruction()|text()"  mode="normalizeWadl2"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="wadl:param" mode="copy-nw2 normalizeWadl2">
		<xsl:param name="generated-id"/>
		<xsl:variable name="type-nsuri" select="namespace-uri-for-prefix(substring-before(@type,':'),.)"/>
		<xsl:variable name="type" select="substring-after(@type,':')"/>
		<xsl:choose>
			<xsl:when test="@default and $xsds/*/xsd:schema[@targetNamespace = $type-nsuri]/xsd:simpleType[@name = $type]/xsd:restriction[@base = 'xsd:string']/xsd:enumeration">
				<xsl:copy>
					<xsl:copy-of select="@*[not(local-name() = 'id') and not(local-name() = 'type')]"/>
					<xsl:attribute name="rax:id">
						<xsl:choose>
							<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="type">xsd:string</xsl:attribute>
					<!-- Explicitly adding xsd namespaced to ensure that xsd is the right prefix -->
					<xsl:namespace name="xsd" select="'http://www.w3.org/2001/XMLSchema'"/>
					<xsl:attribute name="rax:type"><xsl:value-of select="@type"/></xsl:attribute>
					<xsl:apply-templates select="*|comment()|processing-instruction()|text()"  mode="normalizeWadl2"/>
					<!-- Resolve enumerated values from xsd -->
					<xsl:for-each select="$xsds/*/xsd:schema[@targetNamespace = $type-nsuri]/xsd:simpleType[@name = $type]/xsd:restriction[@base = 'xsd:string']/xsd:enumeration">
						<option value="{@value}"/> <!-- Can I put docs in here? Should I? -->
					</xsl:for-each>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*[not(local-name() = 'id')]"/>
					<xsl:attribute name="rax:id" select="@id"/>
					<xsl:apply-templates select="*|comment()|processing-instruction()|text()"  mode="normalizeWadl2"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="wadl:resource[@type]" mode="normalizeWadl2">
        <xsl:param name="baseID" select="@id"/>
	<xsl:param name="context" select="."/>
        <xsl:variable name="realBase">
            <xsl:choose>
                <xsl:when test="@id and not($baseID)">
                    <xsl:value-of select="@id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$baseID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
		<xsl:variable name="content">
			<xsl:for-each select="tokenize(normalize-space(@type),' ')">
				<xsl:variable name="id" select="substring-after(normalize-space(.),'#')"/>
				<xsl:variable name="doc">
					<xsl:choose>
						<xsl:when test="starts-with(normalize-space(.),'http://') or starts-with(normalize-space(.),'file://')">
							<xsl:value-of select="substring-before(normalize-space(.),'#')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="resolve-uri(substring-before(normalize-space(.),'#'),base-uri($context))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="starts-with(normalize-space(.),'#')">
						<xsl:for-each select="$root/*[1]">
							<xsl:apply-templates select="key('ids',$id)/*" mode="normalizeWadl2">
                                <xsl:with-param name="baseID" select="$realBase"/>
                            </xsl:apply-templates>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="included-wadl">
							<xsl:apply-templates select="document($doc,$root)/*" mode="normalizeWadl2"/>
						</xsl:variable>
						<xsl:apply-templates select="$included-wadl//*[@id = $id]/*" mode="normalizeWadl2">
                                <xsl:with-param name="baseID" select="$realBase"/>
                        </xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:apply-templates mode="normalizeWadl2"/>
		</xsl:variable>

		<resource>
			<xsl:copy-of select="@*[name() != 'type']"/>
			<!-- Since we've combined resource types, we need to sort the
	     elements to keep things valid against the schema -->
			<xsl:copy-of select="$content/wadl:doc"/>
			<xsl:copy-of select="$content/wadl:param"/>
			<xsl:copy-of select="$content/wadl:method"/>
			<xsl:copy-of select="$content/wadl:resource"/>
		</resource>
	</xsl:template>

</xsl:stylesheet>