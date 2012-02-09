<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT flattens the xsds associated with the wadl.  -->
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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0" xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="xs wadl xsd xsdxt" version="2.0">

    <xsl:import href="normalizeWadl2.xsl"/>
    <xsl:import href="normalizeWadl3.xsl"/>
    <xsl:import href="normalizeWadl4.xsl"/>

    <!-- This xslt lists and flattens xsds -->

    <xsl:output indent="yes"/>
    
    <xsl:param name="wadl2docbook">0</xsl:param>

    <xsl:param name="xsdVersion" select="xs:decimal(1.1)"/>

    <xsl:param name="flattenXsds">true</xsl:param>

    <xsl:param name="debug">0</xsl:param>
    <xsl:param name="format">-format</xsl:param>

	<xsl:param name="xsd.output.path"/>

    <xsl:param name="samples.path" select="replace(base-uri(/),'(.*/).*\.wadl', '$1')"/>

    <!-- Need this to re-establish context within for-each -->
    <xsl:variable name="root" select="/"/>

    <xsl:variable name="wadl-uri" select="replace(base-uri(.),'(.*/).*\.wadl', '$1')"/>

    <xsl:variable name="wadl-base-file-name" select="replace(base-uri(.),'^.*/(.*)\.[a-zA-Z]*$','$1')"/>

    <xsl:variable name="catalog-wadl-xsds">
        <xsl:if test="$flattenXsds != 'false'">
            <xsl:apply-templates mode="wadl-xsds"/>
        </xsl:if>
    </xsl:variable>

    <xsl:variable name="catalog-imported-xsds">

        <xsl:if test="$flattenXsds != 'false'">
            <xsl:for-each-group select="$catalog-wadl-xsds//xsd" group-by="@location">
            <xsl:apply-templates select="document(current-grouping-key())//xsd:import|document(current-grouping-key())//xsd:include" mode="catalog-imported-xsds"/>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:variable>

    <xsl:variable name="catalog">
        <xsl:if test="$flattenXsds != 'false'">
        <xsl:for-each-group select="$catalog-wadl-xsds//*|$catalog-imported-xsds//*" group-by="@location">
            <xsd location="{current-grouping-key()}" name="{concat($wadl-base-file-name, '-xsd-',position(),'.xsd')}"/>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:variable>

    <!-- 
        This variable contains ALL the flattened xsds rooted at rax:xsd. 
        We can use this to analyze all the xsds, e.g. looking for a 
        particular type. 
    -->
    <xsl:variable name="xsds">
       <xsl:for-each select="$catalog/xsd">
           <rax:xsd xmlns:rax="http://docs.rackspace.com/api"
               location="{@location}"
               name="{@name}">
                 <xsd:schema>
                     <xsl:copy-of select="document(resolve-uri(@location))/xsd:schema/@*"/>
                     <xsl:apply-templates select="document(resolve-uri(@location))" mode="flatten-xsd">
                        <xsl:with-param name="stack" select="@location"/>
                    </xsl:apply-templates>
                </xsd:schema>
           </rax:xsd>         
       </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="normalizeWadl2.xsl">
        <!-- Here we store the base-uri of this file so we can use it to find files relative to this file later -->
        <xsl:processing-instruction name="base-uri">
            <xsl:value-of select="replace(base-uri(.),'(.*/).*\.wadl', '$1')"/>
        </xsl:processing-instruction>
        <xsl:apply-templates mode="normalizeWadl2"/>
    </xsl:variable>

    <xsl:variable name="normalizeWadl3.xsl">
        <xsl:choose>
            <xsl:when test="$format = 'path-format'">
                <xsl:message>[INFO] Flattening resource paths</xsl:message>
                <xsl:apply-templates select="$normalizeWadl2" mode="path-format"/>
            </xsl:when>
            <xsl:when test="$format = 'tree-format'">
                <xsl:message>[INFO] Expanding resource paths to tree format</xsl:message>
                <xsl:variable name="tree-format">
                    <xsl:apply-templates select="$paths-tokenized/*" mode="tree-format"/>
                </xsl:variable>
                <xsl:apply-templates select="$tree-format" mode="prune-params"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>[INFO] Leaving resource paths unchanged</xsl:message>
                <xsl:apply-templates select="$normalizeWadl2" mode="keep-format"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!--    <xsl:variable name="normalizeWadl3.xsl">
        <xsl:apply-templates select="$normalizeWadl2.xsl" mode="normalizeWadl3"/>
        </xsl:variable>-->
    <xsl:variable name="normalizeWadl4.xsl">
        <xsl:choose>
            <xsl:when test="$wadl2docbook != 0">
                <xsl:apply-templates select="$normalizeWadl3.xsl" mode="normalizeWadl4"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$normalizeWadl3.xsl"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="xsdxt:transitions" mode="normalizeWadl2">
        <db:informaltable frame="void">
            <db:tbody>
                <xsl:apply-templates mode="transition"/>
            </db:tbody>
        </db:informaltable>
    </xsl:template>

    <xsl:template match="xsdxt:transition" mode="transition">
        <db:tr>
            <db:td colspan="1">
                <xsl:if test="not(preceding-sibling::xsdxt:transition)">
                    <xsl:text>Status Transition:</xsl:text>
                </xsl:if>
            </db:td>
            <db:td colspan="3">
                <xsl:apply-templates mode="transition"/>
                <xsl:if test="xsd:boolean(@onError)">
                    <xsl:text> (on error)</xsl:text>
                </xsl:if>
            </db:td>
        </db:tr>
    </xsl:template>

    <xsl:template match="xsdxt:step" mode="transition">
        <db:code><xsl:value-of select="@name"/></db:code>
        <xsl:if test="following-sibling::xsdxt:step">
            <db:inlinemediaobject>
                 <db:imageobject role="fo">
                     <!-- An Arrow -->
                     <svg
                         xmlns:svg="http://www.w3.org/2000/svg"
                         xmlns="http://www.w3.org/2000/svg"
                         version="1.0"
                         width="6.9400001"
                         height="3.1700001"
                         viewBox="0 0 6.9399998 3.1700001"
                         id="arrow"
                         xml:space="preserve">
                         <g
                             transform="matrix(-0.00770052,0,0,-0.00870534,6.9477981,3.1700001)"
                             id="Ebene_1">
                             <polygon
                                 points="902.25049,222.98633 233.17773,222.98633 233.17773,364.71875 0,182.35938 233.17773,0 233.17773,141.73242 902.25049,141.73242 902.25049,222.98633 "
                                 id="path2050" />
                         </g>
                     </svg>
                 </db:imageobject>
                 <db:textobject role="html">
                     <db:phrase>→</db:phrase>
                 </db:textobject>
            </db:inlinemediaobject>
        </xsl:if>
    </xsl:template>
    <xsl:template match="rax:examples|xsdxt:samples" 
        xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0" 
        xmlns:rax="http://docs.rackspace.com/api" mode="normalizeWadl2" priority="11">  
