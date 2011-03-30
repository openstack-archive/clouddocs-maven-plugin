<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:exsl="http://exslt.org/common" 
    xmlns="http://www.w3.org/1999/xhtml" 
    version="1.0" 
    exclude-result-prefixes="exsl">

  <!-- First import the non-chunking templates that format elements
       within each chunk file. In a customization, you should
       create a separate non-chunking customization layer such
       as mydocbook.xsl that imports the original docbook.xsl and
       customizes any presentation templates. Then your chunking
       customization should import mydocbook.xsl instead of
       docbook.xsl.  -->
  <xsl:import href="docbook.xsl"/>

  <!-- chunk-common.xsl contains all the named templates for chunking.
       In a customization file, you import chunk-common.xsl, then
       add any customized chunking templates of the same name. 
       They will have import precedence over the original 
       chunking templates in chunk-common.xsl. -->
  <xsl:import href="webhelp-chunk-common.xsl"/>

  <!-- The manifest.xsl module is no longer imported because its
       templates were moved into chunk-common and chunk-code -->

  <!-- chunk-code.xsl contains all the chunking templates that use
       a match attribute.  In a customization it should be referenced
       using <xsl:include> instead of <xsl:import>, and then add
       any customized chunking templates with match attributes. But be sure
       to add a priority="1" to such customized templates to resolve
       its conflict with the original, since they have the
       same import precedence.
       
       Using xsl:include prevents adding another layer
       of import precedence, which would cause any
       customizations that use xsl:apply-imports to wrongly
       apply the chunking version instead of the original
       non-chunking version to format an element.  -->
  <xsl:include href="urn:docbkx:stylesheet-orig/../xhtml/profile-chunk-code.xsl" />


<xsl:template match="/" priority="1">
  <!-- * Get a title for current doc so that we let the user -->
  <!-- * know what document we are processing at this point. -->
  <xsl:variable name="doc.title">
    <xsl:call-template name="get.doc.title"/>
  </xsl:variable>
  <xsl:choose>
    
    <xsl:when test="false()"/>
    <!-- Can't process unless namespace removed -->
    <xsl:when test="false()"/>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$rootid != ''">
          <xsl:choose>
            <xsl:when test="count($profiled-nodes//*[@id=$rootid]) = 0">
              <xsl:message terminate="yes">
                <xsl:text>ID '</xsl:text>
                <xsl:value-of select="$rootid"/>
                <xsl:text>' not found in document.</xsl:text>
              </xsl:message>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$collect.xref.targets = 'yes' or                             $collect.xref.targets = 'only'">
                <xsl:apply-templates select="key('id', $rootid)" mode="collect.targets"/>
              </xsl:if>
              <xsl:if test="$collect.xref.targets != 'only'">
                <xsl:apply-templates select="$profiled-nodes//*[@id=$rootid]" mode="process.root"/>
                <xsl:if test="$tex.math.in.alt != ''">
                  <xsl:apply-templates select="$profiled-nodes//*[@id=$rootid]" mode="collect.tex.math"/>
                </xsl:if>
                <xsl:if test="$generate.manifest != 0">
                  <xsl:call-template name="generate.manifest">
                    <xsl:with-param name="node" select="key('id',$rootid)"/>
                  </xsl:call-template>
                </xsl:if>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$collect.xref.targets = 'yes' or                         $collect.xref.targets = 'only'">
            <xsl:apply-templates select="$profiled-nodes" mode="collect.targets"/>
          </xsl:if>
          <xsl:if test="$collect.xref.targets != 'only'">
            <xsl:apply-templates select="$profiled-nodes" mode="process.root"/>
            <xsl:if test="$tex.math.in.alt != ''">
              <xsl:apply-templates select="$profiled-nodes" mode="collect.tex.math"/>
            </xsl:if>
            <xsl:if test="$generate.manifest != 0">
              <xsl:call-template name="generate.manifest">
                <xsl:with-param name="node" select="$profiled-nodes"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



  <!-- <xsl:variable name="preprocessed"> -->
  <!--   <xsl:apply-templates mode="preprocess"/> -->
  <!-- </xsl:variable> -->

  <!-- <xsl:template match="@*|node()" mode="preprocess"> -->
  <!--   <xsl:copy> -->
  <!--     <xsl:apply-templates select="@*|node()"  mode="preprocess"/> -->
  <!--   </xsl:copy> -->
  <!-- </xsl:template> -->

  <!-- <xsl:template match="/"> -->
  <!--   <xsl:apply-templates select="$preprocessed"/> -->
  <!-- </xsl:template> -->

</xsl:stylesheet>