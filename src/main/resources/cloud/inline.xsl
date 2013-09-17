<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                exclude-result-prefixes="xlink d"
                version='1.0'>

  <xsl:template match="d:guibutton">
    <xsl:call-template name="inline.boldseq"/>
  </xsl:template>
  
  <xsl:template match="d:guiicon">
    <xsl:call-template name="inline.boldseq"/>
  </xsl:template>
  
  <xsl:template match="d:guilabel">
    <xsl:call-template name="inline.boldseq"/>
  </xsl:template>
  
  <xsl:template match="d:guimenu">
    <xsl:call-template name="inline.boldseq"/>
  </xsl:template>
  
  <xsl:template match="d:guimenuitem">
    <xsl:call-template name="inline.boldseq"/>
  </xsl:template>
  
  <xsl:template match="d:guisubmenu">
    <xsl:call-template name="inline.boldseq"/>
  </xsl:template>

</xsl:stylesheet>