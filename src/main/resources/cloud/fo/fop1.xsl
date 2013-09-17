<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="d"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns:d="http://docbook.org/ns/docbook"
                 xmlns:fo="http://www.w3.org/1999/XSL/Format"
                 version='1.0'>

<!-- Metadata support ("Document Properties" in Adobe Reader) -->
<xsl:template name="fop1-document-information">
  <xsl:variable name="authors" select="(//d:author|//d:editor|//d:corpauthor|//d:authorgroup)[1]"/>

  <xsl:variable name="title">
    <xsl:apply-templates select="/*[1]" mode="label.markup"/>
    <xsl:apply-templates select="/*[1]" mode="title.markup"/>
    <xsl:variable name="subtitle">
      <xsl:apply-templates select="/*[1]" mode="subtitle.markup"/>
    </xsl:variable>
    <xsl:if test="$subtitle !=''">
      <xsl:text> - </xsl:text>
      <xsl:value-of select="$subtitle"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="ccid">
      <xsl:value-of select="substring-after(string(/*/d:info/d:legalnotice/@role),'cc-')"/>
  </xsl:variable>
  <xsl:variable name="ccidURL">
      <xsl:text>http://creativecommons.org/licenses/</xsl:text>
      <xsl:value-of select="$ccid"/>
      <xsl:text>/3.0/legalcode</xsl:text>
  </xsl:variable>
  <fo:declarations>
    <x:xmpmeta xmlns:x="adobe:ns:meta/">
      <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
        <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/"
                         xmlns:xapRights='http://ns.adobe.com/xap/1.0/rights/'
                         >
            <xapRights:Marked>True</xapRights:Marked>
        </rdf:Description>
        <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <!-- Dublin Core properties go here -->
          <dc:rights>
              <rdf:Alt>
                  <rdf:li xml:lang="x-default">
                      <xsl:apply-templates mode="titlepage.mode" select="//d:copyright"/>
                      <xsl:if test="starts-with(string(/*/d:info/d:legalnotice/@role),'cc-')">
                          <xsl:text> Licensed to the public under Creative Commons Attribution </xsl:text>
                          <xsl:choose>
                              <xsl:when test="$ccid = 'by'" />
                              <xsl:when test="$ccid = 'by-sa'">
                                  <xsl:text>ShareAlike</xsl:text>
                              </xsl:when>
                              <xsl:when test="$ccid = 'by-nd'">
                                  <xsl:text>NoDerivatives</xsl:text>
                              </xsl:when>
                              <xsl:when test="$ccid = 'by-nc'">
                                  <xsl:text>NonCommercial</xsl:text>
                              </xsl:when>
                              <xsl:when test="$ccid = 'by-nc-sa'">
                                  <xsl:text>NonCommercial ShareAlike</xsl:text>
                              </xsl:when>
                              <xsl:when test="$ccid = 'by-nc-nd'">
                                  <xsl:text>NonCommercial NoDerivatives</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>
                                  <xsl:message terminate="yes">I don't understand licence <xsl:value-of select="$ccid"/></xsl:message>
                              </xsl:otherwise>
                          </xsl:choose>
                          <xsl:text> 3.0 License</xsl:text>
                      </xsl:if>
                  </rdf:li>
              </rdf:Alt>
          </dc:rights>
          <!-- Title -->
          <dc:title><xsl:value-of select="normalize-space($title)"/></dc:title>

          <!-- Author -->
	  <xsl:if test="$authors">
	    <xsl:variable name="author">
	      <xsl:choose>
		<xsl:when test="$authors[self::d:authorgroup]">
                  <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" 
                       select="$authors/*[self::d:author|self::d:corpauthor|
                                     self::d:othercredit|self::d:editor]"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="$authors[self::d:corpauthor]">
                  <xsl:value-of select="$authors"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="person.name">
                    <xsl:with-param name="node" select="$authors"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <dc:creator><xsl:value-of select="normalize-space($author)"/></dc:creator>
          </xsl:if>

          <!-- Subject -->
          <xsl:if test="//d:subjectterm">
            <dc:description>
              <xsl:for-each select="//d:subjectterm">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:if test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </dc:description>
          </xsl:if>
        </rdf:Description>
        <rdf:Description rdf:about="" xmlns:pdf="http://ns.adobe.com/pdf/1.3/">
          <!-- PDF properties go here -->

          <!-- Keywords -->
          <xsl:if test="//d:keyword">
            <pdf:Keywords>
              <xsl:for-each select="//d:keyword">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:if test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </pdf:Keywords>
          </xsl:if>
        </rdf:Description>

        <rdf:Description rdf:about="" xmlns:xmp="http://ns.adobe.com/xap/1.0/">
          <!-- XMP properties go here -->

          <!-- Creator Tool -->
          <xmp:CreatorTool>Cloud API Docs Plugin</xmp:CreatorTool>
        </rdf:Description>
        <xsl:if test="starts-with(string(/*/d:info/d:legalnotice/@role),'cc-')">
            <rdf:Description rdf:about=''
                             xmlns:cc='http://creativecommons.org/ns#'>
                <xsl:element name="cc:license">
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$ccidURL"/>
                    </xsl:attribute>
                </xsl:element>
            </rdf:Description>
        </xsl:if>
      </rdf:RDF>
    </x:xmpmeta>
  </fo:declarations>
</xsl:template>

</xsl:stylesheet>
