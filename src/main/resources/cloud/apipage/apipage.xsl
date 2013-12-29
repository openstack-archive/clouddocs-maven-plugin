<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:classpath="http://docs.rackspace.com/api"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:l="http://xproc.org/library"
    xmlns:rax="http://docs.rackspace.com/api"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="classpath cx d l rax wadl"
    version="1.0">

    <xsl:output
        method="html"
        indent="yes"
        doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

    <xsl:template match="node()|@*" >
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="*" priority="1">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:variable name="vtheElem" select="."/>

            <xsl:for-each select="namespace::*">
                <xsl:variable name="vPrefix" select="name()"/>

                <xsl:if test=
                    "$vtheElem/descendant::*
                    [namespace-uri()=current()
                    and
                    substring-before(name(),':') = $vPrefix
                    or
                    @*[substring-before(name(),':') = $vPrefix]
                    ]
                    ">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
