<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
                xmlns="http://docbook.org/ns/docbook" 
                xmlns:db="http://docbook.org/ns/docbook" 
                xmlns:ext="http://docs.openstack.org/common/api/v1.0"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:xlink="http://www.w3.org/1999/xlink"  
                xmlns:xi="http://www.w3.org/2001/XInclude">
    <xsl:output indent="no"/>

    <xsl:param name="targetExtQueryFile"/>
    <xsl:param name="webhelp"/>
    
    <xsl:template match="/">
        <!-- 
            For debugging only
        <xsl:message>
            @@@@@@@@@@@@@@@@<xsl:copy-of select="$targetExtQueryFile"></xsl:copy-of>@@@@@@@@@@@@@@@@@@@@&#10;
            @@@@@@@@@@@@@@@@<xsl:copy-of select="$webhelp"></xsl:copy-of>@@@@@@@@@@@@@@@@@@@@&#10;
        </xsl:message>
        -->
        <xsl:choose>
            <xsl:when test="$webhelp='true' and (/db:book/db:info/ext:extensions or /db:book/db:info/ext:extension)">
        
                <!-- debug only
                <xsl:message>^^^^^^^webhelp is true and extensions exists^^^^^^^^^^</xsl:message>
                -->
                <xsl:choose>
                    <xsl:when test="(/db:book/db:info/ext:extensions)">
                        <xsl:result-document href="{$targetExtQueryFile}">
                            <xsl:copy-of select="/db:book/db:info/ext:extensions"></xsl:copy-of>
                        </xsl:result-document>                         
                    </xsl:when>
                    <xsl:otherwise>                        
                        <xsl:result-document href="{$targetExtQueryFile}">                          
                            <xsl:copy-of select="/db:book/db:info/ext:extension"></xsl:copy-of>
                        </xsl:result-document> 
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when> 
            <xsl:otherwise>
                <!-- Do nothing 
                    For debugging
                <xsl:message>###########Do nothing^^^^^^^^^^&#10;</xsl:message>
                -->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <xsl:template match="node() | @*">

        <xsl:copy>
            <xsl:apply-templates select="node() | @*">
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="db:chapter[1]">
        <xsl:choose>
            <xsl:when test=" (/db:book/db:info/ext:extensions or /db:book/db:info/ext:extension)">
                <!-- for debugging
                <xsl:message>~~~~~~~~~~~Write out chapter~~~~~~~~~~~&#10;</xsl:message>
                -->
                <chapter>
                    <title>About This Extension</title>
                    <variablelist spacing="compact">
                        <varlistentry>
                            <term>Name</term>
                            <listitem>
                                <para>             
                                    <xsl:value-of select="/db:book/db:info//ext:extension/@name"></xsl:value-of>                                 
                                </para>
                            </listitem>
                        </varlistentry>
                        <varlistentry>
                            <term>Namespace</term>
                            <listitem>
                                <para><xsl:value-of select="/db:book/db:info//ext:extension/@namespace"/></para>
                            </listitem>
                        </varlistentry>
                        <varlistentry>
                            <term>Alias</term>
                            <listitem>
                                <para><xsl:value-of select="/db:book/db:info//ext:extension/@alias"/></para>
                            </listitem>
                        </varlistentry>
                        <varlistentry>
                            <term>Contact</term>
                            <listitem>
                                <para>
                                    <personname>
                                        <firstname><xsl:value-of select="/db:book/db:info/db:othercredit/db:personname/db:firstname"/></firstname>
                                        <surname><xsl:value-of select="/db:book/db:info/db:othercredit/db:personname/db:surname"/></surname>
                                    </personname>
                                    <xsl:if test="/db:book/db:info/db:othercredit/db:email">
                                        <email><xsl:value-of select="/db:book/db:info/db:othercredit/db:email"/></email>
                                    </xsl:if>
                                </para>
                            </listitem>
                        </varlistentry>
                        <varlistentry>
                            <term>Status</term>
                            <listitem>
                                <para>ALPHA</para>
                            </listitem>
                        </varlistentry>
                        <varlistentry>
                            <term>Last Update</term>
                            <listitem>
                                <para><xsl:value-of select="/db:book/db:info//ext:extension/@updated"/></para>
                            </listitem>
                        </varlistentry>
                        <varlistentry>
                            <term>Dependencies</term>
                            <listitem>
                                <para>OpenStack Compute API v1.1 (2011-09-08)</para>
                            </listitem>                    
                        </varlistentry>
                        <varlistentry>
                            <term>Doc Link (PDF)</term>
                            <listitem>
                                <para>
                                    <link xlink:href="{/db:book/db:info//atom:link[@type='application/pdf']/@href}">            
                                        <xsl:value-of select="/db:book/db:info//atom:link[@type='application/pdf']/@href"/>           
                                    </link>
                                </para>
                            </listitem>
                        </varlistentry>
                        <varlistentry>
                            <term>Doc Link (WADL)</term>
                            <listitem>
				<xsl:choose>
				  <xsl:when test="/db:book/db:info//atom:link[@type='application/vnd.sun.wadl+xml']/@href">
                                    <link xlink:href="{/db:book/db:info//atom:link[@type='application/vnd.sun.wadl+xml']/@href}">
                                        <xsl:value-of select="/db:book/db:info//atom:link[@type='application/vnd.sun.wadl+xml']/@href"/>
                                    </link>         
				  </xsl:when>
				  <xsl:otherwise>
				    None, the extension makes no modification to the API WADL.
				  </xsl:otherwise>
				</xsl:choose>                   
                            </listitem>
                        </varlistentry>
                        <varlistentry>
                            <term>doc Link(XSD)</term>
                            <listitem>
			      <para>
				<xsl:choose>
				  <xsl:when test="/db:book/db:info//atom:link[@type='application/xml']/@href">
                                    <link xlink:href="{/db:book/db:info//atom:link[@type='application/xml']/@href}">
                                        <xsl:value-of select="/db:book/db:info//atom:link[@type='application/xml']/@href"/>
                                    </link>         
				  </xsl:when>
				  <xsl:otherwise>
				    No schema provided.
				  </xsl:otherwise>
				</xsl:choose>                   
                                </para>
                            </listitem>
                        </varlistentry>
                        <varlistentry>
                            <term>Short Description</term>
                            <listitem>
                                <para>
                                    <xsl:value-of select="/db:book/db:info//ext:description"></xsl:value-of>
                                </para>
                            </listitem>
                        </varlistentry>
                    </variablelist>
                    <xsl:processing-instruction name="hard-pagebreak"/>
                    <example>
                        <title>Extension Query Response: XML</title>
                        <programlisting language="xml"><xsl:processing-instruction name="db-font-size">95%</xsl:processing-instruction>
                            <xsl:choose>
                                <xsl:when test="//ext:extensions">
                                    <xsl:apply-templates select="//ext:extensions" mode="escape-xml"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="//ext:extension" mode="escape-xml"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </programlisting>
                    </example>
                    <xsl:processing-instruction name="hard-pagebreak"/>
                    <example>
                        <title>Extension Query Response: JSON</title>
                        <programlisting language="json"><xsl:processing-instruction name="db-font-size">95%</xsl:processing-instruction>
                            <xsl:choose>
                                <xsl:when test="//ext:extensions">
                                    <xsl:apply-templates select="//ext:extensions" mode="xml2json"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="//ext:extension" mode="xml2json"/>
                                </xsl:otherwise>
                            </xsl:choose>  
                </programlisting>
                    </example>
                    <section>
                        <title>Document Change History</title>
                        <para>
                            The most recent changes to this document are described below.
                        </para>
                        <xsl:processing-instruction name="rax">revhistory</xsl:processing-instruction>            
                    </section>
                </chapter>               
            </xsl:when>
            <xsl:otherwise>
                <!-- Do nothing
                    For debugging
                <xsl:message>~!@~!@~!@~!@~!@~!@Do not write chapter~!@~!@~!@~!@~@</xsl:message>
                -->
            </xsl:otherwise>
        </xsl:choose>

        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>            
        </xsl:copy>       
        
    </xsl:template>

    <xsl:template match="*" mode="escape-xml">
        <xsl:if test="parent::db:info"><xsl:text>     </xsl:text></xsl:if>&lt;<xsl:value-of select="local-name(.)"/>
        
        <xsl:apply-templates select="@*" mode="escape-xml"/>
        <xsl:if test="self::ext:extensions or self::ext:extension[not(parent::ext:extensions)]"> xmlns="http://docs.openstack.org/common/api/v1.0" 
            xmlns:atom="http://www.w3.org/2005/Atom"</xsl:if><xsl:if test="not(./node())">/</xsl:if>&gt;<xsl:apply-templates xml:space="default" mode="escape-xml"/>
        <xsl:if test="node()">&lt;/<xsl:value-of select="local-name(.)"/>&gt;</xsl:if>        
    </xsl:template>


    <xsl:template match="text()"  mode="escape-xml">
        
        <xsl:variable name="lessthan">&lt;</xsl:variable>
        <xsl:variable name="amplessthan">&amp;lt;</xsl:variable>
        <xsl:variable name="greaterthan">&gt;</xsl:variable>
        <xsl:variable name="ampgreterthan">&amp;gt;</xsl:variable> 
        <xsl:variable name="amp">&amp;</xsl:variable>
        <xsl:variable name="ampamp">&amp;amp;</xsl:variable> 

        <xsl:value-of select="replace(
                                  replace(
                                      replace(.,$amp,$ampamp),
                                          $lessthan,$amplessthan),
                                      $greaterthan,$ampgreterthan)"/>

    </xsl:template>
    
    <xsl:template match="@*" mode="escape-xml">
 
        <xsl:variable name="lessthan">&lt;</xsl:variable>
        <xsl:variable name="amplessthan">&amp;lt;</xsl:variable>
        <xsl:variable name="greaterthan">&gt;</xsl:variable>
        <xsl:variable name="ampgreterthan">&amp;gt;</xsl:variable> 
        <xsl:variable name="amp">&amp;</xsl:variable>
        <xsl:variable name="ampamp">&amp;amp;</xsl:variable> 
 
        <xsl:variable name="singlequote">&#39;</xsl:variable>
        <xsl:variable name="ampsinglequote">&amp;#39;</xsl:variable>
        
        <xsl:variable name="doublequote">&#34;</xsl:variable>
        <xsl:variable name="ampdoublequote">&amp;#34;</xsl:variable>
        
        <xsl:variable name="escaped-text" 
            select="replace(
                        replace(
                            replace(
                                replace(
                                    replace(.,$amp,$ampamp),
                                        $lessthan,$amplessthan),
                                    $greaterthan,$ampgreterthan),
                                $singlequote,$ampsinglequote),
                            $doublequote,$ampdoublequote)"/>

        <xsl:value-of select="concat(' ',local-name(.),'=',$singlequote,$escaped-text,$singlequote)"/>
        <xsl:choose>
            <xsl:when test="not(position()=last())"><xsl:text>
