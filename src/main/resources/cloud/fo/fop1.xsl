<?xml version='1.0'?>
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

  <fo:declarations>
    <x:xmpmeta xmlns:x="adobe:ns:meta/">
      <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
        <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <!-- Dublin Core properties go here -->

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

      </rdf:RDF>
    </x:xmpmeta>
  </fo:declarations>
</xsl:template>

</xsl:stylesheet>
