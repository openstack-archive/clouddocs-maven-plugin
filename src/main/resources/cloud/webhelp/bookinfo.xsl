<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:raxm="http://docs.rackspace.com/api/metadata"
    xmlns:f="http://docbook.org/xslt/ns/extension"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs db raxm f"
    version="2.0">
    
    <xsl:param name="base.dir" select="'target/docbkx/xhtml/example/'"/>
    <xsl:param name="input.filename">cs-devguide</xsl:param>
    <xsl:param name="default.topic">index.html</xsl:param>
    <xsl:param name="IndexWar"/>
    <xsl:param name="groupId"/>
    <xsl:param name="artifactId"/>
    <xsl:param name="docProjectVersion"/>
    <xsl:param name="security">external</xsl:param>
    
    <!-- We need too collect lists that contain their own raxm:metadata so we can 
        add <type>s to the bookinfo for resources mentioned in lists in the doc -->
    <xsl:variable name="resource-lists" select="//db:itemizedlist[db:info/raxm:metadata]"/> 
    
    <xsl:template match="/">

        <xsl:apply-templates/>
        
        <xsl:result-document 
            href="{$base.dir}/bookinfo.xml" 
            method="xml" indent="yes" encoding="UTF-8">
            <products xmlns="">
                <latestpdf><xsl:value-of select="$input.filename"/>.pdf</latestpdf>
                <pdfoutname><xsl:value-of select="concat($input.filename,'-',/*/db:info/db:pubdate,'.pdf')"/></pdfoutname>
                <docname><xsl:value-of select="/*/db:title|/*/db:info/db:title"/></docname>
                <productname><xsl:value-of select="f:productname(//db:info/raxm:metadata/raxm:product,//db:info/raxm:metadata/raxm:product/@version)"/></productname>
                <webappname><xsl:value-of select="$input.filename"/></webappname>
                <pominfo>
                    <groupid><xsl:value-of select="$groupId"/></groupid>
                    <artifactid><xsl:value-of select="$artifactId"/></artifactid>
                    <version><xsl:value-of select="$docProjectVersion"/></version>
                </pominfo>
                <xsl:for-each-group select="//db:info/raxm:metadata" group-by="f:productnumber(raxm:product,raxm:product/@version)">             
                    <product>
                        <id><xsl:value-of select="current-grouping-key()"/></id>
                        <types>
                            <xsl:variable name="types">
                               <xsl:if test="/*/db:info/raxm:metadata">
                                <type xmlns="">
                                    <id><xsl:value-of select="f:calculatetype(/*/db:info/raxm:metadata/raxm:type)"/></id>
                                    <displayname>
                                        <xsl:choose>
                                            <xsl:when test="/*/db:info/raxm:metadata/raxm:displayname">
                                                <xsl:value-of select="/*/db:info/raxm:metadata/raxm:displayname"/>
                                            </xsl:when>
                                            <xsl:when test="/*/db:titleabbrev|/*/db:info/db:titleabbrev">
                                                <xsl:value-of select="/*/db:titleabbrev|/*/db:info/db:titleabbrev"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="/*/db:title|/*/db:info/db:title"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </displayname>
                                    <url><xsl:value-of select="concat($IndexWar,'/',/*/db:info/raxm:metadata/raxm:product,'/api/',/*/db:info/raxm:metadata/raxm:product/@version,'/',$input.filename,'/content/',$default.topic)"/></url>
                                    <sequence><xsl:value-of select="f:calculatepriority(/*/db:info//raxm:priority[1])"/></sequence> 
                                </type>  
                               </xsl:if>
                                <xsl:apply-templates 
                                    select="$resource-lists[f:productnumber(db:info/raxm:metadata/raxm:product,db:info/raxm:metadata/raxm:product/@version) = current-grouping-key()]/db:listitem" 
                                    mode="bookinfo"/>
                            </xsl:variable>
                            <xsl:apply-templates select="$types/type" mode="copy-types">
                                <xsl:sort select="number(./id)" data-type="number"/>
                            </xsl:apply-templates>
                        </types>
                    </product>                    
                </xsl:for-each-group>
            </products>
        </xsl:result-document>     
        <xsl:result-document 
            href="{$base.dir}/bookinfo.properties" 
            method="xml" indent="no" encoding="UTF-8">
