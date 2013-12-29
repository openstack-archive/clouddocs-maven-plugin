<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"
    xmlns:rax="http://docs.rackspace.com/api"
    xmlns:d="http://docbook.org/ns/docbook"
    exclude-result-prefixes="xs d wadl rax" version="2.0">

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:param name="compute.wadl.path.from.docbook.path">0</xsl:param>

    <xsl:param name="project.build.directory"/>

    <xsl:template match="wadl:resources[@href]">
        <xsl:variable name="wadl.path">
            <xsl:call-template name="wadlPath">
                <xsl:with-param name="path" select="@href"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:apply-templates select="document($wadl.path)//wadl:resource"/>
    </xsl:template>

    <xsl:template match="wadl:resources">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="wadl:resource[@href]"> <!-- and not(./wadl:method) -->
        <xsl:variable name="wadl.path">
            <xsl:call-template name="wadlPath">
                <xsl:with-param name="path" select="@href"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="document($wadl.path)//wadl:resource[@id = substring-after(current()/@href,'#')]/@*"/>
            <xsl:choose>
                <xsl:when test="not(./wadl:method)">
                    <xsl:apply-templates
                        select="document($wadl.path)//wadl:resource[@id = substring-after(current()/@href,'#')]/wadl:method">
                        <xsl:with-param name="resourceLink" select="."/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="wadl:method">
                        <xsl:with-param name="wadl.path" select="$wadl.path"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wadl:method[@href]">
        <xsl:param name="wadl.path"/>
        <xsl:param name="resourceid" select="substring-after(parent::wadl:resource/@href,'#')"/>
        <xsl:apply-templates
            select="document($wadl.path)//wadl:resource[@id = $resourceid]/wadl:method[@rax:id = substring-after(current()/@href,'#')]">
            <xsl:with-param name="resourceLink" select="."/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template name="wadlPath">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="contains($path,'#')">
                <xsl:call-template name="wadlPath">
                    <xsl:with-param name="path"
                        select="substring-before($path,'#')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="$compute.wadl.path.from.docbook.path = '0' and contains($path,'\')">
                <xsl:call-template name="wadlPath">
                    <xsl:with-param name="path"
                        select="substring-after($path,'\')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="$compute.wadl.path.from.docbook.path = '0' and contains($path,'/')">
                <xsl:call-template name="wadlPath">
                    <xsl:with-param name="path"
                        select="substring-after($path,'/')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="$compute.wadl.path.from.docbook.path = '0'">
                <xsl:value-of
                    select="concat($project.build.directory, '/generated-resources/xml/xslt/', $path)"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes"> ERROR:
                    compute.wadl.path.from.docbook.path=1 not yet
                    supported </xsl:message>
                <!--                <xsl:value-of
                  select="concat('target/generated-resources/xml/xslt',$docbook.partial.path, $path)"
                />-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
