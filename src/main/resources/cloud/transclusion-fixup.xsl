<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://nwalsh.com/ns/xslt/functions"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
		exclude-result-prefixes="db f xlink xs cx"
                version="2.0">

<xsl:template match="element()">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@xml:id" priority="100">
  <xsl:variable name="id" select="f:trans-id(.)"/>
  <xsl:if test="exists($id)">
    <xsl:attribute name="xml:id" select="$id"/>
  </xsl:if>
</xsl:template>

<xsl:template match="@linkend|@xlink:href[starts-with(.,'#')]" priority="100">
  <xsl:variable name="hash" select="if (starts-with(.,'#')) then '#' else ''"/>
  <xsl:variable name="linkend"
                select="if ($hash='#') then substring-after(., '#') else ."/>

  <xsl:variable name="xiroot" select="(ancestor-or-self::*[@db:idfixup or @db:idprefix])[last()]"/>
  <xsl:variable name="fixup" select="if($xiroot/@db:idfixup) then $xiroot/@db:idfixup else if($xiroot/@db:idprefix) then 'prefix' else 'none'"/>
  <xsl:variable name="linkscope" select="$xiroot/@db:linkscope"/>

  <xsl:choose>
    <xsl:when test="empty($fixup) or $linkscope='user'">
      <xsl:copy/>
    </xsl:when>

    <xsl:when test="($fixup='prefix' or $fixup='auto')
                    and $linkscope='local'">
      <xsl:choose>
        <xsl:when test="$fixup='auto'">
          <xsl:variable name="id" select="concat('idf-', generate-id($xiroot), '-', .)"/>
          <xsl:attribute name="{node-name(.)}" select="concat($hash, $id)"/>
        </xsl:when>
        <xsl:when test="$fixup='prefix'">
          <xsl:variable name="id" select="concat($xiroot/@db:idprefix, .)"/>
          <xsl:attribute name="{node-name(.)}" select="concat($hash, $id)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>Unrecognized db:idfixup value: </xsl:text>
            <xsl:value-of select="$fixup"/>
          </xsl:message>
          <xsl:copy/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="$linkscope='local'">
      <xsl:message>
        <xsl:text>Error: linkscope 'local' cannot be used with fixup '</xsl:text>
        <xsl:value-of select="$fixup"/>
        <xsl:text>'. Link ignored.</xsl:text>
      </xsl:message>
      <xsl:copy/>
    </xsl:when>

    <xsl:when test="$linkscope='near'">
      <xsl:variable name="link" as="xs:string?">
        <xsl:call-template name="f:trans-link">
          <xsl:with-param name="id" select="."/>
          <xsl:with-param name="targets"
                          select="reverse(preceding::*[@xml:id=$linkend])"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="exists($link)">
          <xsl:attribute name="{node-name(.)}" select="concat($hash, $link)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="link" as="xs:string?">
            <xsl:call-template name="f:trans-link">
              <xsl:with-param name="id" select="."/>
              <xsl:with-param name="targets"
                              select="following::*[@xml:id=$linkend]"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="exists($link)">
              <xsl:attribute name="{node-name(.)}" select="concat($hash, $link)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>
                <xsl:text>Failed to find near target for link: </xsl:text>
                <xsl:value-of select="$linkend"/>
              </xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
      <!-- assume $linkscope='global' -->
      <xsl:variable name="link" as="xs:string?">
        <xsl:call-template name="f:trans-link">
          <xsl:with-param name="id" select="."/>
          <xsl:with-param name="targets" select="//*[@xml:id=$linkend]"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="exists($link)">
          <xsl:attribute name="{node-name(.)}" select="concat($hash, $link)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>Failed to find global target for link: </xsl:text>
            <xsl:value-of select="$linkend"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="@db:idfixup|@db:idprefix|@db:linkscope|@cx:root"/>

<xsl:template match="attribute()|text()|comment()|processing-instruction()">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:trans-id" as="xs:string?">
  <xsl:param name="id" as="attribute(xml:id)"/>

  <xsl:variable name="xiroot" select="($id/ancestor-or-self::*[@db:idfixup or @db:idprefix])[last()]"/>
  <xsl:variable name="fixup" select="if($xiroot/@db:idfixup) then $xiroot/@db:idfixup else if($xiroot/@db:idprefix) then 'prefix' else 'none'"/> 

  <xsl:choose>
    <xsl:when test="empty($fixup) or $fixup='none'">
      <xsl:value-of select="$id"/>
    </xsl:when>
    <xsl:when test="$fixup='strip'">
      <xsl:if test="$xiroot is $id/parent::*">
        <xsl:value-of select="$id"/>
      </xsl:if>
    </xsl:when>
    <xsl:when test="$fixup='auto'">
      <xsl:value-of select="concat('idf-', generate-id($xiroot), '-', $id)"/>
    </xsl:when>
    <xsl:when test="$fixup='prefix'">
      <xsl:value-of select="concat($xiroot/@db:idprefix, $id)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>
        <xsl:text>Unrecognized db:idfixup value: </xsl:text>
        <xsl:value-of select="$fixup"/>
      </xsl:message>
      <xsl:value-of select="$id"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:template name="f:trans-link" as="xs:string?">
  <xsl:param name="id" required="yes" as="xs:string"/>
  <xsl:param name="targets" required="yes" as="element()*"/>

  <xsl:if test="exists($targets)">
    <xsl:variable name="link" select="f:trans-id($targets[1]/@xml:id)"/>
    <xsl:choose>
      <xsl:when test="empty($link)">
        <xsl:call-template name="f:trans-link">
          <xsl:with-param name="id" select="$id"/>
          <xsl:with-param name="targets" select="$targets[position() &gt; 1]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$link"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
