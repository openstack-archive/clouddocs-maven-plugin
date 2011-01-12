<xsl:stylesheet exclude-result-prefixes="d"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

  <xsl:template name="longDate">
      <xsl:param name="in"/>
      <xsl:choose>
          <xsl:when test="$in">
              <xsl:variable name="month" select="normalize-space(substring-before(string($in),'/'))"/>
              <xsl:variable name="rest"   select="substring-after(string($in),'/')"/>
              <xsl:variable name="day"   select="normalize-space(substring-before($rest,'/'))"/>
              <xsl:variable name="year" select="normalize-space(substring-after($rest,'/'))"/>
              <xsl:choose>
                  <xsl:when test="$month = 1">
                      <xsl:text>January</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 2">
                      <xsl:text>February</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 3">
                      <xsl:text>March</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 4">
                      <xsl:text>April</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 5">
                      <xsl:text>May</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 6">
                      <xsl:text>June</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 7">
                      <xsl:text>July</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 8">
                      <xsl:text>August</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 9">
                      <xsl:text>September</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 10">
                      <xsl:text>October</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 11">
                      <xsl:text>November</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 12">
                      <xsl:text>December</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:message terminate="yes">Bad Month value <xsl:value-of select="$month"/></xsl:message>
                  </xsl:otherwise>
              </xsl:choose>
              <xsl:text> </xsl:text>
              <xsl:choose>
                  <xsl:when test="starts-with($day, '0')">
                      <xsl:value-of select="substring($day, 2)"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="$day"/>
                  </xsl:otherwise>
              </xsl:choose>
              <xsl:text>, 20</xsl:text>
              <xsl:value-of select="$year"/>
          </xsl:when>
          <xsl:otherwise/>
      </xsl:choose>
  </xsl:template>

  <xsl:template name="shortDate">
      <xsl:param name="in"/>
      <xsl:choose>
          <xsl:when test="$in">
              <xsl:variable name="month" select="normalize-space(substring-before(string($in),'/'))"/>
              <xsl:variable name="rest"   select="substring-after(string($in),'/')"/>
              <xsl:variable name="day"   select="normalize-space(substring-before($rest,'/'))"/>
              <xsl:variable name="year" select="normalize-space(substring-after($rest,'/'))"/>
              <xsl:choose>
                  <xsl:when test="$month = 1">
                      <xsl:text>Jan</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 2">
                      <xsl:text>Feb</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 3">
                      <xsl:text>Mar</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 4">
                      <xsl:text>Apr</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 5">
                      <xsl:text>May</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 6">
                      <xsl:text>Jun</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 7">
                      <xsl:text>Jul</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 8">
                      <xsl:text>Aug</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 9">
                      <xsl:text>Sep</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 10">
                      <xsl:text>Oct</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 11">
                      <xsl:text>Nov</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = 12">
                      <xsl:text>Dec</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:message terminate="yes">Bad Month value <xsl:value-of select="$month"/></xsl:message>
                  </xsl:otherwise>
              </xsl:choose>
              <xsl:text>. </xsl:text>
              <xsl:choose>
                  <xsl:when test="starts-with($day, '0')">
                      <xsl:value-of select="substring($day, 2)"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="$day"/>
                  </xsl:otherwise>
              </xsl:choose>
              <xsl:text>, 20</xsl:text>
              <xsl:value-of select="$year"/>
          </xsl:when>
          <xsl:otherwise />
      </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
