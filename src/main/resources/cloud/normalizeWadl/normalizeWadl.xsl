<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT flattens the xsds associated with the wadl.  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02" xmlns:xsd="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs wadl xsd" version="2.0">

    <xsl:import href="normalizeWadl2.xsl"/>
    <xsl:import href="normalizeWadl3.xsl"/>

    <!-- This xslt lists and flattens xsds -->

    <xsl:output indent="yes"/>

    <xsl:param name="debug">0</xsl:param>

    <!-- Need this to re-establish context within for-each -->
    <xsl:variable name="root" select="/"/>

    <xsl:variable name="wadl-uri" select="replace(base-uri(.),'(.*/).*\.wadl', '$1')"/>

    <xsl:variable name="wadl-base-file-name" select="replace(base-uri(.),'^.*/(.*)\.[a-zA-Z]*$','$1')"/>

    <xsl:variable name="catalog-wadl-xsds">
        <xsl:apply-templates mode="wadl-xsds"/>
    </xsl:variable>

    <xsl:variable name="catalog-imported-xsds">
        <xsl:for-each-group select="$catalog-wadl-xsds//xsd" group-by="@location">
            <xsl:apply-templates select="document(current-grouping-key())//xsd:import|document(current-grouping-key())//xsd:include" mode="catalog-imported-xsds"/>
        </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="catalog">
        <xsl:for-each-group select="$catalog-wadl-xsds//*|$catalog-imported-xsds//*" group-by="@location">
            <xsd location="{current-grouping-key()}" name="{concat('target/generated-resources/xml/xslt/',$wadl-base-file-name, '-xsd-',position(),'.xsd')}"/>
        </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="normalizeWadl.xsl">
        <!-- Here we store the base-uri of this file so we can use it to find files relative to this file later -->
        <xsl:processing-instruction name="base-uri">
            <xsl:value-of select="replace(base-uri(.),'(.*/).*\.wadl', '$1')"/>
        </xsl:processing-instruction>
        <xsl:apply-templates mode="process-wadl"/>
    </xsl:variable>

    <xsl:variable name="normalizeWadl2.xsl">
        <xsl:apply-templates select="$normalizeWadl.xsl" mode="normalizeWadl2"/>
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

    <xsl:template match="/">
        <xsl:for-each select="$catalog/xsd">
            <xsl:message>[INFO] Writing: <xsl:value-of select="@location"/> as <xsl:value-of select="@name"/></xsl:message>

            <xsl:variable name="contents">
                <xsd:schema>
                    <xsl:comment>Original xsd: <xsl:value-of select="@location"/></xsl:comment>
                    <xsl:apply-templates select="document(@location,.)" mode="flatten-xsd">
                        <xsl:with-param name="stack" select="@location"/>
                    </xsl:apply-templates>
                </xsd:schema>
            </xsl:variable>

            <xsl:result-document href="{@name}">
                <xsl:apply-templates select="$contents" mode="prune-imports"/>
            </xsl:result-document>
        </xsl:for-each>

        <xsl:if test="$debug != 0">

            <xsl:result-document href="/tmp/normalizedWadl1.wadl">
                <xsl:copy-of select="$normalizeWadl.xsl"/>
            </xsl:result-document>

            <xsl:result-document href="/tmp/normalizedWadl2.wadl">
                <xsl:copy-of select="$normalizeWadl2.xsl"/>
            </xsl:result-document>

            <xsl:result-document href="/tmp/normalizedWadl3.wadl">
                <xsl:copy-of select="$normalizeWadl3.xsl"/>
            </xsl:result-document>

        </xsl:if>


        <xsl:copy-of select="$normalizeWadl3.xsl"/>
    </xsl:template>

    <!-- Prune imports removes redundant import statements -->
    <xsl:template match="xsd:schema" mode="prune-imports">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="prune-imports"/>
            <xsl:for-each select="xsd:import[not(@schemaLocation = preceding::xsd:import/@schemaLocation)]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="node()" mode="prune-imports"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsd:import" mode="prune-imports"/>

    <xsl:template match="@*|node()" mode="prune-imports">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="prune-imports"/>
        </xsl:copy>
    </xsl:template>

    <!-- End prune-imports mode templates -->

    <xsl:template match="node() | @*" mode="process-wadl">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="process-wadl"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:grammars" mode="process-wadl">
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
        <xsd location="{replace(concat(replace(base-uri(.),'(.*/).*\.xsd', '$1'),@schemaLocation),'/\./','/')}"/>
        <xsl:if test="not(contains($stack, replace(concat(replace(base-uri(.),'(.*/).*\.xsd', '$1'),@schemaLocation),'/\./','/')))">
            <xsl:apply-templates select="document(@schemaLocation)//xsd:include" mode="included-xsds">
                <xsl:with-param name="stack" select="concat($stack,' ',base-uri(.))"/>
            </xsl:apply-templates>
        </xsl:if>
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
        <xsd location="{concat($wadl-uri,@href)}"/>
    </xsl:template>

    <xsl:template match="@href[not(substring-before(.,'#') = '')]" mode="wadl-xsds">
        <xsl:apply-templates select="document(substring-before(.,'#'),.)/*" mode="wadl-xsds"/>
    </xsl:template>

    <xsl:template match="wadl:resource[@type]" mode="wadl-xsds">
        <xsl:for-each select="tokenize(normalize-space(@type),' ')">
            <xsl:variable name="doc">
                <xsl:choose>
                    <xsl:when test="starts-with(normalize-space(.),'http://') or starts-with(normalize-space(.),'file://')">
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
            <xsd type="imported" location="{replace(concat(replace(base-uri(.),'(.*/).*\.xsd', '$1'),@schemaLocation),'/\./','/')}"/>
        </xsl:if>
        <xsl:if test="not(contains($stack,base-uri(.)))">
            <xsl:apply-templates select="document(replace(@schemaLocation,'^\./',''),.)//xsd:import|document(replace(@schemaLocation,'^\./',''),.)//xsd:include" mode="catalog-imported-xsds">
                <xsl:with-param name="stack">
                    <xsl:value-of select="concat($stack, ' ',base-uri(.))"/>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>