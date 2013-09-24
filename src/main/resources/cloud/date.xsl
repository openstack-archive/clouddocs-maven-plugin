<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="d"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

  <!-- 
       These templates convert ISO-8601 to more human friendly forms.

       Examples of valid inputs include:
       * 2011-03-18
       * 2011-03-18T20:05Z
  -->

  <xsl:template name="longDate">
      <xsl:param name="in"/>
      <xsl:choose>
          <xsl:when test="$in">
	    <xsl:variable name="year" select="normalize-space(substring-before(string($in),'-'))"/>
	    <xsl:variable name="rest" select="substring-after(string($in),'-')"/>
	    <xsl:variable name="month" select="normalize-space(substring-before($rest,'-'))"/>
	    <xsl:variable name="day"   select="normalize-space(substring-before(concat(substring-after($rest,'-'),'T'),'T'))"/>
              <xsl:choose>
                  <xsl:when test="$month = '01'">
                      <xsl:text>January</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '02'">
                      <xsl:text>February</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '03'">
                      <xsl:text>March</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '04'">
                      <xsl:text>April</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '05'">
                      <xsl:text>May</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '06'">
                      <xsl:text>June</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '07'">
                      <xsl:text>July</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '08'">
                      <xsl:text>August</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '09'">
                      <xsl:text>September</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '10'">
                      <xsl:text>October</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '11'">
                      <xsl:text>November</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '12'">
                      <xsl:text>December</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:message terminate="yes">
		      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		      Bad Month value in "<xsl:value-of select="$in"/>"
		      Please use the format 2011-12-31 for
		      dates.
		      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		      </xsl:message>
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
              <xsl:text>, </xsl:text>
              <xsl:value-of select="$year"/>
          </xsl:when>
          <xsl:otherwise/>
      </xsl:choose>
  </xsl:template>

  <xsl:template name="shortDate">
      <xsl:param name="in"/>
      <xsl:choose>
	<xsl:when test="$in">
	    <xsl:variable name="year" select="normalize-space(substring-before(string($in),'-'))"/>
	    <xsl:variable name="rest" select="substring-after(string($in),'-')"/>
	    <xsl:variable name="month" select="normalize-space(substring-before($rest,'-'))"/>
	    <xsl:variable name="day"   select="normalize-space(substring-before(concat(substring-after($rest,'-'),'T'),'T'))"/>
              <xsl:choose>
                  <xsl:when test="$month = '01'">
                      <xsl:text>Jan</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '02'">
                      <xsl:text>Feb</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '03'">
                      <xsl:text>Mar</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '04'">
                      <xsl:text>Apr</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '05'">
                      <xsl:text>May</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '06'">
                      <xsl:text>Jun</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '07'">
                      <xsl:text>Jul</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '08'">
                      <xsl:text>Aug</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '09'">
                      <xsl:text>Sep</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '10'">
                      <xsl:text>Oct</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '11'">
                      <xsl:text>Nov</xsl:text>
                  </xsl:when>
                  <xsl:when test="$month = '12'">
                      <xsl:text>Dec</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:message terminate="yes">
		      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		      Bad Month value in "<xsl:value-of select="$in"/>"
		      Please use the format 2011-12-31 for
		      dates.
		      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		      </xsl:message>
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
              <xsl:text>, </xsl:text>
              <xsl:value-of select="$year"/>
          </xsl:when>
          <xsl:otherwise />
      </xsl:choose>
  </xsl:template>

  <xsl:template match="d:SXXP0005">
    <!-- This stupid template is here to avoid SXXP0005 errors from Saxon -->
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