<c:result xmlns:c="http://www.w3.org/ns/xproc-step">
warprefix=<xsl:value-of select="translate(translate(concat(/*/db:info/raxm:metadata/raxm:product,'-',/*/db:info/raxm:metadata/raxm:product/@version,'-'),' ','_'),' ','')"/>
warsuffix=<xsl:if test="not($security = 'external')">-<xsl:value-of select="normalize-space($security)"/></xsl:if>
product=<xsl:value-of select="/*/db:info/db:productname"/>
version=<xsl:value-of select="/*/db:info/db:releaseinfo"/>            
</c:result>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="copy-types">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="copy-types"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="db:listitem" mode="bookinfo">
        <xsl:param name="type" select="normalize-space(db:info//raxm:type[1])"/>
        <xsl:param name="priority" select="normalize-space(db:info//raxm:priority[1])"/>
        <xsl:variable name="idNumber" select="f:calculatetype($type)"/>
        
                <type xmlns="">
                    <id><xsl:value-of select="f:calculatetype(parent::*/db:info//raxm:type[1])"/></id>
                    <displayname><xsl:value-of select=".//db:link[1]"/></displayname>
                    <url><xsl:value-of select=".//db:link[1]/@xlink:href"/></url>
                    <sequence><xsl:value-of select="f:calculatepriority(parent::*/db:info//raxm:priority[1]) + count(preceding::db:listitem)"/></sequence> 
                </type>        
    </xsl:template>
        
    <xsl:function name="f:productname" as="xs:string">
        <xsl:param name="key"/>
        <xsl:param name="version"/>
        <xsl:choose>
            <xsl:when test="$key = 'servers' and $version='v2'">Cloud Servers</xsl:when>
            <xsl:when test="$key = 'servers' and $version='v1.0'">First Generation Cloud Servers</xsl:when>
            <xsl:when test="$key= 'cdb'">Cloud Databases</xsl:when>
            <xsl:when test="$key= 'cm'">Cloud Montioring</xsl:when>
            <xsl:when test="$key= 'cbs'">Cloud Block Storage</xsl:when>            
            <xsl:when test="$key= 'cloudfiles'">Cloud Files</xsl:when>            
            <xsl:when test="$key= 'loadbalancers'">Cloud Loadbalancers</xsl:when>
            <xsl:when test="$key= 'auth'">Cloud Identity</xsl:when>
            <xsl:when test="$key= 'cdns'">Cloud DNS</xsl:when>
            <xsl:when test="$key= 'sites'">Cloud Sites</xsl:when>
            <xsl:otherwise><xsl:value-of select="concat($key,', ',$version)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:productnumber" as="xs:string">
        <xsl:param name="key"/>
        <xsl:param name="version"/>
        <xsl:choose>
            <xsl:when test="$key = 'servers' and $version='v2'">1</xsl:when>
            <xsl:when test="$key = 'servers' and $version='v1.0'">9</xsl:when>
            <xsl:when test="$key= 'cdb'">2</xsl:when>
            <xsl:when test="$key= 'cm'">3</xsl:when>
            <xsl:when test="$key= 'cbs'">4</xsl:when>      
            <xsl:when test="$key= 'cloudfiles'">5</xsl:when>
            <xsl:when test="$key= 'loadbalancers'">6</xsl:when>
            <xsl:when test="$key= 'auth'">7</xsl:when>
            <xsl:when test="$key= 'cdns'">8</xsl:when>   
            <xsl:when test="$key= 'sites'">10</xsl:when>
            <xsl:otherwise>&#160;</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:calculatetype" as="xs:string">
        <xsl:param name="key"/>
        <xsl:choose>
            <xsl:when test="$key = 'concept'">1</xsl:when>
            <xsl:when test="$key= 'apiref'">2</xsl:when>
            <xsl:when test="$key= 'resource'">3</xsl:when>
            <xsl:when test="$key= 'tutorial'">4</xsl:when>      
            <xsl:when test="$key= 'apiref-mgmt'">5</xsl:when>
            <xsl:otherwise>100</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:calculatepriority">
        <xsl:param name="priority"/>
        <xsl:choose>
            <xsl:when test="normalize-space($priority) != ''">
                <xsl:value-of select="normalize-space($priority)"/>
            </xsl:when>
            <xsl:otherwise>100000</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>