<!--        <example xmlns="http://docbook.org/ns/docbook">
            <title><xsl:value-of select="@title"/></title>
-->            <xsl:apply-templates mode="normalizeWadl2"/>
<!--        </example>-->
    </xsl:template>

    <xsl:template match="xsdxt:sample" 
        xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0" 
        mode="normalizeWadl2">
            <xsl:apply-templates select="xsdxt:code" mode="normalizeWadl2"/>
    </xsl:template>
    
    <xsl:template match="xsdxt:code" mode="normalizeWadl2">
        <!--
            In order to create a DocBook example from a sample of code there are,
            three variables we must determine: the media type of the example,
            a human readable title, and the content of the example itself.

            We try to determine as much as we can from context.
        -->
        <xsl:variable
            name="content"
            as="xs:string"
            select="if (@href)
                    then unparsed-text(concat($samples.path, '/',@href))
                    else xs:string(.)"/>
        <xsl:variable
            name="type"
            as="xs:string"
            select="if (@type) then @type
                    else if (ancestor::wadl:representation/@mediaType)
                    then ancestor::wadl:representation/@mediaType
                    else 'application/xml'"/> <!-- xml is the default -->
        <xsl:variable
            name="title"
            as="xs:string"
            select="if (ancestor::xsdxt:sample/@title) then ancestor::xsdxt:sample/@title
                    else if (ancestor::wadl:doc/@title) then ancestor::wadl:doc/@title
                    else ''"/> <!-- a defualt title will be computed below in this case -->
        <example xmlns="http://docbook.org/ns/docbook" role="wadl">
            <title>
            <xsl:choose>
                    <xsl:when test="string-length($title) != 0"><xsl:value-of select="$title"/></xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="ancestor::wadl:method/wadl:doc/@title">
                            <xsl:value-of select="ancestor::wadl:method/wadl:doc/@title"/>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="ancestor::wadl:response"> Response</xsl:when>
                            <xsl:when test="ancestor::wadl:request"> Request</xsl:when>
            </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="$type = 'application/xml'">: XML</xsl:when>
                            <xsl:when test="$type = 'application/json'">: JSON</xsl:when>
                            <xsl:when test="$type = 'application/atom+xml'">: ATOM</xsl:when>
                            <xsl:otherwise>: <xsl:value-of select="$type"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </title>
            <!-- Try to keep an example together if possible -->
            <xsl:processing-instruction name="dbfo">keep-together="auto"</xsl:processing-instruction>
            <programlisting xmlns="http://docbook.org/ns/docbook">
                <xsl:attribute name="language">
                    <xsl:choose>
                        <xsl:when test="$type = 'application/xml'">xml</xsl:when>
                        <xsl:when test="$type = 'application/json'">javascript</xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="$content"/>
            </programlisting>
            </example>
    </xsl:template>

    <xsl:template match="rax:example" 
        xmlns:rax="http://docs.rackspace.com/api" mode="normalizeWadl2"><example xmlns="http://docbook.org/ns/docbook" role="wadl">
            <title><xsl:value-of select="parent::rax:examples/@title"/><xsl:choose>
                <xsl:when test="@language = 'xml'">: XML</xsl:when>
                <xsl:when test="@language = 'javascript'">: JSON</xsl:when>                
            </xsl:choose></title><programlisting language="{@language}" xmlns="http://docbook.org/ns/docbook"><xsl:copy-of select="unparsed-text(concat($samples.path, '/',@href))"/></programlisting></example></xsl:template>
    <xsl:template match="/">
        <xsl:if test="$flattenXsds = 'false'">
	<xsl:message>[INFO] Not flattening xsds. Adjusting paths to xsds.</xsl:message>
        </xsl:if>

        <xsl:for-each select="$xsds/rax:xsd" xmlns:rax="http://docs.rackspace.com/api">

            <xsl:variable name="prune-imports">
                <xsl:apply-templates select="xsd:schema" mode="prune-imports"/>
            </xsl:variable>

            <xsl:result-document href="{concat($xsd.output.path,@name)}">
                <xsl:comment>
                    Flattened from: <xsl:value-of select="@location"/>
                </xsl:comment>
                <xsl:apply-templates select="$prune-imports" mode="sort-schema"/>
            </xsl:result-document>
        </xsl:for-each>

        <xsl:if test="$debug != 0">


            <xsl:result-document href="/tmp/normalizedWadl2.wadl">
                <xsl:copy-of select="$normalizeWadl2.xsl"/>
            </xsl:result-document>

            <xsl:result-document href="/tmp/normalizedWadl3.wadl">
                <xsl:copy-of select="$normalizeWadl3.xsl"/>
            </xsl:result-document>

        </xsl:if>

        <xsl:copy-of select="$normalizeWadl4.xsl"/>

    </xsl:template>

    <!-- Sort the declarations in the flattened schema -->
    <xsl:template match="node() | @*" mode="sort-schema">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="sort-schema"/>
        </xsl:copy>
    </xsl:template>

    <!-- Hack alert: Removing redundant elements and empty import-->
    <xsl:template match="xsd:element" mode="sort-schema">
        <xsl:if test="not(preceding-sibling::xsd:element[@name = current()/@name])">
            <xsl:copy>
                <xsl:apply-templates select="node() | @*" mode="sort-schema"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xsd:complexType" mode="sort-schema">
        <xsl:if test="not(preceding-sibling::xsd:complexType[@name = current()/@name])">
            <xsl:copy>
                <xsl:apply-templates select="node() | @*" mode="sort-schema"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xsd:import[@schemaLocation = '']" mode="sort-schema"/>
    <!-- Hack alert -->

    <xsl:template match="xsd:schema" mode="sort-schema">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="sort-schema"/>
            <xsl:apply-templates select="comment()|*[not(self::xsd:element) and not(self::xsd:simpleType) and not(self::xsd:complexType)]" mode="sort-schema"/>
            <xsl:apply-templates select="xsd:element" mode="sort-schema"/>
            <xsl:apply-templates select="xsd:simpleType" mode="sort-schema"/>
            <xsl:apply-templates select="xsd:complexType" mode="sort-schema"/>
        </xsl:copy>
    </xsl:template>
    <!-- Prune imports removes redundant import statements -->
    <xsl:template match="xsd:schema" mode="prune-imports">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="prune-imports"/>
            <!-- 
		 Note: This for-each-group/copy will fail if there are
		 different namespace declarations sharing the same
		 prefix. I.e. if there's both a
		 xmlns:auth="http://foo" and xmlns:auth="http://bar",
		 in the same set of xsds, then this fails.		 
	    -->
	    <xsl:for-each-group select="//namespace::node()[not(name(.) = 'xml') and not(name(.) = '')]" group-by="name(.)">
                <xsl:copy-of select="."/>
            </xsl:for-each-group>
            <xsl:for-each select="xsd:import[not(@schemaLocation = preceding::xsd:import/@schemaLocation)]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="node()" mode="prune-imports"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsd:import" mode="prune-imports"/>

    <xsl:template match="*[@vc:minVersion or @vc:maxVersion]" xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning" mode="prune-imports">
        <xsl:choose>
            <xsl:when test="@vc:minVersion and ($xsdVersion &lt; @vc:minVersion)"/>
            <xsl:when test="@vc:maxVersion and ($xsdVersion &gt;= @vc:maxVersion)"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="prune-imports"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@*|node()" mode="prune-imports">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="prune-imports"/>
        </xsl:copy>
    </xsl:template>

    <!-- End prune-imports mode templates -->


    <xsl:template match="wadl:grammars" mode="normalizeWadl2">
      <xsl:choose>
	<xsl:when test="$flattenXsds != 'false'">
        <wadl:grammars>
            <xsl:for-each select="$catalog-wadl-xsds//xsd">
                <xsl:comment>Original xsd: <xsl:value-of select="@location"/></xsl:comment>
                <wadl:include>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$catalog//xsd[@location = current()/@location]/@name"/>
                    </xsl:attribute>
                </wadl:include>
            </xsl:for-each>
        </wadl:grammars>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:copy>
	        <xsl:copy-of select="@*"/>
	  <xsl:apply-templates mode="adjust-xsd-path"/>
	    </xsl:copy>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template match="wadl:include" mode="adjust-xsd-path">
      <xsl:copy>
    	<xsl:attribute name="href">
	  <xsl:choose>
	    <xsl:when test="not(contains(@href,':/')) and not(starts-with(@href,'/'))"><xsl:value-of select="concat('../',@href)"/></xsl:when>
	    <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
      </xsl:copy>
    </xsl:template>

    <!-- Flatten xsds -->

    <xsl:template match="/" mode="flatten-xsd">
        <!-- First we create a list of all the schemas included in this schema      -->
        <xsl:variable name="included-xsds">
            <xsl:apply-templates mode="included-xsds"/>
        </xsl:variable>
        <xsl:apply-templates select="*" mode="process-xsd-contents"/>
        <xsl:for-each-group select="$included-xsds/*" group-by="@location">
            <xsl:message>[INFO] Including <xsl:value-of select="current-grouping-key()"/></xsl:message>
            <xsl:apply-templates select="document(current-grouping-key())" mode="process-xsd-contents"/>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="xsd:include" mode="included-xsds">
        <xsl:param name="stack"/>
        <xsl:variable name="schemaLocation" select="resolve-uri(@schemaLocation,document-uri(/))"/>
        <xsd location="{$schemaLocation}"/>
        <xsl:choose>
            <xsl:when test="$flattenXsds != 'false'">
        <xsl:if test="not(contains($stack, $schemaLocation))">
            <xsl:apply-templates select="document($schemaLocation)//xsd:include" mode="included-xsds">
                        <xsl:with-param name="stack" select="concat($stack,' ',$schemaLocation)"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="included-xsds"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text()|comment()|processing-instruction()" mode="included-xsds"/>

    <xsl:template match="*" mode="included-xsds">
        <xsl:apply-templates mode="included-xsds"/>
    </xsl:template>

    <xsl:template match="* | text()|comment()|processing-instruction() | @*" mode="process-xsd-contents">
        <xsl:param name="stack"/>
        <xsl:copy>
            <xsl:apply-templates select="* | text()|comment()|processing-instruction() | @*" mode="process-xsd-contents">
                <xsl:with-param name="stack" select="$stack"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsd:import" mode="process-xsd-contents">
        <xsl:variable name="schemaLocation" select="replace(concat(replace(base-uri(.),'(.*/).*\.xsd', '$1'),@schemaLocation),'/\./','/')"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="schemaLocation">
                <xsl:value-of select="$catalog//xsd[@location = $schemaLocation]/@name"/>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsd:schema" mode="process-xsd-contents">
        <xsl:apply-templates mode="process-xsd-contents"/>
    </xsl:template>

    <xsl:template match="xsd:include" mode="process-xsd-contents"/>

    <!--
    This way ended up not working. There were two of certain elements in the resulting schema :-(
    
    <xsl:template match="xsd:include" mode="flatten-xsd">
        <xsl:param name="stack"/>
        <xsl:choose>
            <xsl:when test="contains($stack,base-uri(document(@schemaLocation)))">
                <xsl:message>[INFO] Recursion detected, skipping: <xsl:value-of select="base-uri(document(@schemaLocation))"/></xsl:message>
            </xsl:when>
            <xsl:otherwise>
                 <xsl:message><xsl:value-of select="concat($stack, ' ', base-uri(document(@schemaLocation)))"/></xsl:message>
                <xsl:comment>Source (xsd:include): <xsl:value-of select="base-uri(document(@schemaLocation))"/></xsl:comment>
                <xsl:apply-templates select="document(@schemaLocation,.)/xsd:schema/*" mode="flatten-xsd">
                    <xsl:with-param name="stack">
                        <xsl:value-of select="concat($stack, ' ', base-uri(document(@schemaLocation)))"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                <xsl:comment>End source: <xsl:value-of select="base-uri(document(@schemaLocation))"/></xsl:comment>
                <xsl:text>            
                </xsl:text>
                <xsl:message><xsl:value-of select="$stack"/></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->

    <!-- Collect list of xsds included in the main wadl or in any included wadls   -->

    <xsl:template match="* | text()|comment()|processing-instruction() | @*" mode="wadl-xsds">
        <xsl:apply-templates select="* | text()|comment()|processing-instruction() | @*" mode="wadl-xsds"/>
    </xsl:template>

    <xsl:template match="wadl:include" mode="wadl-xsds">
        <xsd location="{resolve-uri(@href,document-uri(/))}"/>
    </xsl:template>

    <xsl:template match="@href[not(substring-before(.,'#') = '')]" mode="wadl-xsds">
        <xsl:apply-templates select="document(substring-before(.,'#'),.)/*" mode="wadl-xsds"/>
    </xsl:template>

    <xsl:template match="wadl:resource[@type]" mode="wadl-xsds">
        <xsl:for-each select="tokenize(normalize-space(@type),' ')">
            <xsl:variable name="doc">
                <xsl:choose>
                    <xsl:when test="starts-with(normalize-space(.),'http://') or starts-with(normalize-space(.),'file://') or starts-with(normalize-space(.),'test://')">
                        <xsl:value-of select="substring-before(normalize-space(.),'#')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(normalize-space(.),'#')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="starts-with(normalize-space(.),'#')"/>
                <xsl:otherwise>
                    <xsl:message>
                        <xsl:value-of select="$doc"/>
                    </xsl:message>
                    <xsl:apply-templates select="document($doc,$root)/*" mode="wadl-xsds"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- End section -->

    <!--  Find xsds imported into xsd or into any included xsd  -->

    <xsl:template match="xsd:include|xsd:import" mode="catalog-imported-xsds">
        <xsl:param name="stack"/>
        <xsl:if test="self::xsd:import">
            <xsd type="imported" location="{resolve-uri(@schemaLocation,document-uri(/))}"/>
        </xsl:if>
        <xsl:if test="not(contains($stack,base-uri(.)))">
            <xsl:apply-templates select="document(resolve-uri(@schemaLocation,document-uri(/)))//xsd:import|document(resolve-uri(@schemaLocation,document-uri(/)))//xsd:include" mode="catalog-imported-xsds">
                <xsl:with-param name="stack">
                    <xsl:value-of select="concat($stack, ' ',base-uri(.))"/>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
