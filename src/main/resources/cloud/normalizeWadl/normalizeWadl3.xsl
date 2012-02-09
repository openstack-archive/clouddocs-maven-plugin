<?xml version="1.0" encoding="UTF-8"?>
<!-- 

This XSLT flattens or expands the path in the path attributes of the resource elements in the wadl. 

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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02" xmlns="http://wadl.dev.java.net/2009/02" xmlns:xsd="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsd wadl xs xsl" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:param name="resource_types">keep</xsl:param>

    <xsl:param name="format">-format</xsl:param>
    <!-- path or tree -->
    
    <xsl:variable name="paths-tokenized">
        <xsl:apply-templates select="$normalizeWadl2" mode="tokenize-paths"/>
    </xsl:variable>

    <!-- keep-format mode means we don't touch the formatting -->
    <xsl:template match="node() | @*" mode="keep-format">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="keep-format"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@path[starts-with(.,'/')]" mode="keep-format">
      <xsl:attribute name="path"><xsl:value-of select="substring-after(.,'/')"/></xsl:attribute>
    </xsl:template>

    <!--  prune-params mode: one final pass in tree-format mode where we prune redundant params  -->
    <xsl:template match="node() | @*" mode="prune-params">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="prune-params"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:resource_type|wadl:link[@resource_type]" mode="keep-format tree-format path-format">
      <xsl:if test="$resource_types = 'keep'">
	<xsl:copy>
	  <xsl:apply-templates select="@*|node()" mode="#current"/>
	</xsl:copy>      
      </xsl:if>
    </xsl:template>    

    <xsl:template 
        match="wadl:param" 
        mode="prune-params">
        <xsl:variable name="name" select="@name"/>
        <xsl:choose>
            <xsl:when test="parent::wadl:resource[ancestor::wadl:resource/wadl:param[(@style = 'template' or @style = 'header' or @style='matrix') and @name = $name]]"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*" mode="prune-params"/>
                </xsl:copy>
            </xsl:otherwise>                
        </xsl:choose>
    </xsl:template>

    <!-- Begin tree-format templates   -->

    <xsl:template match="node() | @*" mode="tree-format">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="tree-format"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:resources" mode="tree-format">
        <resources>
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="group">
                <xsl:with-param name="token-number" select="1"/>
                <xsl:with-param name="resources" select="wadl:resource"/>
            </xsl:call-template>
        </resources>
    </xsl:template>

    <xsl:template match="wadl:resource" mode="tree-format">
      <xsl:param name="token-number">1</xsl:param>
      <xsl:param name="resources"/>
      <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="group">
                <xsl:with-param name="token-number" select="$token-number + 1"/>
                <xsl:with-param name="resources" select="wadl:resource"/>
            </xsl:call-template>
	    <xsl:apply-templates select="*" mode="tree-format">
	      <xsl:with-param name="path" select="@path"/>	      
	    </xsl:apply-templates>
      </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:param" mode="tree-format">
      <xsl:param name="path"/>
      <xsl:variable name="opencurly">{</xsl:variable>
      <xsl:variable name="closecurly">}</xsl:variable>
      <xsl:choose>
	<xsl:when test="@style = 'template' and 
			not(concat($opencurly,@name,$closecurly) = $path )">
 	</xsl:when>
	<xsl:otherwise>
	  <param>
	    <xsl:apply-templates select="node() | @*[not(name(.) = 'rax:id')]" mode="tree-format"/>
	  </param>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="group">
        <xsl:param name="token-number"/>
        <xsl:param name="resources"/>
        <xsl:for-each-group select="$resources" group-by="wadl:tokens/wadl:token[$token-number]">
            <resource path="{current-grouping-key()}">
	      <xsl:copy-of select="self::wadl:resource/@*[not(local-name(.) = 'path')]"/>
	      <xsl:apply-templates select="wadl:param[@style = 'template']|*[not(namespace-uri() = 'http://wadl.dev.java.net/2009/02')]" mode="tree-format">
		<xsl:with-param name="path" select="current-grouping-key()"/>
	      </xsl:apply-templates>	      
	      <xsl:if test="count(wadl:tokens/wadl:token) = $token-number">
		  <xsl:apply-templates select="*[not(self::wadl:resource) and not(self::wadl:param[@style = 'template'])]" mode="tree-format"/>
		  <xsl:call-template name="group">
		    <xsl:with-param name="token-number" select="1"/>
		    <xsl:with-param name="resources" select="wadl:resource"/>
		  </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="group">
                    <xsl:with-param name="token-number" select="$token-number + 1"/>
                    <xsl:with-param name="resources" select="current-group()"/>
                </xsl:call-template>
		<!-- <xsl:if test="count(wadl:tokens/wadl:token) = $token-number"> -->
		<!--   <xsl:apply-templates select="wadl:resource" mode="tree-format"/> -->
		<!-- </xsl:if> -->
            </resource>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="wadl:tokens" mode="tree-format">
      <xsl:if test="$debug != 0">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="tree-format"/>
        </xsl:copy>
      </xsl:if>
    </xsl:template>

    <xsl:template match="node() | @*" mode="tokenize-paths">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="tokenize-paths"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:resource" mode="tokenize-paths">
        <resource>
            <xsl:copy-of select="@*"/>
            <tokens>
                <xsl:for-each select="tokenize(replace(@path,'^/?(.+)/?$','$1'),'/')">
                    <token>
                        <xsl:value-of select="."/>
                    </token>
                </xsl:for-each>
            </tokens>
            <xsl:apply-templates select="node()" mode="tokenize-paths"/>
        </resource>
    </xsl:template>

    <!-- Begin path-format templates -->

    <xsl:template match="node() | @*" mode="path-format">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="path-format"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node() | @*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="copy"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:method[parent::wadl:resource]|wadl:param[ancestor::wadl:resource]" mode="path-format"/>

    <xsl:template match="wadl:resource[not(child::wadl:method)]" mode="path-format">
        <xsl:apply-templates select="wadl:resource" mode="path-format"/>
    </xsl:template>

    <xsl:template match="wadl:resource[wadl:method]" mode="path-format">
        <resource>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="path">
                <xsl:for-each select="ancestor-or-self::wadl:resource">
                    <xsl:sort order="ascending" select="position()"/>
                    <xsl:value-of select="replace(@path,'^/(.+)/?$','$1')"/>
                    <xsl:if test="not(position() = last())">/</xsl:if>
                </xsl:for-each>
            </xsl:attribute>
            <xsl:attribute name="id">
      		    <xsl:choose>
      			   <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
      			   <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
      		    </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="wadl:doc" mode="copy"/>
            <xsl:apply-templates select="ancestor-or-self::wadl:resource/wadl:param[@style = 'template' or @style = 'header' or @style='query' or @style='plain']" mode="copy"/>
            <xsl:apply-templates select="wadl:method" mode="copy"/>
        </resource>
        <xsl:apply-templates mode="path-format"/>
    </xsl:template>

    <xsl:template match="processing-instruction('base-uri')|wadl:doc" mode="path-format"/>

</xsl:stylesheet>