</xsl:text><xsl:text>             </xsl:text>
            </xsl:when>
            
        </xsl:choose>
           
    </xsl:template>
    
    <xsl:param name="singlequote">'</xsl:param>
    
    <!-- Maybe use this instead (but integrate it into this xsl):
        https://code.google.com/p/xml2json-xslt/source/browse/trunk/xml2json.xslt -->
    
    <xsl:template match="ext:extensions" mode="xml2json">
        <xsl:text>{ 
        "extensions" : 
        [
        </xsl:text>
        <xsl:apply-templates mode="extension" select="./ext:extension" />
        <xsl:text>
        ]
}
        </xsl:text>
    </xsl:template>
    
    <xsl:template match="ext:extension" mode="xml2json">
        <xsl:text>{ 
        "extension" :</xsl:text>
        <xsl:apply-templates mode="extension" select="." />
        <xsl:text>
}
        </xsl:text>
    </xsl:template>
    
    <xsl:template match="ext:extension" mode="extension">
        <xsl:variable name="attribs" select="./@*"/>
        <xsl:variable name="links" select="./atom:link"/>
        <!--
        <xsl:if test="position() != 1">
            <xsl:text>,</xsl:text>
        </xsl:if>
        -->
        <xsl:text>    {
            </xsl:text>
        <xsl:apply-templates select="$attribs" mode="xml2json"/>
        <xsl:if test="ext:description">
            <xsl:if test="$attribs">
                <xsl:text>,
                </xsl:text>
            </xsl:if>
            <xsl:text>"description" : "</xsl:text>
            <xsl:value-of select="translate(normalize-space(ext:description), '&#x9;&#xa;&#xd;','   ')"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="$links">
            <xsl:text>, 
                "links" : 
                [
            </xsl:text>
            <xsl:apply-templates select="$links" mode="atomlink"/>
            <xsl:text>
                ]</xsl:text>
        </xsl:if>
        <xsl:text>
            }</xsl:text><xsl:if test="position()!=last()">,</xsl:if>
    </xsl:template>
    
    <xsl:template match="atom:link" mode="atomlink">
        
        <xsl:if test="position() != 1">
            <xsl:text>            </xsl:text>
        </xsl:if>
        
        <xsl:text>        {
        </xsl:text>
        <xsl:apply-templates select="./@*" mode="atomlink"/>
        <xsl:text>
                    }</xsl:text>
        <xsl:if test="position()!=last()"><xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>         
</xsl:text>
    </xsl:template>    
    
    <xsl:template match="@*" mode="xml2json">
        <xsl:if test="position() != 1">
            <xsl:text>,
            </xsl:text>
        </xsl:if>
        <xsl:text>    "</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>" : "</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
    </xsl:template>

    <xsl:template match="@*" mode="atomlink">
 
        <xsl:if test="position() != 1">
            <xsl:text>,
            </xsl:text>               
        </xsl:if>
        <xsl:if test="position()=1">
            <xsl:text>    </xsl:text>
        </xsl:if>
        <xsl:text>            "</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>" : "</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
    </xsl:template>

</xsl:stylesheet>