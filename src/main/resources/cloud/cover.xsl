<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY lowercase "'abcdefghijklmnopqrstuvwxyz'">
<!ENTITY uppercase "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'">
 ]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:svg="http://www.w3.org/2000/svg"
                version="1.0">
    <xsl:output method="xml" encoding="UTF-8" media-type="image/svg+xml" standalone="no"/>
    
    <xsl:param name="docbook.infile" select="'/Users/jorgew/projects/cloud-files-api-docs/src/docbkx/cfdevguide_d5.xml'"/>
    <xsl:param name="branding"/>
    <xsl:param name="coverColor"/>
    <xsl:param name="draft.status" select="''"/>

    <xsl:variable name="docbook" select="document($docbook.infile)"/>

  <xsl:variable name="status.bar.text">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="$docbook/*/processing-instruction('rax')"/>
      <xsl:with-param name="attribute" select="'status.bar.text'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="draft.text">
      <xsl:if test="$draft.status = 'on' or ($docbook/*[contains(translate(@status,&lowercase;,&uppercase;),'DRAFT')] and $draft.status = '')">DRAFT</xsl:if>
  </xsl:variable>

  <xsl:variable name="rackspace.status.text">
      <xsl:if test="not(normalize-space($status.bar.text) = '')"><xsl:value-of select="normalize-space($status.bar.text)"/></xsl:if> 
  </xsl:variable>
    
    <xsl:variable name="status.bar.text.font.size">
        <xsl:call-template name="pi-attribute">
            <xsl:with-param name="pis" select="$docbook/*/processing-instruction('rax')"/>
            <xsl:with-param name="attribute" select="'status.bar.text.font.size'"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="title.font.size">
        <xsl:call-template name="pi-attribute">
            <xsl:with-param name="pis" select="$docbook/*/processing-instruction('rax')"/>
            <xsl:with-param name="attribute" select="'title.font.size'"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="subtitle.font.size">
        <xsl:call-template name="pi-attribute">
            <xsl:with-param name="pis" select="$docbook/*/processing-instruction('rax')"/>
            <xsl:with-param name="attribute" select="'subtitle.font.size'"/>
        </xsl:call-template>
    </xsl:variable>


    <xsl:variable name="plaintitle">
        <xsl:choose>
            <xsl:when test="$docbook/*/d:title">
                <xsl:copy-of select="$docbook/*/d:title"/>
            </xsl:when>
            <xsl:when test="$docbook/*/d:info/d:title">
                <xsl:copy-of select="$docbook/*/d:info/d:title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:text>This template requires a docbook title!</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="plainsubtitle">
        <xsl:choose>
            <xsl:when test="$docbook/*/d:subtitle">
                <xsl:copy-of select="$docbook/*/d:subtitle"/>
            </xsl:when>
            <xsl:when test="$docbook/*/d:info/d:subtitle">
                <xsl:copy-of select="$docbook/*/d:info/d:subtitle"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="productname">
        <xsl:copy-of select="$docbook/*/d:info/d:productname"/>
    </xsl:variable>
    <xsl:variable name="title">
        <xsl:choose>
            <!--
                If there's a product name, and the product name is in the
                subtitle then use the product name for the title.
            -->
            <xsl:when test="(string-length(string($productname)) > 0) and contains($plaintitle,$productname)">
                <xsl:copy-of select="$productname"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$plaintitle"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="subtitle">
        <xsl:choose>
            <xsl:when test="(string-length(string($productname))) and contains($plaintitle,$productname)">
                <xsl:value-of select="substring-before($plaintitle,$productname)"/>
                <xsl:value-of select="substring-after($plaintitle,$productname)"/>
            </xsl:when>
            <xsl:when test="$plainsubtitle">
                <xsl:value-of select="$plainsubtitle"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="releaseinfo">
        <xsl:choose>
            <xsl:when test="$docbook//d:info[1]/d:releaseinfo">
                <xsl:value-of select="$docbook//d:info[1]/d:releaseinfo"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pubdate">
        <xsl:choose>
            <xsl:when test="$docbook//d:info[1]/d:pubdate">
                <xsl:call-template name="longDate">
                    <xsl:with-param name="in" select="$docbook//d:info[1]/d:pubdate"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text()" priority="10">
        <xsl:variable name="textWithTitle">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="."/>
                <xsl:with-param name="replace" select="'$title$'"/>
                <xsl:with-param name="with" select="$title"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="textWithSubTitle">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="$textWithTitle"/>
                <xsl:with-param name="replace" select="'$subtitle$'"/>
                <xsl:with-param name="with" select="$subtitle"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="textWithReleaseInfo">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="$textWithSubTitle"/>
                <xsl:with-param name="replace" select="'$releaseinfo$'"/>
                <xsl:with-param name="with" select="$releaseinfo"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="textWithPubDate">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="$textWithReleaseInfo"/>
                <xsl:with-param name="replace" select="'$pubdate$'"/>
                <xsl:with-param name="with" select="$pubdate"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="textWithStatusText">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="$textWithPubDate"/>
                <xsl:with-param name="replace" select="'$status.text$'"/>
                <xsl:with-param name="with" select="$rackspace.status.text"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="textWithDraftText">
            <xsl:call-template name="replaceText">
                <xsl:with-param name="text" select="$textWithStatusText"/>
                <xsl:with-param name="replace" select="'$draft.text$'"/>
                <xsl:with-param name="with" select="$draft.text"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:copy-of select="$textWithDraftText"/>
    </xsl:template>

    <xsl:template name="replaceText">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="with"/>

        <xsl:choose>
            <xsl:when test="contains($text,$replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="normalize-space($with)"/>
                <xsl:value-of select="substring-after($text,$replace)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$text"/>
            </xsl:otherwise>
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

    <!-- DWC: This template comes from the DocBook xsls (MIT-style license) -->
    <xsl:template name="pi-attribute">
        <xsl:param name="pis" select="processing-instruction('BOGUS_PI')"></xsl:param>
        <xsl:param name="attribute">filename</xsl:param>
        <xsl:param name="count">1</xsl:param>
        
        <xsl:choose>
            <xsl:when test="$count>count($pis)">
                <!-- not found -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="pi">
                    <xsl:value-of select="$pis[$count]"></xsl:value-of>
                </xsl:variable>
                <xsl:variable name="pivalue">
                    <xsl:value-of select="concat(' ', normalize-space($pi))"></xsl:value-of>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains($pivalue,concat(' ', $attribute, '='))">
                        <xsl:variable name="rest" select="substring-after($pivalue,concat(' ', $attribute,'='))"></xsl:variable>
                        <xsl:variable name="quote" select="substring($rest,1,1)"></xsl:variable>
                        <xsl:value-of select="substring-before(substring($rest,2),$quote)"></xsl:value-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="pi-attribute">
                            <xsl:with-param name="pis" select="$pis"></xsl:with-param>
                            <xsl:with-param name="attribute" select="$attribute"></xsl:with-param>
                            <xsl:with-param name="count" select="$count + 1"></xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@style[contains(parent::*,'$title$')]">
      <xsl:attribute name="style"><xsl:value-of select="concat('font-size: ',$title.font.size,substring-after(.,'px'))"/>
      </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@style[contains(parent::*,'$subtitle$')]">
      <xsl:attribute name="style"><xsl:value-of select="concat('font-size: ',$subtitle.font.size, substring-after(.,'px'))"/></xsl:attribute>
    </xsl:template>

    
    <xsl:template match="svg:polygon[@id='polygon2727']">
      <xsl:copy>
	<xsl:attribute name="style">
	  <xsl:choose>
	    <xsl:when test="$coverColor != ''">fill:#<xsl:value-of select="$coverColor"/>;fill-opacity:1</xsl:when>
	    <xsl:when test="$branding = 'rackspace-private-cloud'">fill:#c42126;fill-opacity:1</xsl:when>
	    <xsl:when test="$branding = 'openstack'">fill:#ce3327;fill-opacity:1</xsl:when>
	    <xsl:when test="$branding = 'repose'">fill:#A1CAFF;fill-opacity:1</xsl:when>
	    <xsl:otherwise>fill:#c42126;fill-opacity:1</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<xsl:apply-templates select="@points|@id"/>
      </xsl:copy>
    </xsl:template>
    
    <xsl:template match="svg:tspan[contains(.,'$status.text$')]">
      <xsl:copy>
	<xsl:copy-of select="@*[not(local-name() = 'style')]"/>
	<xsl:attribute name="style">
	  <xsl:choose>
	    <xsl:when test="not($status.bar.text.font.size = '')">
	      <xsl:value-of select="concat('font-size:',$status.bar.text.font.size,';',substring-after(@style,'px;'))"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="."/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<xsl:apply-templates/>
      </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
